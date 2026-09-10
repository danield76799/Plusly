import 'package:cross_file/cross_file.dart';
import 'package:matrix/matrix.dart';
import 'package:video_compress/video_compress.dart';

import 'package:Pulsly/utils/client_manager.dart';
import 'package:Pulsly/utils/platform_infos.dart';

extension ResizeImage on XFile {
  static const int max = 1200;
  static const int quality = 40;

  /// Comprimeert de video zodanig dat deze onder [maxBytes] blijft.
  /// Probeert progressief: DefaultQuality (720p) → MediumQuality → LowQuality.
  /// Faalt alles, dan valt de caller terug op de originele bytes.
  Future<MatrixVideoFile> resizeVideo({int? maxBytes}) async {
    MediaInfo? mediaInfo;
    var compressFailed = false;
    try {
      if (PlatformInfos.isMobile) {
        // will throw an error e.g. on Android SDK < 18
        mediaInfo = await VideoCompress.compressVideo(
          path,
          quality: VideoQuality.DefaultQuality,
        );
      }
    } catch (e, s) {
      Logs().w('Error while compressing video', e, s);
      compressFailed = true;
    }

    // Nog te groot na 720p-compressie? → zwaarder comprimeren vanaf het
    // origineel. matrix.org heeft bv. een 50MB-limiet; een lange 720p-
    // video komt daar makkelijk boven uit.
    if (!compressFailed &&
        maxBytes != null &&
        mediaInfo?.file != null &&
        await mediaInfo!.file!.length() > maxBytes) {
      try {
        final lower = await VideoCompress.compressVideo(
          path,
          quality: VideoQuality.MediumQuality,
        );
        if (lower?.file != null) {
          mediaInfo = lower;
          if (await mediaInfo!.file!.length() > maxBytes) {
            final lowest = await VideoCompress.compressVideo(
              path,
              quality: VideoQuality.LowQuality,
            );
            if (lowest?.file != null) mediaInfo = lowest;
          }
        }
      } catch (e, s) {
        Logs().w('Error while re-compressing video', e, s);
        // behoud de 720p-versie
      }
    }

    // Fallback naar originele bytes als compressie faalde
    final bytes = (compressFailed || mediaInfo?.file == null)
        ? await readAsBytes()
        : await mediaInfo!.file!.readAsBytes();

    return MatrixVideoFile(
      bytes: bytes,
      name: name,
      mimeType: mimeType,
      width: mediaInfo?.width,
      height: mediaInfo?.height,
      duration: mediaInfo?.duration?.round(),
    );
  }

  Future<MatrixImageFile?> getVideoThumbnail() async {
    if (!PlatformInfos.isMobile) return null;

    try {
      final bytes = await VideoCompress.getByteThumbnail(path);
      if (bytes == null) return null;

      return MatrixImageFile.create(
        bytes: bytes,
        name: name,
        nativeImplementations: ClientManager.nativeImplementations,
      );
    } catch (e, s) {
      Logs().w('Error while compressing video', e, s);
    }
    return null;
  }
}
