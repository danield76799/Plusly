import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/utils/matrix_sdk_extensions/favourite_stickers_extension.dart';
import 'package:extera_next/utils/matrix_sdk_extensions/recent_stickers_extension.dart';
import 'package:extera_next/widgets/mxc_image.dart';
import '../../widgets/avatar.dart';

// import 'package:extera_next/utils/url_launcher.dart';

class StickerPickerDialog extends StatefulWidget {
  final Room room;
  final void Function(ImagePackImageContent) onSelected;

  const StickerPickerDialog({
    required this.onSelected,
    required this.room,
    super.key,
  });

  @override
  StickerPickerDialogState createState() => StickerPickerDialogState();
}

class StickerPickerDialogState extends State<StickerPickerDialog> {
  String? searchFilter;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _favouriteKey = GlobalKey();
  final GlobalKey _recentKey = GlobalKey();
  final Map<String, GlobalKey> _packKeys = {};
  String? _activePackId;

  Map<String, ImagePackContent> stickerPacks = {};
  List<ImagePackImageContent> recentStickers = [];
  List<ImagePackImageContent> favouriteStickers = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    final client = widget.room.client;
    stickerPacks = widget.room.getImagePacks(.sticker);

    recentStickers = client.recentStickers;
    favouriteStickers = client.favouriteStickers;
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    String? newActiveId;
    double closestDistance = double.infinity;

    // Helper to check a key and id
    void checkKey(GlobalKey key, String id) {
      final ctx = key.currentContext;
      if (ctx == null) return;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final position = box.localToGlobal(Offset.zero);
      // Consider the section "active" if its top is at or above ~120px from top
      // (accounting for app bar + tab bar height)
      final topOffset = position.dy;
      if (topOffset <= 180 && topOffset > -box.size.height) {
        final distance = (topOffset - 120).abs();
        if (distance < closestDistance) {
          closestDistance = distance;
          newActiveId = id;
        }
      }
    }

    checkKey(_favouriteKey, '_favourite');
    checkKey(_recentKey, '_recent');
    for (final entry in _packKeys.entries) {
      checkKey(entry.value, entry.key);
    }

