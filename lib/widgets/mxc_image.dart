import 'dart:async';
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

  /// LRU cache shared across all MxcImage instances (in-memory decoded bytes).
  static final _imageDataCache = _LruCache<String, Uint8List>(maxSize: 500);

  /// In-flight downloads keyed by effective cache key. Multiple widgets that
  /// want the same image share the same Future instead of starting parallel
  /// downloads that overwrite each other in the LRU cache.
  static final _inFlightDownloads = <String, Future<Uint8List?>>{};

  /// Preload a single image into the shared cache.
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

  /// Preload multiple images into the shared cache.
  static Future<void> preloadAll(
    Iterable<Event> events, {
    required double thumbnailSize,
  }) async {
    await Future.wait(events.map((e) => preload(e, thumbnailSize: thumbnailSize)));
  }

  @override
  State<MxcImage> createState() => _MxcImageState();
}

class _MxcImageState extends State<MxcImage> {
  Uint8List? _currentData;
  bool _isLoading = false;
  bool _loadFailed = false;
  int _retryCount = 0;
  static const int _maxRetries = 3;

  String? get _effectiveCacheKey {
    if (widget.cacheKey != null) return widget.cacheKey;
    if (widget.event != null) {
      final suffix = widget.isThumbnail ? '_thumb' : '';
      return '${widget.event!.eventId}$suffix';
    }
    if (widget.uri != null) {
      final suffix = widget.isThumbnail ? '_thumb' : '';
      return '${widget.uri}$suffix';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _currentData = _getFromCache();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentData == null && !_isLoading) {
      _load();
    }
  }

