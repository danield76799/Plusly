import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Widget that measures its child's size and reports changes.
/// Uses a notification instead of ValueListenableBuilder to avoid
/// rebuilding the entire sliver list.
class SizeChangeNotifier extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const SizeChangeNotifier({
    required this.onChange,
    required super.child,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _SizeChangeNotifierRenderObject(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    _SizeChangeNotifierRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _SizeChangeNotifierRenderObject extends RenderProxyBox {
  ValueChanged<Size> onChange;
  Size? _oldSize;

  _SizeChangeNotifierRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    final newSize = size;
    if (newSize != _oldSize) {
      _oldSize = newSize;
      // Defer the callback to avoid mutating state during layout.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onChange(newSize);
      });
    }
  }
}

/// Optimized ChatEventList bottom spacer that doesn't rebuild the entire list
/// when input bar height changes.
class InputBarSpacer extends StatelessWidget {
  final ValueNotifier<double> heightNotifier;

  const InputBarSpacer({
    required this.heightNotifier,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Use AnimatedBuilder which is more efficient than ValueListenableBuilder
    // for size-only changes
    return AnimatedBuilder(
      animation: heightNotifier,
      builder: (context, child) {
        return SizedBox(height: heightNotifier.value + 8);
      },
    );
  }
}
