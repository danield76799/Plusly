import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat_search/chat_search_message_tab.dart';
import 'package:Pulsly/utils/date_time_extension.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:Pulsly/widgets/avatar.dart';

/// Herkent een webadres in platte tekst.
///
/// Bewust smal: alleen http(s), geen mailadressen of matrix-URIs. Zo vult
/// deze tab alleen wat je er van verwacht — gedeelde webadressen — en wordt
/// hij niet gevuld met losse woorden met een dubbele punt.
final RegExp linkPattern = RegExp(r'https?://\S+');

/// Of een bericht een webadres bevat.
bool bevatLink(String tekst) => linkPattern.hasMatch(tekst);

/// Berichten met een webadres, in één lijst.
///
/// WhatsApp heeft hiervoor een aparte tab naast Media en Documenten: de
/// meest gezochte vraag in een gesprek is immers "waar stond die link ook
/// alweer?". De URL zelf is tikbaar (dat doet [BodyWithHighlight] al), en
/// het pijltje springt naar het bericht.
class ChatSearchLinksTab extends StatelessWidget {
  final String searchQuery;
  final Room room;
  final List<Event> events;
  final void Function()? onStartSearch;
  final bool endReached;
  final bool isLoading;

  const ChatSearchLinksTab({
    required this.searchQuery,
    required this.room,
    required this.events,
    this.onStartSearch,
    this.endReached = true,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    if (events.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.link_off_outlined, size: 64),
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
        // +1 voor de "meer zoeken"-knop onderaan, net als in de andere tabs.
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
            if (endReached) return const SizedBox.shrink();
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
            // De tegel gaat naar het bericht; de URL erin is zelf tikbaar.
            onTap: () => context.go('/$eventUri'),
            title: Row(
              children: [
                Avatar(
                  mxContent: sender.avatarUrl,
                  name: displayname,
                  size: 16,
                ),
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
              maxLines: 5,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.chevron_right_outlined),
              onPressed: () => context.go('/$eventUri'),
            ),
          );
        },
      ),
    );
  }
}
