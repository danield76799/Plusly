import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/events/audio_player.dart';
import 'package:Pulsly/pages/chat/events/html_message.dart';
import 'package:Pulsly/pages/chat/events/message_download_content.dart';
import 'package:Pulsly/pages/chat/events/redacted_content.dart';
import 'package:Pulsly/pages/image_viewer/image_viewer.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/event_extension.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/size_string.dart';
import 'package:Pulsly/utils/url_launcher.dart';
import 'package:Pulsly/widgets/blur_hash.dart';
import 'package:Pulsly/widgets/mxc_image.dart';

/// Toont een MSC4274-galerijbericht (`dm.filament.gallery`): één bericht
/// met meerdere media (foto's, video's, audio, bestanden) en één bijschrift.
///
/// De media staan in een raster; audio en bestanden eronder als rij.
class GalleryContent extends StatelessWidget {
  final Event event;
  final Color textColor;
  final Color linkColor;
  final Timeline timeline;
  final bool selectable;
  final bool loadMedia;
  final void Function()? onLoadMedia;

  static const double gridTileSize = 176;
  static const double gridSpacing = 2;

  const GalleryContent(
    this.event, {
    required this.timeline,
    required this.textColor,
    required this.linkColor,
    this.selectable = false,
    this.loadMedia = false,
    this.onLoadMedia,
    super.key,
  });

  /// Aantal kolommen van het raster voor [tileCount] tegels. Eén tegel
  /// krijgt één (volle) kolom, zodat de bubbel niet leeg blijft aan de zijkanten.
  static int gridColumnCount(int tileCount) => tileCount == 1 ? 1 : 2;

  /// Breedte van het raster (en dus van de galerijbubbel).
  static double gridWidth(int columnCount) {
    final available = FluffyThemes.columnWidth * 1.5;
    final width = gridTileSize * columnCount + gridSpacing * (columnCount - 1);
    return width.clamp(gridTileSize, available);
  }

  Map<String, dynamic> _itemInfo(Map<String, dynamic> item) =>
      item.tryGetMap<String, dynamic>('info') ?? <String, dynamic>{};

