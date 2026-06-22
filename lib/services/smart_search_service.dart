import 'dart:convert';
import 'package:matrix/matrix.dart';
import 'package:Pulsly/services/llm_service.dart';

/// Natural language search for Matrix chat messages.
///
/// Flow:
/// 1. User types a natural language query (e.g. "what did Daan say about the deadline?")
/// 2. LLM extracts search keywords from the query
/// 3. Matrix server-side search with those keywords
/// 4. LLM ranks results by relevance to the original question
class SmartSearchService {
  /// Extract search keywords from a natural language query.
  /// Returns a list of search terms to use with Matrix searchEvents.
  static Future<List<String>> extractKeywords(String query) async {
    if (query.trim().isEmpty) return [];

    final messages = [
      LlmMessage(
        role: 'system',
        content: 'You are a search assistant. The user asks a question about '
            'chat messages. Extract 1-5 search keywords that would help find '
            'the relevant messages. Output ONLY a JSON array of strings, '
            'nothing else. Example: ["deadline","project"]\n\n'
            'Rules:\n'
            '- Extract the most important content words\n'
            '- Skip filler words (what, did, say, about, the, a)\n'
            '- Skip time references (last week, yesterday) — those are handled separately\n'
            '- Keep names of people if mentioned\n'
            '- Lowercase everything\n'
            '- Maximum 5 keywords',
      ),
      LlmMessage(role: 'user', content: query),
    ];

    try {
      final response = await LlmService.sendMessage(messages);
      final cleaned = response.trim().replaceAll('```json', '').replaceAll('```', '').trim();
      final list = jsonDecode(cleaned) as List<dynamic>;
      return list.cast<String>().where((s) => s.isNotEmpty).toList();
    } catch (_) {
      // Fallback: split query into words, remove common stopwords
      final stopwords = {'what', 'did', 'say', 'about', 'the', 'a', 'an', 'is',
        'was', 'were', 'are', 'do', 'does', 'did', 'has', 'have', 'had',
        'wat', 'zei', 'over', 'de', 'het', 'een', 'is', 'was', 'waren',
        'heeft', 'hebben', 'kan', 'kun', 'zijn', 'weer', 'vorige', 'deze',
        'laatste', 'on', 'in', 'to', 'for', 'and', 'or', 'of', 'from',
        'last', 'this', 'week', 'yesterday', 'today', 'tomorrow'};
      return query
          .toLowerCase()
          .split(RegExp(r'[\s,.!?;:]+'))
          .where((w) => w.length > 2 && !stopwords.contains(w))
          .take(5)
          .toList();
    }
  }

  /// Search a room using natural language query.
  /// Returns ranked events most relevant to the query.
  static Future<SmartSearchResult> search({
    required Room room,
    required String query,
    String? nextBatch,
    int limit = 50,
  }) async {
    // Step 1: Extract keywords from the natural language query
    final keywords = await extractKeywords(query);

    if (keywords.isEmpty) {
      return SmartSearchResult(events: [], nextBatch: null, keywords: []);
    }

    // Step 2: Search with each keyword and merge results
    final allEvents = <Event>[];
    final seenEventIds = <String>{};
    String? latestBatch;

    for (final keyword in keywords) {
      try {
        final result = await room.searchEvents(
          searchTerm: keyword,
          nextBatch: nextBatch,
          limit: limit,
        );
        latestBatch ??= result.nextBatch;
        for (final event in result.events) {
          if (!seenEventIds.contains(event.eventId)) {
            seenEventIds.add(event.eventId);
            allEvents.add(event);
          }
        }
      } catch (_) {
        // Continue with other keywords even if one fails
      }
    }

    // Step 3: Rank results by relevance using LLM
    final ranked = await _rankResults(query, allEvents);

    return SmartSearchResult(
      events: ranked,
      nextBatch: latestBatch,
      keywords: keywords,
    );
  }

  /// Rank events by relevance to the original query.
  static Future<List<Event>> _rankResults(
    String query,
    List<Event> events,
  ) async {
    if (events.length <= 5) return events; // No need to rank small lists

    try {
      // Build a compact summary of events for the LLM to rank
      final eventSummaries = events.asMap().entries.map((entry) {
        final i = entry.key;
        final e = entry.value;
        final body = e.body;
        final snippet = body.length > 200 ? body.substring(0, 200) : body;
        final sender = e.senderId.split(':').first.replaceAll('@', '');
        return '[$i] $sender: $snippet';
      }).join('\n');

      final messages = [
        LlmMessage(
          role: 'system',
          content: 'You are a search ranker. The user asked: "$query"\n\n'
              'Here are search results. Rank them by relevance to the question. '
              'Output ONLY a JSON array of indices, most relevant first. '
              'Example: [3,0,1,2]\n\n'
              'Keep only results that are actually relevant. '
              'Maximum 20 results.',
        ),
        LlmMessage(role: 'user', content: eventSummaries),
      ];

      final response = await LlmService.sendMessage(messages);
      final cleaned = response.trim().replaceAll('```json', '').replaceAll('```', '').trim();
      final indices = jsonDecode(cleaned) as List<dynamic>;

      final ranked = <Event>[];
      for (final idx in indices) {
        final i = idx as int;
        if (i >= 0 && i < events.length) {
          ranked.add(events[i]);
        }
      }

      // If ranking failed or returned nothing, return unranked
      if (ranked.isEmpty) return events.take(20).toList();
      return ranked;
    } catch (_) {
      // Fallback: return first 20 events
      return events.take(20).toList();
    }
  }
}

/// Result from a smart search.
class SmartSearchResult {
  final List<Event> events;
  final String? nextBatch;
  final List<String> keywords;

  SmartSearchResult({
    required this.events,
    required this.nextBatch,
    required this.keywords,
  });
}