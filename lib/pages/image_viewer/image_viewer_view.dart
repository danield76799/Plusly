import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/image_viewer/video_player.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/widgets/hover_builder.dart';
import 'package:Pulsly/widgets/mxc_image.dart';
import 'image_viewer.dart';

class ImageViewerView extends StatefulWidget {
  final ImageViewerController controller;

  const ImageViewerView(this.controller, {super.key});

  @override
  State<ImageViewerView> createState() => _ImageViewerViewState();
}

class _ImageViewerViewState extends State<ImageViewerView> {
  // PageView scroll is locked as soon as any pointer goes down inside an
  // InteractiveViewer item, and unlocked when the user is zoomed back out.
  // This stops horizontal swipes from stealing the pinch gesture.
  var _pageScrollLocked = false;

  void _lockScroll(bool locked) {
    if (_pageScrollLocked != locked) {
      setState(() {
        _pageScrollLocked = locked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconButtonStyle = IconButton.styleFrom(
      backgroundColor: Colors.black.withAlpha(200),
      foregroundColor: Colors.white,
    );
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withAlpha(128),
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
              onPressed: widget.controller.forwardAction,
              color: Colors.white,
              tooltip: L10n.of(context).share,
            ),
            const SizedBox(width: 8),
            IconButton(
              style: iconButtonStyle,
              icon: const Icon(Icons.download_outlined),
              onPressed: () => widget.controller.saveFileAction(context),
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
                    onPressed: () => widget.controller.shareFileAction(context),
                    tooltip: L10n.of(context).share,
                    color: Colors.white,
                    icon: Icon(Icons.adaptive.share_outlined),
                  ),
                ),
              ),
          ],
        ),
        body: HoverBuilder(
          builder: (context, hovered) => Stack(
            children: [
              KeyboardListener(
                focusNode: widget.controller.focusNode,
                onKeyEvent: widget.controller.onKeyEvent,
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: _pageScrollLocked
                      ? const NeverScrollableScrollPhysics()
                      : null,
                  controller: widget.controller.pageController,
                  itemCount: widget.controller.allEvents.length,
                  itemBuilder: (context, i) {
                    final event = widget.controller.allEvents[i];
                    switch (event.messageType) {
                      case MessageTypes.Video:
                        return Padding(
                          padding: const EdgeInsets.only(top: 52.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: EventVideoPlayer(event, widget.controller),
                            ),
                          ),
                        );
                      case MessageTypes.Image:
                      case MessageTypes.Sticker:
                      default:
                        return _ZoomableImage(
                          event: event,
                          controller: widget.controller,
                          onLockChanged: _lockScroll,
                        );
                    }
                  },
                ),
              ),
              if (hovered)
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.controller.canGoBack)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: IconButton(
                            style: iconButtonStyle,
                            tooltip: L10n.of(context).previous,
                            icon: const Icon(Icons.arrow_back_outlined),
                            onPressed: widget.controller.prevImage,
                          ),
                        ),
                      if (widget.controller.canGoNext)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: IconButton(
                            style: iconButtonStyle,
                            tooltip: L10n.of(context).next,
                            icon: const Icon(Icons.arrow_forward_outlined),
                            onPressed: widget.controller.nextImage,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  final Event event;
  final ImageViewerController controller;
  final ValueChanged<bool> onLockChanged;

  const _ZoomableImage({
    required this.event,
    required this.controller,
    required this.onLockChanged,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  final _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  bool get _isZoomed {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    return scale > 1.01;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return InteractiveViewer(
      transformationController: _transformationController,
      minScale: 1.0,
      maxScale: 10.0,
      boundaryMargin: EdgeInsets.zero,
      clipBehavior: Clip.none,
      // Lock the PageView as soon as the user touches the image. This makes
      // pinch-to-zoom reliable; if they weren't zooming, the lock is removed
      // on interaction end.
      onInteractionStart: (_) => widget.onLockChanged(true),
      onInteractionEnd: (details) {
        widget.controller.onInteractionEnds(details);
        widget.onLockChanged(_isZoomed);
      },
      child: Center(
        child: SizedBox.expand(
          child: Hero(
            tag: widget.event.eventId,
            child: GestureDetector(
              onTap: () {},
              child: MxcImage(
                key: ValueKey(widget.event.eventId),
                event: widget.event,
                width: size.width,
                height: size.height,
                fit: BoxFit.contain,
                isThumbnail: false,
                animated: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
