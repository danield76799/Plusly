// SPDX-License-Identifier: AGPL-3.0-or-later

import 'package:matrix/matrix.dart';

import 'package:Pulsly/widgets/mxc_image.dart';

/// Prefetches thumbnails for events around an anchor position in the timeline.
///
/// Splits events into media (image/video/sticker with a thumbnail) and
/// non-media so we only download the ones the chat-view will actually render.
/// Downloads run in parallel chunks capped at [maxConcurrent] so a slow bridge
/// cannot starve the queue.
class MediaPrefetcher {
  static const int defaultLookahead = 5;
  static const int defaultLookbehind = 3;
  static const int defaultMaxConcurrent = 3;

  static bool _isMediaEvent(Event event) {
    if (event.type != 'm.room.message') return false;
    final msgType = event.messageType;
    return msgType == MessageTypes.Image ||
        msgType == MessageTypes.Video ||
        msgType == MessageTypes.Sticker;
  }

  /// Prefetches thumbnails of the [lookahead] events after [anchorIndex] and
  /// the [lookbehind] events before it. Safe to call repeatedly: already
  /// cached events are skipped inside [MxcImage.preload].
  static Future<void> prefetchAround(
    List<Event> events,
    int anchorIndex, {
    int lookahead = defaultLookahead,
    int lookbehind = defaultLookbehind,
    int maxConcurrent = defaultMaxConcurrent,
  }) async {
    if (events.isEmpty || anchorIndex < 0 || anchorIndex >= events.length) {
      return;
    }
    final from = (anchorIndex - lookbehind).clamp(0, events.length);
    final to = (anchorIndex + lookahead + 1).clamp(0, events.length);

    final mediaEvents = <Event>[];
    for (var i = from; i < to; i++) {
      if (i == anchorIndex) continue;
      final ev = events[i];
      if (_isMediaEvent(ev)) mediaEvents.add(ev);
    }
    if (mediaEvents.isEmpty) return;

    // Simple chunked parallelism: process maxConcurrent at a time.
    for (var i = 0; i < mediaEvents.length; i += maxConcurrent) {
      final chunk = mediaEvents.skip(i).take(maxConcurrent);
      await Future.wait(chunk.map(preloadOne));
    }
  }

  static Future<void> preloadOne(Event event) async {
    try {
      await MxcImage.preload(event);
    } catch (_) {
      // Prefetch failures are best-effort.
    }
  }
}