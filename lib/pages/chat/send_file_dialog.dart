import 'dart:typed_data';

import 'package:flutter/cupertino.dart' hide Image;
import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/src/utils/markdown.dart';
import 'package:mime/mime.dart';

import 'package:Pulsly/config/app_config.dart';
import 'package:Pulsly/config/setting_keys.dart';
import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/utils/bridge_utils.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/event_extension.dart';
import 'package:Pulsly/utils/clean_exif.dart';
import 'package:Pulsly/utils/foreground_services.dart';
import 'package:Pulsly/utils/loading_snackbar_extension.dart';
import 'package:Pulsly/utils/localized_exception_extension.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_file_extension.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/size_string.dart';
import 'package:Pulsly/widgets/adaptive_dialogs/dialog_text_field.dart';
import 'package:Pulsly/widgets/adaptive_dialogs/image_editor_dialog.dart';
import 'package:Pulsly/widgets/matrix.dart';
import '../../utils/resize_video.dart';
import '../../utils/resize_image.dart';
import '../../utils/share_event_log.dart';

// ignore: implementation_imports
// ignore: depend_on_referenced_packages

class SendFileDialog extends StatefulWidget {
  final Room room;
  final Thread? thread;
  final List<XFile> files;
  final BuildContext outerContext;
  final Event? replyEvent;
  final void Function()? onClearReply;
  final void Function()? onSent;

  const SendFileDialog({
    required this.room,
    required this.thread,
    required this.files,
    required this.outerContext,
    this.onClearReply,
    this.replyEvent,
    this.onSent,
    super.key,
  });

  @override
  SendFileDialogState createState() => SendFileDialogState();
}

class SendFileDialogState extends State<SendFileDialog> {
  bool compress = true;
  bool isSending = false;

  /// Images smaller than 20kb don't need compression.
  static const int minSizeToCompress = 20 * 1000;

  final TextEditingController _labelTextController = TextEditingController();

  /// Verstuurt alle bestanden als één MSC4274-galerijbericht
  /// (`dm.filament.gallery`): één bericht met meerdere media.
  Future<void> _sendGallery(
    ScaffoldMessengerState scaffoldMessenger,
    L10n l10n,
    int maxUploadSize,
  ) async {
    final items = <Map<String, dynamic>>[];
    for (final xfile in widget.files) {
      items.add(
        await _prepareGalleryItem(
          scaffoldMessenger: scaffoldMessenger,
          l10n: l10n,
          maxUploadSize: maxUploadSize,
          xfile: xfile,
        ),
      );
    }

    final label = _labelTextController.text.trim();
    final content = <String, dynamic>{
      'msgtype': galleryMessageType,
      'body': label,
      'itemtypes': items,
      if (label.isNotEmpty) ..._extraGalleryContent(label),
    };

    widget.onClearReply?.call();

    await widget.room.sendEvent(
      content,
      threadLastEventId:
          widget.thread?.lastEvent?.eventId ?? widget.thread?.rootEvent.eventId,
      threadRootEventId: widget.thread?.rootEvent.eventId,
    );
    widget.onSent?.call();
  }

  /// Bouwt het bijschrift/format/content-warning/reply-gedeelte van het
  /// galerijbericht, net als bij losse bestanden.
  Map<String, dynamic> _extraGalleryContent(String label) {
    final extraContent = <String, dynamic>{};
    final html = markdown(
      label,
      getEmotePacks: () =>
          widget.room.getImagePacksFlat(ImagePackUsage.emoticon),
      getMention: widget.room.getMention,
      convertLinebreaks: Matrix.of(
        context,
      ).client.convertLinebreaksInFormatting,
    );
    // Als de HTML hetzelfde is als de tekst is er geen opmaak nodig.
    if (HtmlUnescape().convert(
          html.replaceAll(RegExp(r'<br />\n?'), '\n'),
        ) !=
        label) {
      extraContent['format'] = 'org.matrix.custom.html';
      extraContent['formatted_body'] = html;
    }
    if (widget.replyEvent != null) {
      extraContent['m.relates_to'] = {
        'm.in_reply_to': {'event_id': widget.replyEvent!.eventId},
      };
    }
    return extraContent;
  }

