import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_file_extension.dart';
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
      body: _RawZoomableImage(event: controller.currentEvent),
    );
  }
}

class _RawZoomableImage extends StatefulWidget {
  final Event event;

  const _RawZoomableImage({required this.event});

  @override
  State<_RawZoomableImage> createState() => _RawZoomableImageState();
}

class _RawZoomableImageState extends State<_RawZoomableImage> {
  Uint8List? _bytes;
  bool _loading = true;

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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      );
    }
    if (_bytes == null || _bytes!.isEmpty) {
      return const Center(
        child: Icon(Icons.broken_image_outlined, size: 64, color: Colors.white54),
      );
    }
    // BARE MINIMUM: InteractiveViewer + Image.memory. Nothing else.
    return InteractiveViewer(
      minScale: 1.0,
      maxScale: 10.0,
      child: Image.memory(
        _bytes!,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      ),
    );
  }
}