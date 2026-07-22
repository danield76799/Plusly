import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/image_viewer/video_player.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_file_extension.dart';
import 'package:Pulsly/widgets/hover_builder.dart';
import 'package:Pulsly/widgets/matrix.dart';
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
        body: HoverBuilder(
          builder: (context, hovered) => Stack(
            children: [
              KeyboardListener(
                focusNode: controller.focusNode,
                onKeyEvent: controller.onKeyEvent,
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  controller: controller.pageController,
                  itemCount: controller.allEvents.length,
                  itemBuilder: (context, i) {
                    final event = controller.allEvents[i];
                    switch (event.messageType) {
                      case MessageTypes.Video:
                        return Padding(
                          padding: const EdgeInsets.only(top: 52.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {},
                              child: EventVideoPlayer(event, controller),
                            ),
                          ),
                        );
                      case MessageTypes.Image:
                      case MessageTypes.Sticker:
                      default:
                        return _RawZoomableImage(event: event);
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
                      if (controller.canGoBack)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: IconButton(
                            style: iconButtonStyle,
                            tooltip: L10n.of(context).previous,
                            icon: const Icon(Icons.arrow_back_outlined),
                            onPressed: controller.prevImage,
                          ),
                        ),
                      if (controller.canGoNext)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: IconButton(
                            style: iconButtonStyle,
                            tooltip: L10n.of(context).next,
                            icon: const Icon(Icons.arrow_forward_outlined),
                            onPressed: controller.nextImage,
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

/// Loads the image bytes directly via downloadAndDecryptAttachment and renders
/// them in a plain Image.memory inside InteractiveViewer. Bypasses MxcImage
/// entirely to test whether MxcImage's RepaintBoundary/ClipRRect/cache logic
/// is interfering with pinch-to-zoom.
class _RawZoomableImage extends StatefulWidget {
  final Event event;

  const _RawZoomableImage({required this.event});

  @override
  State<_RawZoomableImage> createState() => _RawZoomableImageState();
}

class _RawZoomableImageState extends State<_RawZoomableImage> {
  Uint8List? _bytes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.event.downloadAndDecryptAttachment(
        getThumbnail: false,
      );
      if (mounted) {
        setState(() {
          _bytes = data.bytes;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      );
    }
    if (_error != null || _bytes == null || _bytes!.isEmpty) {
      return const Center(
        child: Icon(Icons.broken_image_outlined, size: 64, color: Colors.white54),
      );
    }
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 10.0,
      child: Center(
        child: GestureDetector(
          onTap: () {},
          child: Image.memory(
            _bytes!,
            fit: BoxFit.contain,
            gaplessPlayback: true,
            errorBuilder: (context, e, s) => const Center(
              child: Icon(Icons.broken_image_outlined, size: 64, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}