  @override
  void didUpdateWidget(MxcImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri != widget.uri ||
        oldWidget.event != widget.event ||
        oldWidget.cacheKey != widget.cacheKey) {
      _retryCount = 0;
      final cached = _getFromCache();
      if (cached != null) {
        setState(() {
          _currentData = cached;
          _isLoading = false;
        });
      } else {
        setState(() {
          _currentData = null;
          _isLoading = false;
        });
        _load();
      }
    }
  }

  Uint8List? _getFromCache() {
    final key = _effectiveCacheKey;
    if (key != null) {
      return MxcImage._imageDataCache.get(key);
    }
    return null;
  }

  void _saveToCache(Uint8List data) {
    final key = _effectiveCacheKey;
    if (key != null) {
      MxcImage._imageDataCache.put(key, data);
    }
  }

  Future<void> _load() async {
    if (_isLoading || !mounted) return;

    if (_retryCount >= _maxRetries) {
      Logs().w(
        'MxcImage failed to load after $_maxRetries attempts: ${widget.uri}',
      );
      return;
    }

    final effectiveKey = _effectiveCacheKey;

    // 1. Try in-memory cache first.
    final cached = effectiveKey != null
        ? MxcImage._imageDataCache.get(effectiveKey)
        : null;
    if (cached != null && cached.isNotEmpty) {
      if (mounted) {
        setState(() {
          _currentData = cached;
          _isLoading = false;
          _retryCount = 0;
          _loadFailed = false;
        });
      }
      return;
    }

    // 2. Deduplicate in-flight downloads for the same key.
    if (effectiveKey != null) {
      final existing = MxcImage._inFlightDownloads[effectiveKey];
      if (existing != null) {
        setState(() => _isLoading = true);
        final shared = await existing;
        if (!mounted) return;
        if (shared != null && shared.isNotEmpty) {
          setState(() {
            _currentData = shared;
            _isLoading = false;
            _retryCount = 0;
            _loadFailed = false;
          });
        } else {
          _scheduleRetry();
        }
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final completer = Completer<Uint8List?>();
    if (effectiveKey != null) {
      MxcImage._inFlightDownloads[effectiveKey] = completer.future;
    }

    Uint8List? loadedBytes;
    try {
      loadedBytes = await _fetchBytes();
    } on Exception catch (e, s) {
      Logs().d('MxcImage load failed', e, s);
    } catch (e, s) {
      Logs().d('Unexpected error loading mxc image', e, s);
    }

    if (effectiveKey != null) {
      MxcImage._inFlightDownloads.remove(effectiveKey);
      completer.complete(loadedBytes);
    }

    if (!mounted) return;

    if (loadedBytes != null && loadedBytes.isNotEmpty) {
      _saveToCache(loadedBytes);
      setState(() {
        _currentData = loadedBytes;
        _isLoading = false;
        _retryCount = 0;
        _loadFailed = false;
      });
    } else {
      _scheduleRetry();
    }
  }

  Future<Uint8List?> _fetchBytes() async {
    final originalUri = widget.uri;
    final originalEvent = widget.event;
    final originalIsThumbnail = widget.isThumbnail;

    final client =
        widget.client ?? widget.event?.room.client ?? Matrix.of(context).client;
    final uri = originalUri;
    final event = originalEvent;

    if (uri != null) {
      final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
      final realWidth = widget.width != null
          ? widget.width! * devicePixelRatio
          : null;
      final realHeight = widget.height != null
          ? widget.height! * devicePixelRatio
          : null;

      return await client.downloadMxcCached(
        uri,
        width: realWidth,
        height: realHeight,
        thumbnailMethod: widget.thumbnailMethod,
        isThumbnail: originalIsThumbnail,
        animated: widget.animated,
      ).timeout(const Duration(seconds: 15));
    } else if (event != null) {
      final useThumbnail = originalIsThumbnail && event.hasThumbnail;
      if (!useThumbnail &&
          !{
            MessageTypes.Image,
            MessageTypes.Sticker,
          }.contains(event.messageType)) {
        throw Exception(
          'Event of type ${event.messageType} has no thumbnail!',
        );
      }
      MatrixFile data;
      try {
        data = await event.downloadAndDecryptAttachment(
          getThumbnail: useThumbnail,
        ).timeout(const Duration(seconds: 15));
      } on Exception catch (_) {
        // Thumbnail failed (missing on server, key gap, etc.). Fall back to
        // the full-resolution original before giving up — many old media
        // only have the full file, not a generated thumbnail.
        if (useThumbnail) {
          data = await event.downloadAndDecryptAttachment(
            getThumbnail: false,
          ).timeout(const Duration(seconds: 30));
        } else {
          rethrow;
        }
      }
      if (data.detectFileType is MatrixImageFile) {
        return data.bytes;
      }
    }
    return null;
  }

  void _scheduleRetry() {
    if (!mounted) return;

    setState(() => _isLoading = false);

    _retryCount++;

    // Exponential backoff: 2s, 4s, 8s, 16s...
    final delay = widget.retryDuration * pow(2, _retryCount - 1);

    Future.delayed(delay, () {
      if (mounted && _currentData == null) {
        setState(() => _loadFailed = false);
        _load();
      }
    });
  }

  Widget _buildPlaceholder(BuildContext context) =>
      widget.placeholder?.call(context) ??
      SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      );

  Widget _buildDecryptError(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        child: InkWell(
          onTap: () {
            // The Matrix SDK already requests the missing room key during
            // downloadAndDecryptAttachment. Tapping just retries — if a key
            // arrived via backup in the meantime, the image will now decode.
            setState(() {
              _loadFailed = false;
              _retryCount = 0;
            });
            _load();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: min(widget.height ?? 64, 48),
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                'Kan niet decoderen',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) =>
      widget.placeholder?.call(context) ??
      SizedBox(
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

  @override
  Widget build(BuildContext context) {
    final data = _currentData;

    if (data == null || data.isEmpty) {
      if (_loadFailed && !_isLoading) {
        return _buildDecryptError(context);
      }
      if (_retryCount >= _maxRetries && !_isLoading) {
        return _buildError(context);
      }

      return KeyedSubtree(
        key: const ValueKey('placeholder'),
        child: _buildPlaceholder(context),
      );
    }

    final repaintKey = ValueKey<Object>([
      _effectiveCacheKey ?? widget.uri,
      widget.width,
      widget.height,
      widget.isThumbnail,
      widget.fit,
    ]);

    final imageWidget = Image.memory(
      data,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true,
      filterQuality: widget.isThumbnail
          ? (widget.width ?? 0) < 100
              ? FilterQuality.none // Scherpe pixels bij kleine thumbnails
              : FilterQuality.low
          : FilterQuality.medium,
      errorBuilder: (context, e, s) {
        Logs().d('Unable to render mxc image', e, s);
        return _buildError(context);
      },
    );

    return RepaintBoundary(
      key: repaintKey,
      child: ClipRRect(borderRadius: widget.borderRadius, child: imageWidget),
    );
  }
}

/// Simple LRU cache for image data
class _LruCache<K, V> {
  final int maxSize;
  final _map = <K, V>{};

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
