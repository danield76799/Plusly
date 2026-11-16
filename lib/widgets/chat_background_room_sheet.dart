import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:file_picker/file_picker.dart';

import 'package:Pulsly/utils/file_selector.dart';

import 'chat_background.dart';

const _kBackgroundLabels = <String, String>{
  'dusk': 'Schemering',
  'forest': 'Bos',
  'ocean': 'Oceaan',
  'dots': 'Stippen',
  'waves': 'Golven',
  'stars': 'Sterren',
  'lattice': 'Ruitjes',
};

/// Bottom sheet om een achtergrond voor één specifieke chat te kiezen.
///
/// Keuze 'default' volgt de globale instelling (Weergave → Chatachtergrond),
/// 'none' zet de achtergrond bewust uit voor deze chat. De keuze wordt
/// lokaal op het apparaat opgeslagen (per roomId, niet gedeeld via Matrix).
Future<void> showChatBackgroundRoomSheet(
  BuildContext context,
  Room room,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _ChatBackgroundRoomSheet(room: room),
  );
}

class _ChatBackgroundRoomSheet extends StatefulWidget {
  final Room room;

  const _ChatBackgroundRoomSheet({required this.room});

  @override
  State<_ChatBackgroundRoomSheet> createState() =>
      _ChatBackgroundRoomSheetState();
}

class _ChatBackgroundRoomSheetState extends State<_ChatBackgroundRoomSheet> {
  // Foto specifiek voor dít gesprek; nooit de globale wallpaper overschrijven.
  String? get _roomWallpaper => perRoomWallpaperPath(widget.room.id);

  Future<void> pickCustomPhoto() async {
    final picked = await selectFiles(context, type: FileType.image);
    final pickedFile = picked.isEmpty ? null : picked.first;
    if (pickedFile == null) return;
    await setWallpaperForRoom(widget.room.id, File(pickedFile.path));
    await setChatBackgroundForRoom(widget.room.id, 'wallpaper');
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = widget.room;
    final current = perRoomChatBackground(room.id);

    Future<void> pick(String value) async {
      await setChatBackgroundForRoom(room.id, value);
      if (context.mounted) Navigator.of(context).pop();
    }

    Widget tile({
      required String id,
      required String label,
      required Widget preview,
      required bool selected,
      required VoidCallback onTap,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 64,
                  height: 84,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      width: selected ? 2.5 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: preview,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 72,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget builtinTile(String id, String label) => tile(
          id: id,
          label: label,
          selected: current == id,
          onTap: () => pick(id),
          preview: id == 'none'
              ? ColoredBox(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Center(
                    child: Icon(
                      Icons.block,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ChatBackground(background: id),
        );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Achtergrond voor deze chat',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              'Alleen voor dit gesprek. "Standaard" volgt de globale instelling.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  tile(
                    id: 'default',
                    label: 'Standaard',
                    selected: current == 'default',
                    onTap: () => pick('default'),
                    preview: ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.phonelink_setup_outlined,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  tile(
                    id: 'wallpaper',
                    label: 'Eigen foto',
                    selected: current == 'wallpaper',
                    onTap: pickCustomPhoto,
                    preview: _roomWallpaper != null
                        ? Image.file(
                            File(_roomWallpaper!),
                            fit: BoxFit.cover,
                            width: 64,
                            height: 84,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(Icons.broken_image_outlined),
                            ),
                          )
                        : ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.add_photo_alternate_outlined,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                  ),
                  builtinTile('none', 'Geen'),
                  for (final entry in _kBackgroundLabels.entries)
                    builtinTile(entry.key, entry.value),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