    if (newActiveId != _activePackId) {
      setState(() {
        _activePackId = newActiveId;
      });
    }
  }

  void _onStickerSelected(ImagePackImageContent sticker) {
    widget.room.client.addRecentSticker(sticker);
    widget.onSelected(sticker);
  }

  void _scrollToKey(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  void _showStickerInfoDialog({
    required ImagePackImageContent sticker,
    String? packName,
    String? packAttribution,
    bool isFromRecents = false,
  }) {
    final client = widget.room.client;
    showDialog(
      context: context,
      useRootNavigator: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            var isFavourite = client.isFavouriteSticker(sticker);
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MxcImage(
                    uri: sticker.url,
                    isThumbnail: false,
                    width: 384,
                    fit: BoxFit.contain,
                    animated: true,
                  ),
                  const SizedBox(height: 16),
                  if (sticker.body != null && sticker.body!.isNotEmpty)
                    Text(
                      sticker.body!,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  if (packName != null && packName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      packName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (packAttribution != null &&
                      packAttribution.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      packAttribution,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],

                  Material(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.send_outlined),
                          title: Text(L10n.of(context).sendSticker),
                          onTap: () async {
                            _onStickerSelected(sticker);
                            setDialogState(() {});
                            setState(() {});
                            if (mounted) {
                              Navigator.of(context, rootNavigator: false).pop();
                            }
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            isFavourite ? Icons.star : Icons.star_border,
                          ),
                          title: Text(
                            isFavourite
                                ? L10n.of(context).removeFromFavourites
                                : L10n.of(context).addToFavourites,
                          ),
                          onTap: () async {
                            if (isFavourite) {
                              await client.removeFavouriteSticker(sticker);
                            } else {
                              await client.addFavouriteSticker(sticker);
                            }
                            setDialogState(() {});
                            setState(() {
                              isFavourite = !isFavourite;
                            });
                          },
                        ),
                        if (isFromRecents)
                          ListTile(
                            iconColor: Theme.of(context).colorScheme.error,
                            leading: const Icon(Icons.delete_outline),
                            title: Text(
                              L10n.of(context).removeFromRecents,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            onTap: () async {
                              await client.removeRecentSticker(sticker);
                              setState(() {});
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStickerGrid(
    List<ImagePackImageContent> stickers, {
    bool isFromRecents = false,
  }) {
    return GridView.builder(
      itemCount: stickers.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 84,
        mainAxisSpacing: 8.0,
        crossAxisSpacing: 8.0,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final image = stickers[index];
        return Tooltip(
          message: image.body ?? '',
          child: InkWell(
            radius: AppConfig.borderRadius,
            key: ValueKey(image.url.toString()),
            onTap: () {
              final imageCopy = ImagePackImageContent.fromJson(
                image.toJson().copy(),
              );
              _onStickerSelected(imageCopy);
            },
            onLongPress: () {
              _showStickerInfoDialog(
                sticker: image,
                isFromRecents: isFromRecents,
              );
            },
            child: AbsorbPointer(
              absorbing: true,
              child: MxcImage(
                uri: image.url,
                fit: BoxFit.contain,
                width: 128,
                height: 128,
                animated: true,
                isThumbnail: false,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPackWidget({
    required ImagePackContent pack,
    required String slug,
    required bool hasRecentStickers,
    required bool isFirst,
  }) {
    final filteredImagePackImageEntried = pack.images.entries.toList();
    if (searchFilter?.isNotEmpty ?? false) {
      filteredImagePackImageEntried.removeWhere(
        (e) =>
            !(e.key.toLowerCase().contains(searchFilter!.toLowerCase()) ||
                (e.value.body?.toLowerCase().contains(
                      searchFilter!.toLowerCase(),
                    ) ??
                    false)),
      );
    }
    final imageKeys = filteredImagePackImageEntried.map((e) => e.key).toList();
    if (imageKeys.isEmpty) {
      return const SizedBox.shrink();
    }
    final packName = pack.pack.displayName ?? slug;
    return Container(
      key: _packKeys[slug],
      child: Column(
        children: <Widget>[
          if (!isFirst || hasRecentStickers) const SizedBox(height: 20),
          if (packName != 'user')
            ListTile(
              leading: Avatar(
                mxContent: pack.pack.avatarUrl,
                name: packName,
                client: widget.room.client,
              ),
              title: Text(packName),
            ),
          const SizedBox(height: 6),
          GridView.builder(
            itemCount: imageKeys.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 84,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int imageIndex) {
              final image = pack.images[imageKeys[imageIndex]]!;
              return Tooltip(
                message: image.body ?? imageKeys[imageIndex],
                child: InkWell(
                  radius: AppConfig.borderRadius,
                  key: ValueKey(image.url.toString()),
                  onTap: () {
                    final imageCopy = ImagePackImageContent.fromJson(
                      image.toJson().copy(),
                    );
                    imageCopy.body ??= imageKeys[imageIndex];
                    _onStickerSelected(imageCopy);
                  },
                  onLongPress: () {
                    final stickerCopy = ImagePackImageContent.fromJson(
                      image.toJson().copy(),
                    );
                    stickerCopy.body ??= imageKeys[imageIndex];
                    _showStickerInfoDialog(
                      sticker: stickerCopy,
                      packName: pack.pack.displayName ?? slug,
                      packAttribution: pack.pack.attribution,
                    );
                  },
                  child: AbsorbPointer(
                    absorbing: true,
                    child: MxcImage(
                      uri: image.url,
                      fit: BoxFit.contain,
                      width: 128,
                      height: 128,
                      animated: true,
                      isThumbnail: false,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final packSlugs = stickerPacks.keys.toList();

    final hasRecentStickers =
        recentStickers.isNotEmpty && !(searchFilter?.isNotEmpty ?? false);

    final hasFavouriteStickers =
        favouriteStickers.isNotEmpty && !(searchFilter?.isNotEmpty ?? false);

    // Ensure pack keys exist for all slugs
    for (final slug in packSlugs) {
      _packKeys.putIfAbsent(slug, () => GlobalKey());
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerHigh,
      body: SizedBox(
        width: double.maxFinite,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              floating: true,
              pinned: true,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: theme.colorScheme.surfaceContainerHigh,
              title: SizedBox(
                height: 40,
                child: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    filled: true,
                    hintText: L10n.of(context).search,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (s) => setState(() => searchFilter = s),
                ),
              ),
            ),
            // Sticky horizontal pack selector
            SliverPersistentHeader(
              pinned: true,
              delegate: _PackTabBarDelegate(
                child: Container(
                  color: theme.colorScheme.surfaceContainerHigh,
                  height: 57,
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const SizedBox(width: 4),
                              if (hasFavouriteStickers)
                                _PackTabItem(
                                  onTap: () => _scrollToKey(_favouriteKey),
                                  isActive: _activePackId == '_favourite',
                                  child: const Icon(Icons.star, size: 28),
                                ),
                              if (hasRecentStickers)
                                _PackTabItem(
                                  onTap: () => _scrollToKey(_recentKey),
                                  isActive: _activePackId == '_recent',
                                  child: const Icon(Icons.history, size: 28),
                                ),
                              for (final slug in packSlugs)
                                Builder(
                                  builder: (context) {
                                    final pack = stickerPacks[slug]!;
                                    final firstImage =
                                        pack.images.values.isNotEmpty
                                        ? pack.images.values.first
                                        : null;
                                    return _PackTabItem(
                                      onTap: () =>
                                          _scrollToKey(_packKeys[slug]!),
                                      isActive: _activePackId == slug,
                                      child: firstImage != null
                                          ? MxcImage(
                                              uri: firstImage.url,
                                              width: 36,
                                              height: 36,
                                              fit: BoxFit.contain,
                                              isThumbnail: true,
                                            )
                                          : const Icon(Icons.image, size: 28),
                                    );
                                  },
                                ),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1, thickness: 1),
                    ],
                  ),
                ),
              ),
            ),
            if (hasFavouriteStickers)
              SliverToBoxAdapter(
                child: Container(
                  key: _favouriteKey,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons. /*WE ARE*/ star /* T RAIN*/),
                        title: Text(L10n.of(context).favouriteStickers),
                      ),
                      const SizedBox(height: 6),
                      _buildStickerGrid(
                        favouriteStickers,
                        isFromRecents: false,
                      ),
                    ],
                  ),
                ),
              ),
            if (hasRecentStickers)
              SliverToBoxAdapter(
                child: Container(
                  key: _recentKey,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.history),
                        title: Text(L10n.of(context).recentStickers),
                      ),
                      const SizedBox(height: 6),
                      _buildStickerGrid(recentStickers, isFromRecents: true),
                    ],
                  ),
                ),
              ),
            if (packSlugs.isEmpty && !hasRecentStickers)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [Text(L10n.of(context).noEmotesFound)],
                  ),
                ),
              )
            else
              // Use a single SliverToBoxAdapter with a Column so all
              // pack widgets and their GlobalKeys are always laid out
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    for (int i = 0; i < packSlugs.length; i++)
                      _buildPackWidget(
                        pack: stickerPacks[packSlugs[i]]!,
                        slug: packSlugs[i],
                        hasRecentStickers: hasRecentStickers,
                        isFirst: i == 0,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A single tab item in the pack selector bar.
class _PackTabItem extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  final bool isActive;

  const _PackTabItem({
    required this.onTap,
    required this.child,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? theme.colorScheme.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: SizedBox(width: 40, height: 36, child: Center(child: child)),
      ),
    );
  }
}

/// Delegate for the sticky pack tab bar header.
class _PackTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _PackTabBarDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  double get maxExtent => 57;

  @override
  double get minExtent => 57;

  @override
  bool shouldRebuild(covariant _PackTabBarDelegate oldDelegate) => true;
}