  /// Bereidt één galerijitem voor: bestand comprimeren, thumbnail maken,
  /// encrypten en uploaden. Geeft de item-map terug die in het galerijbericht
  /// komt.
  Future<Map<String, dynamic>> _prepareGalleryItem({
    required ScaffoldMessengerState scaffoldMessenger,
    required L10n l10n,
    required int maxUploadSize,
    required XFile xfile,
  }) async {
    final length = await xfile.length();
    final path = xfile.path;
    final mimeType = xfile.mimeType ?? lookupMimeType(path);
    final name = xfile.name.isNotEmpty
        ? xfile.name
        : "file.${mimeType?.split('/').last ?? 'bin'}";

    MatrixFile file;
    MatrixImageFile? thumbnail;

    if (mimeType != null &&
        mimeType.startsWith('image') &&
        length > minSizeToCompress &&
        compress) {
      scaffoldMessenger.showLoadingSnackBar(l10n.compress);
      final resizedImage = await ImageResizer.resizeImage(xfile);
      file = resizedImage ??
          MatrixFile(
            bytes: await xfile.readAsBytes(),
            name: name,
            mimeType: mimeType,
          ).detectFileType;
    } else {
      if (length > maxUploadSize) {
        throw FileTooBigMatrixException(length, maxUploadSize);
      }
      file = MatrixFile(
        bytes: await xfile.readAsBytes(),
        name: name,
        mimeType: mimeType,
      ).detectFileType;
    }

    if (file.bytes.length > maxUploadSize) {
      throw FileTooBigMatrixException(length, maxUploadSize);
    }

    if (PlatformInfos.isMobile &&
        mimeType != null &&
        mimeType.startsWith('video')) {
      try {
        scaffoldMessenger.showLoadingSnackBar(
          l10n.generatingVideoThumbnail,
        );
        thumbnail = await xfile.getVideoThumbnail();
      } catch (e) {
        Logs().e("Failed to generate video thumbnail", e);
      }
    }

    if (widget.files.length > 1) {
      scaffoldMessenger.showLoadingSnackBar(
        l10n.sendingAttachmentCountOfCount(
          widget.files.indexOf(xfile) + 1,
          widget.files.length,
        ),
      );
    }

    final client = widget.room.client;

    // Encrypten zoals Room.sendFileEvent dat doet.
    MatrixFile? uploadFile;
    MatrixFile? uploadThumbnail = thumbnail;
    EncryptedFile? encryptedFile;
    EncryptedFile? encryptedThumbnail;
    if (widget.room.encrypted && client.fileEncryptionEnabled) {
      encryptedFile = await file.encrypt();
      uploadFile = encryptedFile.toMatrixFile();
      if (thumbnail != null) {
        encryptedThumbnail = await thumbnail.encrypt();
        uploadThumbnail = encryptedThumbnail.toMatrixFile();
      }
    }

    final uploadResp = await client.uploadContent(
      (uploadFile ?? file).bytes,
      filename: (uploadFile ?? file).name,
      contentType: (uploadFile ?? file).mimeType,
    );
    final thumbnailUploadResp = uploadThumbnail != null
        ? await client.uploadContent(
            uploadThumbnail.bytes,
            filename: uploadThumbnail.name,
            contentType: uploadThumbnail.mimeType,
          )
        : null;

    return {
      'itemtype': MatrixFile.msgTypeFromMime(file.mimeType),
      'body': file.name,
      'filename': file.name,
      if (encryptedFile == null) 'url': uploadResp.toString(),
      if (encryptedFile != null)
        'file': {
          'url': uploadResp.toString(),
          'mimetype': file.mimeType,
          'v': 'v2',
          'key': {
            'alg': 'A256CTR',
            'ext': true,
            'k': encryptedFile.k,
            'key_ops': ['encrypt', 'decrypt'],
            'kty': 'oct',
          },
          'iv': encryptedFile.iv,
          'hashes': {'sha256': encryptedFile.sha256},
        },
      'info': {
        ...file.info,
        if (thumbnail != null && encryptedThumbnail == null)
          'thumbnail_url': thumbnailUploadResp.toString(),
        if (thumbnail != null && encryptedThumbnail != null)
          'thumbnail_file': {
            'url': thumbnailUploadResp.toString(),
            'mimetype': thumbnail.mimeType,
            'v': 'v2',
            'key': {
              'alg': 'A256CTR',
              'ext': true,
              'k': encryptedThumbnail.k,
              'key_ops': ['encrypt', 'decrypt'],
              'kty': 'oct',
            },
            'iv': encryptedThumbnail.iv,
            'hashes': {'sha256': encryptedThumbnail.sha256},
          },
        if (thumbnail != null) 'thumbnail_info': thumbnail.info,
      },
    };
  }

