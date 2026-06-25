import 'package:flutter/material.dart';

class DummyChatListItem extends StatefulWidget {
  final double opacity;
  final bool animate;

  const DummyChatListItem({
    required this.opacity,
    required this.animate,
    super.key,
  });

  @override
  State<DummyChatListItem> createState() => _DummyChatListItemState();
}

class _DummyChatListItemState extends State<DummyChatListItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.35, end: 0.65).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.onSurface;

    if (!widget.animate) {
      return _buildItem(baseColor.withAlpha((widget.opacity * 80).toInt()));
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final alpha = (_animation.value * widget.opacity * 160).toInt();
        return _buildItem(baseColor.withAlpha(alpha));
      },
    );
  }

  Widget _buildItem(Color shimmerColor) {
    final theme = Theme.of(context);
    final subtitleColor = shimmerColor.withAlpha((shimmerColor.alpha * 0.6).toInt());
    return Opacity(
      opacity: widget.opacity,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: shimmerColor,
          child: widget.animate
              ? SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: theme.colorScheme.onSurface.withAlpha(150),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  color: shimmerColor,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(width: 36),
            Container(
              height: 14,
              width: 14,
              decoration: BoxDecoration(
                color: subtitleColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 14,
              width: 14,
              decoration: BoxDecoration(
                color: subtitleColor,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ],
        ),
        subtitle: Container(
          decoration: BoxDecoration(
            color: subtitleColor,
            borderRadius: BorderRadius.circular(3),
          ),
          height: 12,
          margin: const EdgeInsets.only(right: 22),
        ),
      ),
    );
  }
}
