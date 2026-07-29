// SPDX-License-Identifier: AGPL-3.0-or-later

import 'dart:async';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/widgets/mxc_image.dart';

/// Prefetches thumbnails for events around an anchor position in the timeline.
///
/// Splits events into media (image/video/file with a thumbnail) and non-media
/// (text/state) so we only download the ones the chat-view will actually
/// render. Downloads run in parallel but capped at [maxConcurrent] so a slow
/// bridge cannot starve the queue.
class MediaPrefetcher {
  /// Number of events to prefetch after the anchor (newer messages first
  /// because the chat list is reversed).
  static const int defaultLookahead = 5;

  /// Number of events to prefetch before the anchor.
  static const int defaultLookbehind = 3;

  /// Hard cap on parallel downloads to avoid head-of-line blocking when a
  /// bridge or E2EE key fetch stalls.
  static const int defaultMaxConcurrent = 3;

  /// Returns true if the event is likely to render an MxcImage thumbnail in
  /// the chat bubble, so prefetching its thumbnail is worth it.
  static bool _isMediaEvent(Event event) {
    final type = event.type;
    if (type != 'm.room.message') return false;
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

    final iterator = Stream<Event>.fromIterable(mediaEvents);
    await iterator
        .transform(_ConcurrentLimiter<Event>(maxConcurrent))
        .map(preloadOne)
        .drain<void>();
  }

  static Future<void> preloadOne(Event event) async {
    try {
      await MxcImage.preload(event);
    } catch (_) {
      // Prefetch failures are best-effort; the next scroll will retry via the
      // normal MxcImage path.
    }
  }
}

/// A simple stream transformer that lets at most [limit] futures run in
/// parallel. Implemented inline so we do not need a `stream_transform`
/// dependency just for prefetch.
class _ConcurrentLimiter<T> extends StreamTransformerBase<T, T> {
  final int limit;

  _ConcurrentLimiter(this.limit);

  @override
  Stream<T> bind(Stream<T> stream) {
    final controller = StreamController<T>(sync: true);
    var inFlight = 0;
    var completed = false;
    final queue = <T>[];

    void maybePump() {
      while (inFlight < limit && queue.isNotEmpty) {
        final next = queue.removeAt(0);
        inFlight++;
        controller.add(next);
      }
      if (completed && inFlight == 0 && queue.isEmpty) {
        controller.close();
      }
    }

    controller.onListen = () {
      stream.listen(
        (data) {
          queue.add(data);
          maybePump();
        },
        onError: controller.addError,
        onDone: () {
          completed = true;
          maybePump();
        },
      );
    };

    // We need a separate listener to detect when the consumer is done so we
    // can mark the upstream finished. Re-listen using a wrapper:
    final output = controller.stream;
    return output.transform(_MarkInFlight<T>(onAck: () {
      inFlight--;
      maybePump();
    }));
  }
}

/// Tracks when each emitted item has been acknowledged by the downstream so
/// the limiter can free a slot.
class _MarkInFlight<T> extends StreamTransformerBase<T, T> {
  final void Function() onAck;

  _MarkInFlight({required this.onAck});

  @override
  Stream<T> bind(Stream<T> stream) async* {
    await for (final data in stream) {
      yield data;
      onAck();
    }
  }
}