  Future<void> _send() async {
    final scaffoldMessenger = ScaffoldMessenger.of(widget.outerContext);
    final l10n = L10n.of(context);

    try {
      setState(() {
        isSending = true;
      });
      scaffoldMessenger.showLoadingSnackBar(l10n.prepareSendingAttachment);
      final clientConfig = await widget.room.client.getConfig();
      final maxUploadSize = clientConfig.mUploadSize ?? 100 * 1000 * 1000;
    // Cap op 30MB voor video: houdt ruimte voor encryptie-overhead en blijft kijkbaar.

      // Vroege duidelijke melding: oncomprimeerbare bestanden die sowieso
      // te groot zijn, afvangen VÓÓR de upload. Voorheen leek het alsof
      // "er niets gebeurde" — de dialoog sloot, de upload faalde stil.
      // Video's krijgen hier nog een kans: die worden later progressief
      // gecomprimeerd (resizeVideo(maxBytes:)) zodat ze alsnog passen.
      for (final xfile in widget.files) {
        final path = xfile.path;
        final mimeType = xfile.mimeType ?? (path != null ? lookupMimeType(path) : null);
        // ignore: unnecessary_null_comparison
        final isVideo = (mimeType ?? '').startsWith('video');
        if (isVideo) continue; // video -> compressie-pad hieronder
        final length = await xfile.length();
        if (length > maxUploadSize) {
          scaffoldMessenger.clearSnackBars();
          scaffoldMessenger.showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              content: Text(
                l10n.fileIsTooBigForServer(
                  formatFileSizeHuman(maxUploadSize),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              duration: const Duration(seconds: 6),
            ),
          );
          return;
        }
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: false).pop();
      }

      // Upload overleeft wegdrukken: foreground-service aan vóór compressie
      // (video-compressie duurt lang) en uit in finally — ook bij falen.
      await ForegroundServices.startService('send_files');

      // Galerij: alle bestanden in één MSC4274-bericht. In overbrugde
      // kamers (Telegram, WhatsApp, Signal...) kan de brug dit berichttype
      // niet converteren en komt het er nooit aan — daar dus losse
      // berichten.
      if (AppSettings.useGalleries.value &&
          widget.files.length > 1 &&
          !isBridgeRoom(widget.room)) {
        await _sendGallery(scaffoldMessenger, l10n, maxUploadSize);
        scaffoldMessenger.clearSnackBars();
        return;
      }

      for (final xfile in widget.files) {
        MatrixFile file;
        MatrixImageFile? thumbnail;
        final length = await xfile.length();
        final path = xfile.path;
        final mimeType = xfile.mimeType ?? (path != null ? lookupMimeType(path) : null);
        // ignore: unnecessary_null_comparison
        final name = xfile.name.isNotEmpty
            ? xfile.name
            : "file.${mimeType?.split('/').last ?? 'bin'}";

        // If file is a video, shrink it!
        if (PlatformInfos.isMobile &&
            mimeType != null &&
            mimeType.startsWith('video') &&
            length > minSizeToCompress &&
            compress) {
          scaffoldMessenger.showLoadingSnackBar(l10n.compressVideo);
          final effectiveMax = (maxUploadSize > 30 * 1000 * 1000 ? 30 * 1000 * 1000 : maxUploadSize);
    file = await xfile.resizeVideo(maxBytes: effectiveMax);
        } else if (mimeType != null &&
            mimeType.startsWith('image') &&
            length > minSizeToCompress &&
            compress) {
          // Resize image before upload (much faster sending)
          // EXIF wordt automatisch verwijderd tijdens resize + JPEG encode
          scaffoldMessenger.showLoadingSnackBar(l10n.compress);
          final resizedImage = await ImageResizer.resizeImage(xfile);
          if (resizedImage != null) {
            file = resizedImage;
          } else {
            // Resize faalde, gebruik origineel
            file = MatrixFile(
              bytes: await xfile.readAsBytes(),
              name: name,
              mimeType: mimeType,
            ).detectFileType;
          }
        } else if (mimeType != null &&
            mimeType.startsWith('image') &&
            AppSettings.cleanExif.value) {
          // Alleen EXIF verwijderen als we NIET al gecomprimeerd hebben
          if (length > maxUploadSize) {
            throw FileTooBigMatrixException(length, maxUploadSize);
          }

          scaffoldMessenger.showLoadingSnackBar(l10n.prepareSendingAttachment);
          try {
            file = MatrixFile(
              bytes: Uint8List.fromList(
                ExifCleaner.removeExifData(await xfile.readAsBytes()),
              ),
              name: name,
              mimeType: mimeType,
            ).detectFileType;
          } catch (e) {
            // Exif clean faalde, gebruik origineel
            Logs().w('EXIF cleanup failed, using original', e);
            file = MatrixFile(
              bytes: await xfile.readAsBytes(),
              name: name,
              mimeType: mimeType,
            ).detectFileType;
          }
        } else {
          if (length > maxUploadSize) {
            throw FileTooBigMatrixException(length, maxUploadSize);
          }

          // Else we just create a MatrixFile
          file = MatrixFile(
            bytes: await xfile.readAsBytes(),
            name: name,
            mimeType: mimeType,
          ).detectFileType;
        }

        if (file.bytes.length > maxUploadSize) {
          throw FileTooBigMatrixException(length, maxUploadSize);
        }

        // Video thumbnail alleen genereren als expliciet gewenst (bespaart tijd)
        if (PlatformInfos.isMobile &&
            mimeType != null &&
            mimeType.startsWith('video') &&
            compress) {
          try {
            scaffoldMessenger.showLoadingSnackBar(
              l10n.generatingVideoThumbnail,
            );
            thumbnail = await xfile.getVideoThumbnail();
          } catch (e) {
            Logs().e("Failed to generate video thumbnail", e);
            scaffoldMessenger.showLoadingSnackBar(e.toLocalizedString(context));
          }
        }

        if (widget.files.length > 1) {
          scaffoldMessenger.showLoadingSnackBar(
            l10n.sendingAttachmentCountOfCount(
              widget.files.indexOf(xfile) + 1,
              widget.files.length,
            ),
          );
        } else {
          scaffoldMessenger.clearSnackBars();
        }

        final label = _labelTextController.text.trim();
        final extraContent = <String, dynamic>{};

        if (label.isNotEmpty) {
          extraContent['body'] = label;
          final html = markdown(
            label,
            getEmotePacks: () =>
                widget.room.getImagePacksFlat(ImagePackUsage.emoticon),
            getMention: widget.room.getMention,
            convertLinebreaks: Matrix.of(
              context,
            ).client.convertLinebreaksInFormatting,
          );

          // if the decoded html is the same as the body, there is no need in sending a formatted message
          if (HtmlUnescape().convert(
                html.replaceAll(RegExp(r'<br />\n?'), '\n'),
              ) !=
              label) {
            extraContent['format'] = 'org.matrix.custom.html';
            extraContent['formatted_body'] = html;
          }
        }

        if (widget.replyEvent != null) {
          extraContent['m.relates_to'] = {
            'm.in_reply_to': {'event_id': widget.replyEvent!.eventId},
          };
        }

        widget.onClearReply?.call();

        try {
          await widget.room.sendFileEvent(
            file,
            thumbnail: thumbnail,
            shrinkImageMaxDimension: compress ? 1600 : null,
            extraContent: extraContent,
            threadLastEventId:
                widget.thread?.lastEvent?.eventId ??
                widget.thread?.rootEvent.eventId,
            threadRootEventId: widget.thread?.rootEvent.eventId,
          );
          widget.onSent?.call();
        } on MatrixException catch (e) {
          final retryAfterMs = e.retryAfterMs;
          if (e.error != MatrixError.M_LIMIT_EXCEEDED || retryAfterMs == null) {
            rethrow;
          }
          final retryAfterDuration = Duration(
            milliseconds: retryAfterMs + 1000,
          );

          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(
                l10n.serverLimitReached(retryAfterDuration.inSeconds),
              ),
            ),
          );
          await Future.delayed(retryAfterDuration);

          scaffoldMessenger.showLoadingSnackBar(l10n.sendingAttachment);

          await widget.room.sendFileEvent(
            file,
            thumbnail: thumbnail,
            shrinkImageMaxDimension: compress ? 1600 : null,
            extraContent: extraContent,
            threadLastEventId:
                widget.thread?.lastEvent?.eventId ??
                widget.thread?.rootEvent.eventId,
            threadRootEventId: widget.thread?.rootEvent.eventId,
          );
        }
      }
      scaffoldMessenger.clearSnackBars();
    } catch (e) {
      // Leg vast wat er misging: bij een share-fout is dit het enige spoor.
      // De snackbar hieronder is vluchtig; deze regel blijft staan.
      ShareEventLog().add('share_verzend-fout', {
        'fout': '$e',
        'type': e.runtimeType.toString(),
      });
      Logs().e('error on send', e);
      setState(() {
        isSending = false;
      });
      scaffoldMessenger.clearSnackBars();
      final theme = Theme.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: theme.colorScheme.errorContainer,
          closeIconColor: theme.colorScheme.onErrorContainer,
          content: Text(
            e.toLocalizedString(widget.outerContext),
            style: TextStyle(color: theme.colorScheme.onErrorContainer),
          ),
          duration: const Duration(seconds: 30),
          showCloseIcon: true,
        ),
      );
      rethrow;
    } finally {
      await ForegroundServices.stopService('send_files');
    }

    return;
  }

  Future<String> _calcCombinedFileSize() async {
    final lengths = await Future.wait(
      widget.files.map((file) => file.length()),
    );
    return lengths.fold<double>(0, (p, length) => p + length).sizeString;
  }

  void editImage(int index) async {
    final file = widget.files[index];
    final edited = await showImageEditor(
      context: context,
      byteArray: await file.readAsBytes(),
    );
    if (edited == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(L10n.of(context).imageEditFailed)));
      return;
    }
    setState(() {
      widget.files[index] = XFile.fromData(
        edited,
        mimeType: file.mimeType,
        name: file.name,
        path: file.path,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    var sendStr = L10n.of(context).sendFile;
    final uniqueFileType = widget.files
        .map((file) => file.mimeType ?? lookupMimeType(file.name))
        .map((mimeType) => mimeType?.split('/').first)
        .toSet()
        .singleOrNull;

    final fileName = widget.files.length == 1
        ? widget.files.single.name
        : L10n.of(context).countFiles(widget.files.length);
    final fileTypes = widget.files
        .map((file) => file.name.split('.').last)
        .toSet()
        .join(', ')
        .toUpperCase();

    if (uniqueFileType == 'image') {
      if (widget.files.length == 1) {
        sendStr = L10n.of(context).sendImage;
      } else {
        sendStr = L10n.of(context).sendImages(widget.files.length);
      }
    } else if (uniqueFileType == 'audio') {
      sendStr = L10n.of(context).sendAudio;
    } else if (uniqueFileType == 'video') {
      sendStr = L10n.of(context).sendVideo;
    }

    final compressionSupported =
        uniqueFileType != 'video' || PlatformInfos.isMobile;

    return FutureBuilder<String>(
      future: _calcCombinedFileSize(),
      builder: (context, snapshot) {
        final sizeString =
            snapshot.data ?? L10n.of(context).calculatingFileSize;

        return AlertDialog.adaptive(
          title: Text(sendStr),
          content: SizedBox(
            width: 256,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  if (uniqueFileType == 'image')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: SizedBox(
                        height: 256,
                        child: Center(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.files.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, i) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Material(
                                borderRadius: BorderRadius.circular(
                                  AppConfig.borderRadius / 2,
                                ),
                                color: Colors.black,
                                clipBehavior: Clip.hardEdge,
                                child: FutureBuilder(
                                  future: widget.files[i].readAsBytes(),
                                  builder: (context, snapshot) {
                                    final bytes = snapshot.data;
                                    if (bytes == null) {
                                      return const Center(
                                        child:
                                            CircularProgressIndicator.adaptive(),
                                      );
                                    }
                                    if (snapshot.error != null) {
                                      Logs().w(
                                        'Unable to preview image',
                                        snapshot.error,
                                        snapshot.stackTrace,
                                      );
                                      return const Center(
                                        child: SizedBox(
                                          width: 256,
                                          height: 256,
                                          child: Icon(
                                            Icons.broken_image_outlined,
                                            size: 64,
                                          ),
                                        ),
                                      );
                                    }
                                    return Stack(
                                      children: [
                                        Image.memory(
                                          bytes,
                                          height: 256,
                                          width: widget.files.length == 1
                                              ? 256 - 36
                                              : null,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, e, s) {
                                            Logs().w(
                                              'Unable to preview image',
                                              e,
                                              s,
                                            );
                                            return const Center(
                                              child: SizedBox(
                                                width: 256,
                                                height: 256,
                                                child: Icon(
                                                  Icons.broken_image_outlined,
                                                  size: 64,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        Positioned(
                                          right: 8,
                                          bottom: 8,
                                          child: IconButton.filledTonal(
                                            onPressed: () => editImage(i),
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (uniqueFileType != 'image')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Icon(
                            uniqueFileType == null
                                ? Icons.description_outlined
                                : uniqueFileType == 'video'
                                ? Icons.video_file_outlined
                                : uniqueFileType == 'audio'
                                ? Icons.audio_file_outlined
                                : Icons.description_outlined,
                            size: 32,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$sizeString - $fileTypes',
                                  style: theme.textTheme.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.files.length == 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: DialogTextField(
                        controller: _labelTextController,
                        labelText: L10n.of(context).optionalMessage,
                        minLines: 1,
                        maxLines: 3,
                        maxLength: 255,
                        counterText: '',
                      ),
                    ),
                  // Workaround for SwitchListTile.adaptive crashes in CupertinoDialog
                  if ({'image', 'video'}.contains(uniqueFileType))
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if ({
                          TargetPlatform.iOS,
                          TargetPlatform.macOS,
                        }.contains(theme.platform))
                          CupertinoSwitch(
                            value: compressionSupported && compress,
                            onChanged: compressionSupported
                                ? (v) => setState(() => compress = v)
                                : null,
                          )
                        else
                          Switch.adaptive(
                            value: compressionSupported && compress,
                            onChanged: compressionSupported
                                ? (v) => setState(() => compress = v)
                                : null,
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    L10n.of(context).compress,
                                    style: theme.textTheme.titleMedium,
                                    textAlign: TextAlign.left,
                                  ),

                  // Galerij: meerdere bestanden als één bericht. Experimenteel
                  // — clients die MSC4274 niet kennen tonen het als één
                  // onbekend bestand.
                  if (widget.files.length > 1 && !isBridgeRoom(widget.room))
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Switch.adaptive(
                          value: AppSettings.useGalleries.value,
                          onChanged: (v) async {
                            await AppSettings.useGalleries.setItem(v);
                            if (!mounted) return;
                            setState(() {});
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                L10n.of(context).sendAsGallery,
                                style: theme.textTheme.titleMedium,
                                textAlign: TextAlign.left,
                              ),
                              Text(
                                L10n.of(context).sendAsGalleryDescription,
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                                ],
                              ),
                              if (!compress)
                                Text(
                                  ' ($sizeString)',
                                  style: theme.textTheme.labelSmall,
                                ),
                              if (!compressionSupported)
                                Text(
                                  L10n.of(context).notSupportedOnThisDevice,
                                  style: theme.textTheme.labelSmall,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            if (!isSending)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.0),
                  ),
                ),
                onPressed: () =>
                    Navigator.of(context, rootNavigator: false).pop(),
                child: Text(L10n.of(context).cancel),
              ),
            if (!isSending)
              FilledButton(
                onPressed: _send,
                child: Text(L10n.of(context).send),
              ),
            if (isSending) const CircularProgressIndicator.adaptive(),
          ],
        );
      },
    );
  }
}