  /// Placeholder zolang de media niet geladen is.
  Widget _buildTilePlaceholder(
    BuildContext context,
    Event itemEvent, {
    String? blurhash,
    VoidCallback? onPressed,
    IconData icon = Icons.image,
    String tooltip = '',
  }) {
    final label = tooltip.isEmpty
        ? ''
        : (itemEvent.content
                  .tryGetMap<String, dynamic>('info')
                  ?.tryGet<num>('size'))
              ?.sizeString;
    return Stack(
      alignment: Alignment.center,
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: BlurHash(
            blurhash: blurhash,
            width: double.infinity,
            height: gridTileSize,
          ),
        ),
        if (onPressed != null)
          Positioned.fill(
            child: Center(
              child: label == null || label.isEmpty
                  ? IconButton.filledTonal(
                      onPressed: onPressed,
                      icon: Icon(icon),
                      tooltip: tooltip,
                    )
                  : FilledButton.tonal(
                      onPressed: onPressed,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: Row(
                        mainAxisSize: .min,
                        spacing: 8,
                        children: [Icon(icon, size: 20), Text(label)],
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  /// Bouwt een tegel voor een `m.image` of `m.video`-item.
  Widget _buildMediaTile(BuildContext context, Event itemEvent) {
    final isVideo = itemEvent.messageType == MessageTypes.Video;
    final info = _itemInfo(itemEvent.content);
    final blurhash = info.tryGet<String>('xyz.amorgan.blurhash');
    // Video's zonder thumbnail kunnen niet als afbeelding getekend worden
    // zonder het hele bestand op te halen.
    final canRenderImage =
        itemEvent.hasAttachment && (!isVideo || itemEvent.hasThumbnail);

    final Widget tile;
    if (canRenderImage && loadMedia) {
      tile = MxcImage(
        event: itemEvent,
        fit: BoxFit.cover,
        isThumbnail: true,
        placeholder: (context) => BlurHash(
          blurhash: blurhash,
          width: gridTileSize,
          height: gridTileSize,
        ),
      );
    } else {
      tile = _buildTilePlaceholder(
        context,
        itemEvent,
        blurhash: blurhash,
        onPressed: loadMedia ? null : onLoadMedia,
        icon: isVideo ? Icons.video_library : Icons.image,
        tooltip: isVideo
            ? L10n.of(context).downloadVideoNoSize
            : L10n.of(context).loadImageNoSize,
      );
    }
    return InkWell(
      onTap: () {
        if (!loadMedia) {
          onLoadMedia?.call();
          return;
        }
        showDialog(
          context: context,
          useRootNavigator: false,
          builder: (_) =>
              ImageViewer(itemEvent, timeline: timeline, outerContext: context),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: tile),
          if (isVideo && loadMedia && canRenderImage)
            Icon(
              Icons.play_circle_outline,
              size: 48,
              color: Colors.white.withAlpha(200),
            ),
        ],
      ),
    );
  }

  /// Bouwt de bijschrift, gestyled als een normaal tekstbericht.
  Widget _buildCaption(BuildContext context, double fontSize) {
    final body = event.body;
    if (body.isEmpty) return const SizedBox.shrink();
    final formattedHtml =
        AppSettings.renderHtml.value &&
            event.content.tryGet<String>('format') == 'org.matrix.custom.html'
        ? event.content.tryGet<String>('formatted_body')
        : null;
    if (formattedHtml != null) {
      return HtmlMessage(
        html: formattedHtml,
        textColor: textColor,
        room: event.room,
        selectable: selectable,
        fontSize: fontSize,
        linkStyle: TextStyle(color: linkColor, fontSize: fontSize),
        onOpen: (url) => UrlLauncher(context, url.url).launchUrl(),
        onCopy: () {
          Clipboard.setData(ClipboardData(text: event.body));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(L10n.of(context).copiedToClipboard)),
          );
        },
      );
    }
    final richSpan = TextSpan(
      style: TextStyle(color: textColor, fontSize: fontSize),
      children: [TextSpan(text: body)],
    );
    return selectable
        ? SelectableText.rich(richSpan)
        : Text.rich(richSpan);
  }

  /// Hoekradius van het raster: afgeleid van de bubbelvorm.
  BorderRadius _gridBorderRadius() {
    final hardCorner = Radius.circular(2);
    final roundedCorner = Radius.circular(AppConfig.borderRadius - 2);

    var borderRadius = BorderRadius.all(roundedCorner);
    final hasCaption = event.body.isNotEmpty;
    if (hasCaption) {
      borderRadius = borderRadius.copyWith(
        bottomLeft: hardCorner,
        bottomRight: hardCorner,
      );
    }
    return borderRadius;
  }

  @override
  Widget build(BuildContext context) {
    // De app-schaal zit al op de MediaQuery; niet nog eens vermenigvuldigen.
    final fontSize = AppSettings.messageFontSize.value;

    if (event.redacted) {
      return EventRedactedContent(
        event: event,
        textColor: textColor,
        fontSize: fontSize,
      );
    }

    final items = galleryItems(event);
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Text(
          event.body,
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
      );
    }

    final gridTiles = <Widget>[];
    final rows = <Widget>[];
    var index = 0;
    for (final item in items) {
      final itemEvent = galleryItemEvent(event, item, index);
      index++;
      final msgType = itemEvent.messageType;
      if (msgType == MessageTypes.Image ||
          (msgType == MessageTypes.Video &&
              PlatformInfos.supportsVideoPlayer)) {
        gridTiles.add(_buildMediaTile(context, itemEvent));
        continue;
      }
      if (msgType == MessageTypes.Audio &&
          (PlatformInfos.isMobile ||
              PlatformInfos.isMacOS ||
              PlatformInfos.isWeb ||
              PlatformInfos.isLinux)) {
        rows.add(
          AudioPlayerWidget(
            itemEvent,
            color: textColor,
            linkColor: linkColor,
            fontSize: fontSize,
          ),
        );
        continue;
      }
      rows.add(
        MessageDownloadContent(
          itemEvent,
          textColor: textColor,
          linkColor: linkColor,
        ),
      );
    }

    final columnCount = gridColumnCount(gridTiles.length);
    final width = gridWidth(columnCount);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (gridTiles.isNotEmpty)
          Padding(
            padding: const .all(2),
            child: Container(
              decoration: BoxDecoration(borderRadius: _gridBorderRadius()),
              clipBehavior: Clip.antiAlias,
              width: width,
              child: _GridLayout(
                tiles: gridTiles,
                tileSize: gridTileSize,
                columns: columnCount,
                spacing: gridSpacing,
              ),
            ),
          ),
        if (rows.isNotEmpty) ...rows,
        if (event.body.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _buildCaption(context, fontSize),
          ),
      ],
    );
  }
}

/// Legt de galerijtegels in rijen van [columns]. Een eenzame tegel in de
/// laatste rij loopt door over de resterende cellen.
class _GridLayout extends StatelessWidget {
  final List<Widget> tiles;
  final double tileSize;
  final int columns;
  final double spacing;

  const _GridLayout({
    required this.tiles,
    required this.tileSize,
    this.columns = 2,
    this.spacing = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (var i = 0; i < tiles.length; i++)
          Builder(
            builder: (context) {
              final remainder = tiles.length % columns;
              final lastRowCount = remainder == 0 ? columns : remainder;
              final isLastLone =
                  lastRowCount < columns && i >= tiles.length - lastRowCount;
              final width = isLastLone
                  ? tileSize * columns + spacing * (columns - 1)
                  : tileSize;
              return SizedBox(width: width, height: tileSize, child: tiles[i]);
            },
          ),
      ],
    );
  }
}
