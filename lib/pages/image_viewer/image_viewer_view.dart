import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/image_viewer/video_player.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/widgets/mxc_image.dart';
import 'image_viewer.dart';

class ImageViewerView extends StatelessWidget {
  final ImageViewerController controller;

  const ImageViewerView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final iconButtonStyle = IconButton.styleFrom(
      backgroundColor: Colors.black.withAlpha(200),
      foregroundColor: Colors.white,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          style: iconButtonStyle,
          icon: const Icon(Icons.close),
          onPressed: Navigator.of(context).pop,
          color: Colors.white,
          tooltip: L10n.of(context).close,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            style: iconButtonStyle,
            icon: const Icon(Icons.reply_outlined),
            onPressed: controller.forwardAction,
            color: Colors.white,
            tooltip: L10n.of(context).share,
          ),
          const SizedBox(width: 8),
          IconButton(
            style: iconButtonStyle,
            icon: const Icon(Icons.download_outlined),
            onPressed: () => controller.saveFileAction(context),
            color: Colors.white,
            tooltip: L10n.of(context).downloadFile,
          ),
          const SizedBox(width: 8),
          if (PlatformInfos.isMobile)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Builder(
                builder: (context) => IconButton(
                  style: iconButtonStyle,
                  onPressed: () => controller.shareFileAction(context),
                  tooltip: L10n.of(context).share,
                  color: Colors.white,
                  icon: Icon(Icons.adaptive.share_outlined),
                ),
              ),
            ),
        ],
      ),
      body: _PagedZoomableImages(controller: controller),
    );
  }
}

class _PagedZoomableImages extends StatefulWidget {
  final ImageViewerController controller;

  const _PagedZoomableImages({required this.controller});

  @override
  State<_PagedZoomableImages> createState() => _PagedZoomableImagesState();
}

class _PagedZoomableImagesState extends State<_PagedZoomableImages> {
  // Track active pointers. When 2+ are down (pinch), lock the PageView.
  final ValueNotifier<bool> _scrollLocked = ValueNotifier<bool>(false);
  int _activePointers = 0;

  void _onPointerDown(PointerDownEvent _) {
    _activePointers++;
    if (_activePointers >= 2) {
      _scrollLocked.value = true;
    }
  }

  void _onPointerUp(PointerUpEvent _) {
    _activePointers = (_activePointers - 1).clamp(0, 999);
    if (_activePointers < 2) {
      _scrollLocked.value = false;
    }
  }

  @override
  void dispose() {
    _scrollLocked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: (_) => _onPointerUp,
      child: ValueListenableBuilder<bool>(
        valueListenable: _scrollLocked,
        builder: (context, locked, _) => PageView.builder(
          scrollDirection: Axis.horizontal,
          physics: locked
              ? const NeverScrollableScrollPhysics()
              : const BouncingScrollPhysics(),
          controller: widget.controller.pageController,
          itemCount: widget.controller.allEvents.length,
          itemBuilder: (context, i) {
            final event = widget.controller.allEvents[i];
            switch (event.messageType) {
              case MessageTypes.Video:
                return Padding(
                  padding: const EdgeInsets.only(top: 52.0),
                  child: Center(
                    child: EventVideoPlayer(event, widget.controller),
                  ),
                );
              case MessageTypes.Image:
              case MessageTypes.Sticker:
              default:
                return InteractiveViewer(
                  minScale: 1.0,
                  maxScale: 10.0,
                  child: Center(
                    child: MxcImage(
                      key: ValueKey(event.eventId),
                      event: event,
                      fit: BoxFit.contain,
                      isThumbnail: false,
                      animated: true,
                    ),
                  ),
                );
            }
          },
        ),
      ),
    );
  }
}