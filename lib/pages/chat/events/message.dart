import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/pages/chat/chat.dart';
import 'package:Pulsly/utils/redacted_body_cache.dart';
import 'message_bubble.dart';
import 'message_bubble_legacy.dart';
import 'message_modern.dart';

/// Bericht-layouts, overgenomen van Extera Next:
/// - bubbles: Plusly's eigen bubble-stijl (standaard, WhatsApp-achtig met
///   staarten en clusters)
/// - bubblesLegacy: klassieke FluffyChat-bubbels
/// - modern: Extera modern layout (center-aligned, compacte status-row)
enum MessageLayout { modern, bubbles, bubblesLegacy }

class Message extends StatelessWidget {
  final Event event;
  final Event? nextEvent;
  final Event? previousEvent;
  final bool displayReadMarker;
  final void Function(Event, Offset?) onSelect;
  final void Function(Event) onInfoTab;
  final void Function(String) scrollToEventId;
  final void Function(Event) onSwipe;
  final void Function() onMention;
  final bool longPressSelect;
  final bool selected;
  final Timeline timeline;
  final bool highlightMarker;
  final bool animateIn;
  final bool wallpaperMode;
  final ScrollController? scrollController;
  final ChatController? chatController;
  final List<Color> colors;
  final bool gradient;
  final bool singleSelected;
  final Thread? thread;
  final bool hasBeenRead;
  final List<Receipt>? readReceipts;
  final MessageLayout layout;

  const Message(
    this.event, {
    this.nextEvent,
    this.previousEvent,
    this.displayReadMarker = false,
    this.longPressSelect = false,
    this.gradient = false,
    this.singleSelected = false,
    this.hasBeenRead = false,
    this.readReceipts,
    this.thread,
    required this.onSelect,
    required this.onInfoTab,
    required this.scrollToEventId,
    required this.onSwipe,
    this.selected = false,
    required this.timeline,
    this.highlightMarker = false,
    this.animateIn = false,
    this.wallpaperMode = false,
    required this.onMention,
    this.scrollController,
    this.chatController,
    required this.colors,
    this.layout = MessageLayout.bubbles,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Bewaar de originele tekst ZODRA we het bericht zien. Bij een redaction
    // strip't de SDK de content weg, waarna de tekst nergens meer te vinden
    // is. Met deze cache blijft een verwijderd bericht leesbaar.
    //
    // Dit staat HIER, in de wrapper om alle drie de layouts heen (bubbles,
    // bubblesLegacy, modern): in een van de bubbel-widgets zou de cache bij
    // een andere layout leeg blijven.
    _cacheBody();

    final Widget message = switch (layout) {
      MessageLayout.bubbles => MessageBubble(
        event,
        onSelect: onSelect,
        onInfoTab: onInfoTab,
        scrollToEventId: scrollToEventId,
        onSwipe: onSwipe,
        timeline: timeline,
        onMention: onMention,
        colors: colors,
        animateIn: animateIn,
        displayReadMarker: displayReadMarker,
        gradient: gradient,
        hasBeenRead: hasBeenRead,
        highlightMarker: highlightMarker,
        key: key,
        longPressSelect: longPressSelect,
        nextEvent: nextEvent,
        previousEvent: previousEvent,
        scrollController: scrollController,
        chatController: chatController,
        selected: selected,
        singleSelected: singleSelected,
        thread: thread,
        wallpaperMode: wallpaperMode,
        readReceipts: readReceipts,
      ),
      MessageLayout.bubblesLegacy => MessageBubbleLegacy(
        event,
        onSelect: onSelect,
        onInfoTab: onInfoTab,
        scrollToEventId: scrollToEventId,
        onSwipe: onSwipe,
        timeline: timeline,
        onMention: onMention,
        colors: colors,
        animateIn: animateIn,
        displayReadMarker: displayReadMarker,
        gradient: gradient,
        hasBeenRead: hasBeenRead,
        highlightMarker: highlightMarker,
        key: key,
        longPressSelect: longPressSelect,
        nextEvent: nextEvent,
        previousEvent: previousEvent,
        scrollController: scrollController,
        chatController: chatController,
        selected: selected,
        singleSelected: singleSelected,
        thread: thread,
        wallpaperMode: wallpaperMode,
      ),
      MessageLayout.modern => MessageModern(
        event,
        onSelect: onSelect,
        onInfoTab: onInfoTab,
        scrollToEventId: scrollToEventId,
        onSwipe: onSwipe,
        timeline: timeline,
        onMention: onMention,
        colors: colors,
        animateIn: animateIn,
        displayReadMarker: displayReadMarker,
        gradient: gradient,
        hasBeenRead: hasBeenRead,
        highlightMarker: highlightMarker,
        key: key,
        longPressSelect: longPressSelect,
        nextEvent: nextEvent,
        previousEvent: previousEvent,
        scrollController: scrollController,
        chatController: chatController,
        selected: selected,
        singleSelected: singleSelected,
        thread: thread,
        wallpaperMode: wallpaperMode,
      ),
    };

    return message;
  }

  /// Bewaart de originele tekst van dit bericht in [RedactedBodyCache].
  ///
  /// Bij een Matrix-redaction verwijdert de SDK de content van het event
  /// (`Event.setRedactionEvent` zet `prevContent` op null en leegt de
  /// content-whitelist). Daarna levert `Event.body` de letterlijke string
  /// `'Redacted'` op en is de tekst nergens meer terug te vinden uit het
  /// event zelf.
  ///
  /// Het bericht wordt onder twee id's bewaard:
  /// - het id van het originele event (dat gebruikt de weergave bij een
  ///   redaction, want `getDisplayEvent` geeft dan `this` terug);
  /// - het id van het weergegeven event, want bij een bewerking geeft
  ///   `getDisplayEvent` de edit-event terug en die heeft een ander id.
  void _cacheBody() {
    if (event.redacted) return;
    final body = event.text;
    if (body.isEmpty) return;

    final roomId = event.room.id;
    RedactedBodyCache.instance.store(redactedCacheKey(roomId, event.eventId), body);

    try {
      final displayEvent = event.getDisplayEvent(timeline);
      if (displayEvent.eventId != event.eventId) {
        RedactedBodyCache.instance.store(
          redactedCacheKey(roomId, displayEvent.eventId),
          body,
        );
      }
    } catch (_) {
      // Alleen een extra sleutel; het originele id is al bewaard.
    }
  }
}