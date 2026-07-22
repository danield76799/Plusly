import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/events/html_message.dart';
import 'package:Pulsly/pages/image_viewer/image_viewer.dart';
import 'package:Pulsly/utils/size_string.dart';
import 'package:Pulsly/utils/url_launcher.dart';
import 'package:Pulsly/widgets/mxc_image.dart';

class ImageBubble extends StatelessWidget {
  final Event event;
  final bool tapToView;
  final BoxFit fit;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? linkColor;
  final bool thumbnailOnly;
  final bool animated;
  final double width;
  final double? imageWidth;
  final double height;
  final void Function()? onTap;
  final BorderRadius? borderRadius;
  final Timeline? timeline;

  final bool loadMedia;
  final void Function()? onLoadMedia;

  const ImageBubble(
    this.event, {
    this.tapToView = true,
    this.backgroundColor,
    this.fit = BoxFit.contain,
    this.thumbnailOnly = true,
    this.width = 400,
    this.imageWidth,
    this.height = 300,
    this.animated = false,
    this.onTap,
    this.borderRadius,
    this.timeline,
    this.textColor,
    this.linkColor,
    this.loadMedia = false,
    this.onLoadMedia,
    super.key,
  });

  double get _effectiveImageWidth => imageWidth ?? width;

  double get _aspectRatio {
    // Get image dimensions from event metadata
    final infoMap = event.infoMap;
    final imageWidth = infoMap['w'] as int?;
    final imageHeight = infoMap['h'] as int?;

    if (imageWidth != null &&
        imageHeight != null &&
        imageWidth > 0 &&
        imageHeight > 0) {
      // Return aspect ratio (width / height)
      return imageWidth / imageHeight;
    }

    // Fallback to square aspect ratio if metadata is not available
    return 1.0;
  }

  Widget _buildPlaceholder(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildUnloaded(BuildContext context) {
    final size = event.infoMap['size'] is num
        ? event.infoMap['size'] as num
        : null;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            Center(
              child: ElevatedButton(
                onPressed: onLoadMedia,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.image),
                    const SizedBox(width: 12),
                    Text(
                      size != null
                          ? L10n.of(context).loadImage(size.sizeString)
                          : L10n.of(context).loadImageNoSize,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _onTap(BuildContext context) {
    if (!loadMedia) return;
    if (onTap != null) {
      onTap!();
      return;
    }
    if (!tapToView) return;

    // Push a full-screen page (FluffyChat-style) instead of a dialog so the
    // image viewer owns the whole screen and InteractiveViewer can work without
    // layout/focus fights.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageViewer(
          event,
          timeline: timeline,
          outerContext: context,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var borderRadius =
        this.borderRadius ?? BorderRadius.circular(AppConfig.borderRadius);

    final fileDescription = event.fileDescription;
    final textColor = this.textColor;

    if (fileDescription != null) {
      borderRadius = borderRadius.copyWith(
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero,
      );
    }

    if (event.inReplyToEventId(includingFallback: false) != null &&
        fileDescription != null) {
      borderRadius = borderRadius.copyWith(
        topLeft: Radius.zero,
        topRight: Radius.zero,
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: width),
          child: AspectRatio(
            aspectRatio: _aspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: borderRadius,
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _onTap(context),
                      child: Hero(
                        tag: event.eventId,
                        child: loadMedia
                            ? MxcImage(
                                event: event,
                                width: _effectiveImageWidth,
                                fit: fit,
                                animated: animated,
                                isThumbnail: thumbnailOnly,
                                cacheKey:
                                    '${event.eventId}_thumb_${_effectiveImageWidth.toInt()}',
                                placeholder: event.messageType == MessageTypes.Sticker
                                    ? null
                                    : _buildPlaceholder,
                              )
                            : _buildUnloaded(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (fileDescription != null &&
            textColor != null &&
            !event.isRichFileDescription)
          SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Linkify(
                text: fileDescription,
                textScaleFactor: MediaQuery.textScalerOf(context).scale(1),
                style: TextStyle(
                  color: textColor,
                  fontSize:
                      AppSettings.fontSizeFactor.value *
                      AppSettings.messageFontSize.value,
                ),
                options: const LinkifyOptions(humanize: false),
                linkStyle: TextStyle(
                  color: linkColor,
                  fontSize:
                      AppSettings.fontSizeFactor.value *
                      AppSettings.messageFontSize.value,
                  decoration: TextDecoration.underline,
                  decorationColor: linkColor,
                ),
                onOpen: (url) => UrlLauncher(context, url.url).launchUrl(),
              ),
            ),
          ),
        if (fileDescription != null &&
            textColor != null &&
            event.isRichFileDescription)
          SizedBox(
            width: width,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: HtmlMessage(
                html: fileDescription,
                textColor: textColor,
                room: event.room,
                fontSize:
                    AppSettings.fontSizeFactor.value *
                    AppSettings.messageFontSize.value,
                linkStyle: TextStyle(
                  color: linkColor,
                  fontSize:
                      AppSettings.fontSizeFactor.value *
                      AppSettings.messageFontSize.value,
                  decoration: TextDecoration.underline,
                  decorationColor: linkColor,
                ),
                onOpen: (url) => UrlLauncher(context, url.url).launchUrl(),
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: event.body));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(L10n.of(context).copiedToClipboard)),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
