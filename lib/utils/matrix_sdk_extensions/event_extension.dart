import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:async/async.dart' as async;
import 'package:matrix/matrix.dart';
import 'package:mime/mime.dart';

import 'package:Pulsly/pages/download_manager/download_manager.dart';
import 'package:Pulsly/utils/size_string.dart';
import 'package:Pulsly/widgets/future_loading_dialog.dart';
import 'matrix_file_extension.dart';

/// Berichttype van een MSC4274-galerij: één bericht met meerdere media.
///
/// Dit is een specificatievoorstel; clients die het niet kennen tonen het
/// bericht als één onbekend bestand.
const String galleryMessageType = 'dm.filament.gallery';

/// De media-items van een galerijbericht.
List<Map<String, dynamic>> galleryItems(Event event) {
  final itemtypes = event.content['itemtypes'];
  if (itemtypes is! List) return const [];
  return itemtypes
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

/// Zet een galerij-itemtype om naar het bijbehorende media-type.
String galleryItemtypeToMsgtype(String itemtype) => switch (itemtype) {
  'm.image' => MessageTypes.Image,
  'm.video' => MessageTypes.Video,
  'm.audio' => MessageTypes.Audio,
  'm.file' => MessageTypes.File,
  _ => MessageTypes.File,
};

/// Maakt een pseudo-[Event] van één MSC4274-galerijitem, zodat de gewone
/// media-widgets hergebruikt kunnen worden.
Event galleryItemEvent(Event parent, Map<String, dynamic> item, int index) =>
    Event(
      content: {
        ...item,
        'msgtype': galleryItemtypeToMsgtype(
          item.tryGet<String>('itemtype') ?? 'm.file',
        ),
      },
      type: EventTypes.Message,
      eventId: '${parent.eventId}:gallery:$index',
      senderId: parent.senderId,
      originServerTs: parent.originServerTs,
      room: parent.room,
    );

extension LocalizedBody on Event {
  Future<async.Result<MatrixFile?>> _getFile(BuildContext context) =>
      showFutureLoadingDialog(
        context: context,
        future: downloadAndDecryptAttachment,
      );

  void saveFile(BuildContext context) async {
    final matrixFile = await _getFile(context);

    matrixFile.result?.save(context);
  }

  String getLink() {
    return "https://matrix.to/#/${room.canonicalAlias != '' ? room.canonicalAlias : roomId}/$eventId";
  }

  void downloadInBackground(BuildContext context) async {
    if (canDownloadInBackground) {
      final dmc = DownloadManager.of(context);
      final filename = content.tryGet<String>('filename') ?? body;
      dmc.download(
        context,
        "$filename.${roomId!.substring(1, 5)}.${eventId.substring(1, 5)}.${extensionFromMime(attachmentMimetype) ?? filename.split('.').last}",
        attachmentMxcUrl.toString(),
      );
    } else {
      throw Exception(
        "Cannot download in background $hasAttachment ${room.encrypted}",
      );
    }
  }

  void shareFile(BuildContext context) async {
    final matrixFile = await _getFile(context);
    inspect(matrixFile);

    matrixFile.result?.share(context);
  }

  bool get canDownloadInBackground => hasAttachment && !room.encrypted;

  bool get isAttachmentSmallEnough =>
      infoMap['size'] is int &&
      infoMap['size'] as int < room.client.database.maxFileSize;

  bool get isThumbnailSmallEnough =>
      thumbnailInfoMap['size'] is int &&
      thumbnailInfoMap['size'] as int < room.client.database.maxFileSize;

  bool get showThumbnail =>
      [
        MessageTypes.Image,
        MessageTypes.Sticker,
        MessageTypes.Video,
      ].contains(messageType) &&
      (kIsWeb ||
          isAttachmentSmallEnough ||
          isThumbnailSmallEnough ||
          (content['url'] is String));

  String? get sizeString => content
      .tryGetMap<String, dynamic>('info')
      ?.tryGet<int>('size')
      ?.sizeString;
}
