import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/date_time_extension.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:Pulsly/utils/url_launcher.dart';
import 'package:Pulsly/widgets/avatar.dart';

class ChatSearchMessageTab extends StatelessWidget {
  final String searchQuery;
  final Room room;
  final List<Event> events;
  final void Function() onStartSearch;
  final bool endReached;
  final bool isLoading;

  const ChatSearchMessageTab({
    required this.searchQuery,
    required this.room,
    required this.events,
    required this.onStartSearch,
    required this.endReached,
    required this.isLoading,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    if (events.isEmpty && !isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_outlined, size: 64),
          const SizedBox(height: 8),
          Text(
            l10n.searchIn(
              room.getLocalizedDisplayname(MatrixLocals(l10n)),
            ),
          ),
        ],
      );
    }

    return SelectionArea(
      child: ListView.separated(
        itemCount: events.length + 1,
        separatorBuilder: (context, _) =>
            Divider(color: theme.dividerColor, height: 1),
        itemBuilder: (context, i) {
          if (i == events.length) {
            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
              );
            }
            if (endReached) {
              return const SizedBox.shrink();
            }
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                  onPressed: onStartSearch,
                  icon: const Icon(Icons.arrow_downward_outlined),
                  label: Text(l10n.searchMore),
                ),
              ),
            );
          }
          final event = events[i];
          final sender = event.senderFromMemoryOrFallback;
          final displayname = sender.calcDisplayname(
            i18n: MatrixLocals(l10n),
          );
          return _MessageSearchResultListTile(
            sender: sender,
            displayname: displayname,
            event: event,
            room: room,
            searchQuery: searchQuery,
          );
        },
      ),
    );
  }
}

class _MessageSearchResultListTile extends StatelessWidget {
  const _MessageSearchResultListTile({
    required this.sender,
    required this.displayname,
    required this.event,
    required this.room,
    this.searchQuery = '',
  });

  final User sender;
  final String displayname;
  final Event event;
  final Room room;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);

    final body = event
        .calcLocalizedBodyFallback(
          plaintextBody: true,
          removeMarkdown: true,
          MatrixLocals(l10n),
        )
        .trim();
    final eventUri = Uri(
      pathSegments: ['rooms', room.id],
      queryParameters: {'event': event.eventId},
    );

    return ListTile(
      // Hele tegel is tikbaar, niet alleen het pijltje: het resultaat is
      // immers de reden dat je zoekt.
      onTap: () => context.go('/$eventUri'),
      title: Row(
        children: [
          Avatar(mxContent: sender.avatarUrl, name: displayname, size: 16),
          const SizedBox(width: 8),
          Text(displayname),
          Expanded(
            child: Text(
              ' | ${event.originServerTs.localizedTimeShort(context)}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
      subtitle: BodyWithHighlight(
        text: body,
        query: searchQuery,
        maxLines: 7,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.chevron_right_outlined),
        onPressed: () => context.go('/$eventUri'),
      ),
    );
  }
}

/// Berichttekst met de zoekterm gemarkeerd.
///
/// De gemarkeerde regel is precies waarom je een resultaat kiest; zonder
/// markering moet je elke zin zelf afzoeken. URLs blijven aanklikbaar, net
/// als ze dat met Linkify waren.
class BodyWithHighlight extends StatelessWidget {
  const BodyWithHighlight({
    required this.text,
    required this.query,
    this.maxLines,
    super.key,
  });

  final String text;
  final String query;
  final int? maxLines;

  static final RegExp _urlPattern = RegExp(r'^https?://\S+$');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highlight = TextStyle(
      backgroundColor: theme.colorScheme.tertiaryContainer,
      color: theme.colorScheme.onTertiaryContainer,
      fontWeight: FontWeight.w600,
    );
    final link = TextStyle(
      color: theme.colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.colorScheme.primary,
    );

    return Text.rich(
      TextSpan(children: _spans(context, link, highlight)),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  List<InlineSpan> _spans(
    BuildContext context,
    TextStyle link,
    TextStyle highlight,
  ) {
    final zoekterm = query.trim();
    final pattern = zoekterm.isEmpty
        ? RegExp(r'https?://\S+')
        : RegExp('${RegExp.escape(zoekterm)}|https?://\\S+', caseSensitive: false);

    final spans = <InlineSpan>[];
    var last = 0;
    for (final match in pattern.allMatches(text)) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      final waarde = match.group(0)!;
      if (_urlPattern.hasMatch(waarde)) {
        spans.add(
          TextSpan(
            text: waarde,
            style: link,
            recognizer: TapGestureRecognizer()
              ..onTap = () => UrlLauncher(context, waarde).launchUrl(),
          ),
        );
      } else {
        spans.add(TextSpan(text: waarde, style: highlight));
      }
      last = match.end;
    }
    if (last < text.length) {
      spans.add(TextSpan(text: text.substring(last)));
    }
    return spans;
  }
}
