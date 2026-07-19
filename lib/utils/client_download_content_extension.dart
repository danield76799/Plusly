import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:matrix/matrix.dart';

extension ClientDownloadContentExtension on Client {
  static const int _thumbnailBucketSize = 128;

  int? _bucket(num? value) {
    if (value == null) return null;
    return ((value / _thumbnailBucketSize).ceil() * _thumbnailBucketSize)
        .toInt();
  }

  Future<Uint8List> downloadMxcCached(
    Uri mxc, {
    num? width,
    num? height,
    bool isThumbnail = false,
    bool? animated,
    ThumbnailMethod? thumbnailMethod,
    bool rounded = false,
  }) async {
    // Bucket the requested size so similar thumbnails share one disk cache
    // entry. Without bucketing the same image at 98px, 101px and 104px would
    // each get their own row, quickly filling the DB and lowering hit rates.
    final effectiveWidth = _bucket(width);
    final effectiveHeight = _bucket(height);

    // To stay compatible with previous storeKeys:
    final cacheKey = isThumbnail
        // ignore: deprecated_member_use
        ? mxc.getThumbnail(
            this,
            width: effectiveWidth,
            height: effectiveHeight,
            animated: animated,
            method: thumbnailMethod,
          )
        : mxc;

    final cachedData = await database.getFile(cacheKey);
    if (cachedData != null) return cachedData;

    final httpUri = isThumbnail
        ? await mxc.getThumbnailUri(
            this,
            width: effectiveWidth,
            height: effectiveHeight,
            animated: animated,
            method: thumbnailMethod,
          )
        : await mxc.getDownloadUri(this);

    final response = await httpClient.get(
      httpUri,
      headers: accessToken == null
          ? null
          : {'authorization': 'Bearer $accessToken'},
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception();
    }
    var imageData = response.bodyBytes;

    if (rounded) {
      final image = img.decodeImage(imageData);
      if (image != null) {
        imageData = img.encodePng(img.copyCropCircle(image));
      }
    }

    await database.storeFile(cacheKey, imageData, 0);

    return imageData;
  }
}
