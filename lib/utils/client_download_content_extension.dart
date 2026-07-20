import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:matrix/matrix.dart';

extension ClientDownloadContentExtension on Client {
  /// Downloads an MXC URI and caches it in the database. Validates that cached
  /// data is actually a decodable image so corrupt entries can be detected and
  /// re-downloaded.
  Future<Uint8List> downloadMxcCached(
    Uri mxc, {
    num? width,
    num? height,
    bool isThumbnail = false,
    bool? animated,
    ThumbnailMethod? thumbnailMethod,
    bool rounded = false,
  }) async {
    // To stay compatible with previous storeKeys:
    final cacheKey = isThumbnail
        // ignore: deprecated_member_use
        ? mxc.getThumbnail(
            this,
            width: width,
            height: height,
            animated: animated,
            method: thumbnailMethod,
          )
        : mxc;

    final cachedData = await database.getFile(cacheKey);
    if (cachedData != null && cachedData.isNotEmpty) {
      if (_isValidImage(cachedData)) {
        return cachedData;
      }
      // Cached data is corrupt (e.g. HTML error page). Remove it and re-fetch.
      Logs().w('Discarding corrupt cached image for $cacheKey');
      await database.deleteFile(cacheKey);
    }

    final httpUri = isThumbnail
        ? await mxc.getThumbnailUri(
            this,
            width: width,
            height: height,
            animated: animated,
            method: thumbnailMethod,
          )
        : await mxc.getDownloadUri(this);

    final response = await httpClient.get(
      httpUri,
      headers: accessToken == null
          ? null
          : {'authorization': 'Bearer $accessToken'},
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to download $httpUri: ${response.statusCode} ${response.body}',
      );
    }
    var imageData = response.bodyBytes;

    if (rounded) {
      final image = img.decodeImage(imageData);
      if (image != null) {
        imageData = img.encodePng(img.copyCropCircle(image));
      }
    }

    if (!_isValidImage(imageData)) {
      throw Exception(
        'Downloaded data for $httpUri is not a valid image',
      );
    }

    await database.storeFile(cacheKey, imageData, 0);

    return imageData;
  }

  /// Heuristic image validation: try to decode the first frame using Flutter's
  /// image codec. This catches HTML error pages and truncated files.
  static bool _isValidImage(Uint8List data) {
    try {
      // image package is fast and catches most corrupt files.
      final image = img.decodeImage(data);
      if (image != null && image.width > 0 && image.height > 0) return true;
    } catch (e) {
      Logs().d('image package validation failed', e);
    }
    return false;
  }
}
