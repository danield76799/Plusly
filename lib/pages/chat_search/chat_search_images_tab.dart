import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/events/video_player.dart';
import 'package:Pulsly/pages/image_viewer/image_viewer.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_locals.dart';
import 'package:Pulsly/widgets/mxc_image.dart';

class ChatSearchImagesTab extends StatelessWidget {
  final Room room;
  final List<Event> events;
  final void Function() onStartSearch;
  final bool endReached;
  final bool isLoading;
  final DateTime? searchedUntil;

  const ChatSearchImagesTab({
    required this.room,
    required this.events,
    required this.onStartSearch,
    required this.endReached,
    required this.isLoading,
    required this.searchedUntil,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(AppConfig.borderRadius / 2);
    final theme = Theme.of(context);
    final l10n = L10n.of(context);

    if (events.isEmpty && !isLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_outlined, size: 64),
          const SizedBox(height: 8),
          Text(l10n.nothingFound),
        ],
      );
    }

    final eventsByMonth = <DateTime, List<Event>>{};
    for (final event in events) {
      final month = DateTime(
        event.originServerTs.year,
        event.originServerTs.month,
      );
      eventsByMonth[month] ??= [];
      eventsByMonth[month]!.add(event);
    }
    final eventsByMonthList = eventsByMonth.entries.toList();

    const padding = 8.0;

    final crossAxisCount = AppSettings.galleryColumns.value;
    final thumbnailSize = AppSettings.galleryThumbnailSize.value.toDouble();
    final useLazyLoading = AppSettings.galleryLazyLoading.value;

    return ListView.builder(
      itemCount: eventsByMonth.length + 1,
      itemBuilder: (context, i) {
        if (i == eventsByMonth.length) {
          if (isLoading) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              ),
            );
          }
          if (endReached) {
            return const SizedBox.shrink();
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  foregroundColor: theme.colorScheme.onSecondaryContainer,
                ),
                onPressed: onStartSearch,
                icon: const Icon(Icons.arrow_downward_outlined),
                label: Text(l10n.searchMore),
              ),
            ),
          );
        }

        final monthEvents = eventsByMonthList[i].value;
        final isLazyLoaded = useLazyLoading && i > 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Container(height: 1, color: theme.dividerColor),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    DateFormat.yMMMM(
                      Localizations.localeOf(context).languageCode,
                    ).format(eventsByMonthList[i].key),
                    style: theme.textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Container(height: 1, color: theme.dividerColor),
                ),
              ],
            ),
            GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              mainAxisSpacing: padding,
              crossAxisSpacing: padding,
              clipBehavior: Clip.hardEdge,
              padding: const EdgeInsets.all(padding),
              crossAxisCount: crossAxisCount,
              children: monthEvents.map((event) {
                if (event.messageType == MessageTypes.Video) {
                  return Material(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: borderRadius,
                    child: EventVideoPlayer(
                      event,
                      theme.colorScheme.onSurface,
                      theme.colorScheme.primary,
                    ),
                  );
                }
                return InkWell(
                  onTap: () => showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (_) =>
                        ImageViewer(event, outerContext: context),
                  ),
                  borderRadius: borderRadius,
                  child: Material(
                    clipBehavior: Clip.hardEdge,
                    borderRadius: borderRadius,
                    child: isLazyLoaded
                        ? _LazyMxcImage(
                            event: event,
                            width: thumbnailSize,
                            height: thumbnailSize,
                          )
                        : MxcImage(
                            event: event,
                            width: thumbnailSize,
                            height: thumbnailSize,
                            fit: BoxFit.cover,
                            animated: true,
                            isThumbnail: true,
                          ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

class _LazyMxcImage extends StatefulWidget {
  final Event event;
  final double width;
  final double height;

  const _LazyMxcImage({
    required this.event,
    required this.width,
    required this.height,
  });

  @override
  State<_LazyMxcImage> createState() => _LazyMxcImageState();
}

class _LazyMxcImageState extends State<_LazyMxcImage> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  void _checkVisibility() {
    if (!mounted || _isVisible) return;
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenHeight = WidgetsBinding.instance.window.physicalSize.height /
        WidgetsBinding.instance.window.devicePixelRatio;
    if (offset.dy < screenHeight * 2) {
      setState(() => _isVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppConfig.borderRadius / 2),
        ),
        child: const Center(
          child: Icon(Icons.image_outlined, color: Colors.grey),
        ),
      );
    }
    return MxcImage(
      event: widget.event,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      animated: true,
      isThumbnail: true,
    );
  }
}
