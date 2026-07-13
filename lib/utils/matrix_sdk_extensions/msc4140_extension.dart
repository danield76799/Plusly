import 'dart:convert';

import 'package:matrix/matrix.dart' as matrix;
import 'package:matrix/matrix_api_lite/utils/logs.dart';

extension Msc4140Extension on matrix.Room {
  static final Map<String, bool> _cancelSupportCache = {};

  /// Check if the server supports delayed event cancellation.
  /// Probes the cancel endpoint once per server and caches the result.
  Future<bool> supportsDelayedEventCancel() async {
    final server = client.baseUri?.host ?? '';
    if (_cancelSupportCache.containsKey(server)) {
      return _cancelSupportCache[server]!;
    }

    try {
      // Probe the cancel endpoint with a dummy ID
      final requestUri = Uri(
        path: '/_matrix/client/unstable/org.matrix.msc4140/delayed_events/_probe/cancel',
      );
      final response = await client.httpClient.post(
        requestUri,
        body: jsonEncode({}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${client.accessToken}',
        },
      );
      // 404 = endpoint doesn't exist, anything else = it does
      final supported = response.statusCode != 404;
      _cancelSupportCache[server] = supported;
      Logs().i('MSC4140 cancel support for $server: $supported');
      return supported;
    } catch (e) {
      _cancelSupportCache[server] = false;
      Logs().w('MSC4140 cancel probe failed for $server: $e');
      return false;
    }
  }

  Future<String> scheduleDelayedEvent(
    Map<String, dynamic> content, {
    required int delay,
    String type = matrix.EventTypes.Message,
    String? txid,
    matrix.Event? inReplyTo,
    String? editEventId,
    String? threadRootEventId,
    String? threadLastEventId,
  }) async {
    // Build enriched content with reply/thread info
    final enrichedContent = Map<String, dynamic>.from(content);

    if (inReplyTo != null) {
      enrichedContent['m.relates_to'] = {
        'm.in_reply_to': {'event_id': inReplyTo.eventId},
      };
    } else if (threadRootEventId != null) {
      enrichedContent['m.relates_to'] = {
        'rel_type': 'm.thread',
        'event_id': threadRootEventId,
        'm.relatesto': threadLastEventId,
        'is_falling_back': inReplyTo == null,
      };
    }

    // PUT /_matrix/client/v3/rooms/{roomId}/send/{eventType}/{txnId}?delay={ms}
    final requestUri = Uri(
      path: '/_matrix/client/v3/rooms/$id/send/$type/$txid',
      queryParameters: {'delay': delay.toString()},
    );
    final body = jsonEncode(enrichedContent);
    final response = await client.httpClient.put(
      client.baseUri!.resolveUri(requestUri),
      body: body,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${client.accessToken}',
      },
    );
    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      // Server may return delay_id (some implementations) or just event_id
      return (responseBody['delay_id'] as String?) ?? txid ?? 'unknown';
    } else {
      final errorBody = jsonDecode(response.body);
      var text = "${errorBody['errcode']}: ${errorBody['error']}";
      if (errorBody['max_delay'] != null) {
        text += " (Max delay: ${errorBody['max_delay']})";
      }
      throw Exception(text);
    }
  }

  Future<void> _manageDelayedEvent(String delayId, String action) async {
    // POST /_matrix/client/unstable/org.matrix.msc4140/delayed_events/{delay_id}/{action}
    final requestUri = Uri(
      path: '/_matrix/client/unstable/org.matrix.msc4140/delayed_events/$delayId/$action',
    );
    final response = await client.httpClient.post(
      requestUri,
      body: jsonEncode({}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${client.accessToken}',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    try {
      final errorBody = jsonDecode(response.body);
      final text = "${errorBody['errcode']}: ${errorBody['error']}";
      throw Exception(text);
    } catch (e) {
      throw Exception(
        'Failed to $action delayed event $delayId: ${response.statusCode}',
      );
    }
  }

  /// Send the delayed event immediately instead of waiting for the delay time.
  Future<void> sendDelayedEventNow(String delayId) async {
    return _manageDelayedEvent(delayId, 'send');
  }

  /// Cancel the delayed event so that it will never be sent.
  /// Note: Not all servers support this endpoint.
  Future<void> cancelDelayedEvent(String delayId) async {
    return _manageDelayedEvent(delayId, 'cancel');
  }

  /// Restart the timer of a delayed event (reset to now + original_delay).
  Future<void> restartDelayedEvent(String delayId) async {
    return _manageDelayedEvent(delayId, 'restart');
  }

  /// Retrieve delayed events owned by the user.
  /// Optional `status` may be 'scheduled' or 'finalised'.
  Future<Map<String, dynamic>> getDelayedEvents({
    String? status,
    List<String>? delayIds,
    String? from,
  }) async {
    // GET /_matrix/client/unstable/org.matrix.msc4140/delayed_events
    const basePath = '/_matrix/client/unstable/org.matrix.msc4140/delayed_events';
    final queryParts = <String>[];
    if (status != null) {
      queryParts.add('status=${Uri.encodeQueryComponent(status)}');
    }
    if (delayIds != null) {
      for (final id in delayIds) {
        queryParts.add('delay_id=${Uri.encodeQueryComponent(id)}');
      }
    }
    if (from != null) queryParts.add('from=${Uri.encodeQueryComponent(from)}');

    final pathWithQuery = queryParts.isEmpty
        ? basePath
        : '$basePath?${queryParts.join('&')}';
    final requestUri = Uri(path: pathWithQuery);

    final response = await client.httpClient.get(
      client.baseUri!.resolveUri(requestUri),
      headers: {
        'Authorization': 'Bearer ${client.accessToken}',
      },
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded;
      } catch (e) {
        throw Exception('Failed to decode delayed events response: $e');
      }
    }
    try {
      final errorBody = jsonDecode(response.body);
      final text = "${errorBody['errcode']}: ${errorBody['error']}";
      throw Exception(text);
    } catch (e) {
      throw Exception('Failed to fetch delayed events: ${response.statusCode}');
    }
  }
}
