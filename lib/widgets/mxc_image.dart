import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/utils/client_download_content_extension.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_file_extension.dart';
import 'package:Pulsly/widgets/matrix.dart';

class MxcImage extends StatefulWidget {
  final Uri? uri;
  final Event? event;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isThumbnail;
  final bool animated;
  final Duration retryDuration;
  final Duration animationDuration;
  final Curve animationCurve;
  final ThumbnailMethod thumbnailMethod;
  final Widget Function(BuildContext context)? placeholder;
  final String? cacheKey;
  final Client? client;
  final BorderRadius borderRadius;

  const MxcImage({
    this.uri,
    this.event,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.isThumbnail = true,
    this.animated = false,
    this.animationDuration = const Duration(milliseconds: 200),
    this.retryDuration = const Duration(seconds: 2),
    this.animationCurve = Curves.easeInOut,
    this.thumbnailMethod = ThumbnailMethod.scale,
    this.cacheKey,
    this.client,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  /// LRU cache shared across all MxcImage instances
  static final _imageDataCache = _LruCache<String, Uint8List>(maxSize: 300);

  /// Preload a single image into cache
  static Future<void> preload(Event event, {required double thumbnailSize}) async {
    final cacheKey = '${event.eventId}_thumb_${thumbnailSize.toInt()}';
    if (_imageDataCache.containsKey(cacheKey)) return;

    try {
      final data = await event.downloadAndDecryptAttachment(
        getThumbnail: true,
      );
      if (data.bytes.isNotEmpty) {
        _imageDataCache.put(cacheKey, data.bytes);
      }
    } catch (_) {}
  }

  /// Preload multiple images into cache
  static Future<void> preloadAll(Iterable<Event> events, {required double thumbnailSize}) async {
    await Future.wait(events.map((e) => preload(e, thumbnailSize: thumbnailSize)));
  }

  @override
  State<MxcImage> createState() => _MxcImageState();
}

class _MxcImageState extends State<MxcImage> {
  Uint8List? _imageDataNoCache;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  Uint8List? get _imageData => widget.cacheKey == null
      ? _imageDataNoCache
      : MxcImage._imageDataCache.get(widget.cacheKey!);

  set _imageData(Uint8List? data) {
    if (data == null) return;
    final cacheKey = widget.cacheKey;
    cacheKey == null
        ? _imageDataNoCache = data
        : MxcImage._imageDataCache.put(cacheKey, data);
  }

  Future<void> _load() async {
    if (!mounted) return;
    final client =
        widget.client ?? widget.event?.room.client ?? Matrix.of(context).client;
    final uri = widget.uri;
    final event = widget.event;
    if (uri != null) {
      final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
      final width = widget.width;
      final realWidth = width == null ? null : width * devicePixelRatio;
      final height = widget.height;
      final realHeight = height == null ? null : height * devicePixelRatio;
      final remoteData = await client.downloadMxcCached(
        uri,
        width: realWidth,
        height: realHeight,
        thumbnailMethod: widget.thumbnailMethod,
        isThumbnail: widget.isThumbnail,
        animated: widget.animated,
      );
      if (!mounted) return;
      setState(() {
        _imageData = remoteData;
      });
    } else if (event != null) {
      final data = await event.downloadAndDecryptAttachment(
        getThumbnail: widget.isThumbnail,
      );
      if (data.detectFileType is MatrixImageFile || widget.isThumbnail) {
        if (!mounted) return;
        setState(() {
          _imageData = data.bytes;
        });
        return;
      }
    }
  }

  Future<void> _tryLoad() async {
    if (_imageData != null) {
      return;
    }
    try {
      await _load();
      _retryCount = 0; // reset on success
    } catch (e, s) {
      if (!mounted) return;
      Logs().d('MxcImage: error loading image ${widget.uri ?? widget.event?.eventId}', e, s);
      _retryCount++;
      if (_retryCount >= _maxRetries) {
        return;
      }
      await Future.delayed(widget.retryDuration);
      _tryLoad();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryLoad());
  }

  @override
  Widget build(BuildContext context) {
    final data = _imageData;
    final hasData = data != null && data.isNotEmpty;
    return AnimatedSwitcher(
      duration: widget.animationDuration,
      child: hasData
          ? ClipRRect(
              borderRadius: widget.borderRadius,
              child: Image.memory(
                data,
                width: widget.width,
                height: widget.height,
                fit: widget.fit,
                filterQuality: widget.isThumbnail
                    ? (widget.width ?? 0) < 100
                        ? FilterQuality.none  // Scherpe pixels bij kleine thumbnails
                        : FilterQuality.low
                    : FilterQuality.medium,
                errorBuilder: (context, e, s) {
                  Logs().d('Unable to render mxc image', e, s);
                  return SizedBox(
                    width: widget.width,
                    height: widget.height,
                    child: Material(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: Icon(
                        Icons.broken_image_outlined,
                        size: min(widget.height ?? 64, 64),
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                },
              ),
            )
          : _MxcImagePlaceholder(
              width: widget.width,
              height: widget.height,
              placeholder: widget.placeholder,
            ),
    );
  }
}

class _MxcImagePlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget Function(BuildContext context)? placeholder;

  const _MxcImagePlaceholder({
    required this.width,
    required this.height,
    required this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return placeholder?.call(context) ??
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          child: const CircularProgressIndicator.adaptive(strokeWidth: 2),
        );
  }
}

/// Simple LRU cache for image data
class _LruCache<K, V> {
  final int maxSize;
  final _map = LinkedHashMap<K, V>();

  _LruCache({required this.maxSize});

  V? get(K key) {
    final value = _map.remove(key);
    if (value != null) {
      _map[key] = value;
    }
    return value;
  }

  bool containsKey(K key) => _map.containsKey(key);

  void put(K key, V value) {
    _map.remove(key);
    _map[key] = value;
    while (_map.length > maxSize) {
      _map.remove(_map.keys.first);
    }
  }

  void clear() => _map.clear();
}
