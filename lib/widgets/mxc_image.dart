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
  int _retryCount = 0;
  static const int _maxRetries = 2;

  /// The last failure type so we can show a helpful retry tile.
  _ImageFailureType _failureType = _ImageFailureType.none;

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
    final oldKey = oldWidget.cacheKey ??
        oldWidget.event?.eventId ??
        oldWidget.uri?.toString();
    final newKey = widget.cacheKey ??
        widget.event?.eventId ??
        widget.uri?.toString();
    if (oldKey != newKey) {
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

  void _removeFromCache() {
    final key = _effectiveCacheKey;
    if (key != null) {
      MxcImage._imageDataCache.remove(key);
    }
  }

  Future<void> _load() async {
    if (_isLoading || !mounted) return;

    if (_retryCount >= _maxRetries) {
      Logs().w(
        'MxcImage failed after $_maxRetries attempts: ${widget.uri ?? widget.event?.eventId}',
      );
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    final originalUri = widget.uri;
    final originalEvent = widget.event;
    final originalCacheKey = widget.cacheKey;

    setState(() => _isLoading = true);

    Uint8List? loadedBytes;
    var failureType = _ImageFailureType.unknown;

    try {
      loadedBytes = await _fetchBytes();
    } on DecryptException catch (e, s) {
      failureType = _ImageFailureType.decrypt;
      Logs().w('MxcImage decrypt failed', e, s);
    } on TimeoutException catch (e, s) {
      failureType = _ImageFailureType.timeout;
      Logs().w('MxcImage timed out', e, s);
    } on Exception catch (e, s) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('status code') ||
          msg.contains('404') ||
          msg.contains('403') ||
          msg.contains('failed to download')) {
        failureType = _ImageFailureType.serverError;
      }
      Logs().w('MxcImage load failed', e, s);
    }

    if (!mounted) return;

    if (originalUri != widget.uri ||
        originalEvent != widget.event ||
        originalCacheKey != widget.cacheKey) {
      return;
    }

    if (loadedBytes != null && loadedBytes.isNotEmpty) {
      _saveToCache(loadedBytes);
      setState(() {
        _currentData = loadedBytes;
        _isLoading = false;
        _retryCount = 0;
        _failureType = _ImageFailureType.none;
      });
      return;
    }

    // If we got here the load did not produce usable bytes.
    _retryCount++;
    setState(() {
      _isLoading = false;
      _failureType = failureType;
    });

    if (_retryCount >= _maxRetries) {
      // Final state: show retry tile.
      return;
    }

    final delay = widget.retryDuration * pow(2, _retryCount - 1);
    Future.delayed(delay, () {
      if (mounted && _currentData == null) {
        _load();
      }
    });
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
      ).timeout(const Duration(seconds: 30));
    }

    if (event != null) {
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

      try {
        final data = await event.downloadAndDecryptAttachment(
          getThumbnail: useThumbnail,
        ).timeout(const Duration(seconds: 60));
        if (data.detectFileType is MatrixImageFile) {
          return data.bytes;
        }
      } on MatrixException catch (e) {
        // Real decryption/key gap: Matrix tells us it could not decrypt.
        throw DecryptException(e.toString());
      } on TimeoutException {
        // Thumbnail decryption timed out. Try the full-resolution original
        // before giving up; large old media may take longer to fetch/keys.
        if (useThumbnail) {
          final data = await event.downloadAndDecryptAttachment(
            getThumbnail: false,
          ).timeout(const Duration(seconds: 60));
          if (data.detectFileType is MatrixImageFile) {
            return data.bytes;
          }
        }
        rethrow;
      }
    }
    return null;
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

  Widget _buildRetryTile(BuildContext context) {
    final theme = Theme.of(context);
    final String label;
    final IconData icon;
    switch (_failureType) {
      case _ImageFailureType.serverError:
        label = 'Foto niet beschikbaar';
        icon = Icons.image_not_supported_outlined;
      case _ImageFailureType.timeout:
        label = 'Laden duurt te lang, tik om opnieuw';
        icon = Icons.refresh;
      case _ImageFailureType.decrypt:
        label = 'Kan niet decoderen, tik om opnieuw';
        icon = Icons.lock_outline_rounded;
      default:
        label = 'Laden mislukt, tik om opnieuw';
        icon = Icons.refresh;
    }
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        child: InkWell(
          onTap: () {
            _removeFromCache();
            setState(() {
              _retryCount = 0;
              _isLoading = false;
              _failureType = _ImageFailureType.none;
            });
            _load();
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: min(widget.height ?? 64, 48),
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
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

  @override
  Widget build(BuildContext context) {
    final data = _currentData;

    if (data == null || data.isEmpty) {
      if (_retryCount >= _maxRetries && !_isLoading) {
        return _buildRetryTile(context);
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
              ? FilterQuality.none
              : FilterQuality.low
          : FilterQuality.medium,
      errorBuilder: (context, e, s) {
        Logs().w('Unable to render mxc image, clearing cache', e, s);
        _removeFromCache();
        return _buildRetryTile(context);
      },
    );

    return RepaintBoundary(
      key: repaintKey,
      child: ClipRRect(borderRadius: widget.borderRadius, child: imageWidget),
    );
  }
}

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

  void remove(K key) => _map.remove(key);

  void clear() => _map.clear();
}

class DecryptException implements Exception {
  final String message;
  DecryptException(this.message);
  @override
  String toString() => message;
}

enum _ImageFailureType { none, unknown, timeout, decrypt, serverError }
