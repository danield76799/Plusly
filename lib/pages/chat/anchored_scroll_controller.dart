import 'package:flutter/widgets.dart';

import 'package:scroll_to_index/scroll_to_index.dart';

class AnchoredScrollPosition extends ScrollPositionWithSingleContext {
  bool shouldAnchor = false;

  AnchoredScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
  });

  @override
  bool correctForNewDimensions(
    ScrollMetrics oldPosition,
    ScrollMetrics newPosition,
  ) {
    if (shouldAnchor) {
      final delta = newPosition.maxScrollExtent - oldPosition.maxScrollExtent;
      if (delta > 0) {
        correctPixels(pixels + delta);
        shouldAnchor = false;
        return false;
      }
    }
    return super.correctForNewDimensions(oldPosition, newPosition);
  }
}

class AnchoredAutoScrollController extends SimpleAutoScrollController {
  AnchoredAutoScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.suggestedRowHeight,
    super.viewportBoundaryGetter,
    super.beginGetter = _defaultBeginGetter,
    super.endGetter = _defaultEndGetter,
    super.copyTagsFrom,
    super.debugLabel,
  });

  static double _defaultBeginGetter(Rect r) => r.top;
  static double _defaultEndGetter(Rect r) => r.bottom;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return AnchoredScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }

  bool get shouldAnchor {
    if (hasClients && position is AnchoredScrollPosition) {
      return (position as AnchoredScrollPosition).shouldAnchor;
    }
    return false;
  }

  set shouldAnchor(bool value) {
    if (hasClients && position is AnchoredScrollPosition) {
      (position as AnchoredScrollPosition).shouldAnchor = value;
    }
  }
}
