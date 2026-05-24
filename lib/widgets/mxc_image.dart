import 'dart:collection';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/utils/client_download_content_extension.dart';
import 'package:Pulsly/utils/matrix_sdk_extensions/matrix_file_extension.dart';
import 'package:Pulsly/widgets/matrix.dart';

/// Semaphore to limit concurrent image downloads and prevent server overload
class ImageDownloadSemaphore {
  static const int maxConcurrentDownloads = 4;
  static int _activeDownloads = 0;
  static final Queue<_PendingDownload> _pendingQueue = Queue();

  /// Acquire a download slot. Returns true if download can proceed immediately.
  /// If false is returned, the download has been queued and will be started when a slot is available.
  static bool tryAcquire(void Function() onCanProceed) {
    if (_activeDownloads < maxConcurrentDownloads) {
      _activeDownloads++;
      return true;
    }
    _pendingQueue.add(_PendingDownload(onCanProceed));
    return false;
  }

  /// Release a download slot and start next pending download if any
  static void release() {
    if (_pendingQueue.isNotEmpty) {
      final next = _pendingQueue.removeFirst();
      next.onCanProceed();
    } else {
      _activeDownloads--;
    }
  }

  static int get activeDownloads => _activeDownloads;
  static int get pendingCount => _pendingQueue.length;
}

class _PendingDownload {
  final void Function() onCanProceed;
  _PendingDownload(this.onCanProceed);
}

class MxcImage extends StatefulWidget {
  final Uri? uri;
  final Event? event;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final bool isThumbnail;
  final bool animated;
  final Duration retryDuration;
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
    this.retryDuration = const Duration(seconds: 2),
    this.thumbnailMethod = ThumbnailMethod.scale,
    this.cacheKey,
    this.client,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  @override
  State<MxcImage> createState() => _MxcImageState();
}

class _MxcImageState extends State<MxcImage> {
  // LRU cache with max 200 entries to prevent unbounded memory growth
  static const int _maxCacheSize = 200;
  static final LinkedHashMap<String, Uint8List> _imageDataCache =
      LinkedHashMap<String, Uint8List>();

  Uint8List? _currentData;
  bool _isLoading = false;
  bool _isQueued = false;

  // FIX: Track retry attempts to prevent infinite loops
  int _retryCount = 0;
  static const int _maxRetries = 3;

  @override
  void initState() {
    super.initState();
    _currentData = _getFromCache();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_currentData == null && !_isLoading && !_isQueued) {
      _load();
    }
  }

  @override
  void didUpdateWidget(MxcImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uri != widget.uri ||
        oldWidget.event != widget.event ||
        oldWidget.cacheKey != widget.cacheKey) {
      // Reset retry count on widget update
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
    if (widget.cacheKey != null) {
      final data = _imageDataCache.remove(widget.cacheKey);
      if (data != null) {
        // Re-insert to mark as most recently used
        _imageDataCache[widget.cacheKey!] = data;
      }
      return data;
    }
    return null;
  }

  void _saveToCache(Uint8List data) {
    if (widget.cacheKey != null) {
      // Move to end (most recently used) if already exists
      _imageDataCache.remove(widget.cacheKey!);
      _imageDataCache[widget.cacheKey!] = data;
      // Evict oldest entries if over capacity
      while (_imageDataCache.length > _maxCacheSize) {
        _imageDataCache.remove(_imageDataCache.keys.first);
      }
    }
  }

  Future<void> _load() async {
    if (_isLoading || !mounted) return;

    // Check if we've exceeded max retries
    if (_retryCount >= _maxRetries) {
      Logs().w(
        'MxcImage failed to load after $_maxRetries attempts: ${widget.uri}',
      );
      return;
    }

    // Try to acquire a download slot
    bool acquired = false;
    void startDownload() {
      acquired = true;
      _doLoad();
    }

    if (!ImageDownloadSemaphore.tryAcquire(startDownload)) {
      // Queued - will be called when slot available
      setState(() {
        _isLoading = true;
        _isQueued = true;
      });
      return;
    }

    // Only start download if we acquired a slot
    if (!acquired) return;
    _doLoad();
  }

  Future<void> _doLoad() async {
    setState(() {
      _isLoading = true;
      _isQueued = false;
    });

    try {
      final client =
          widget.client ??
          widget.event?.room.client ??
          Matrix.of(context).client;
      final uri = widget.uri;
      final event = widget.event;

      Uint8List? loadedBytes;

      if (uri != null) {
        final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
        final realWidth = widget.width != null
            ? widget.width! * devicePixelRatio
            : null;
        final realHeight = widget.height != null
            ? widget.height! * devicePixelRatio
            : null;

        loadedBytes = await client.downloadMxcCached(
          uri,
          width: realWidth ?? 800,
          height: realHeight ?? 600,
          thumbnailMethod: widget.thumbnailMethod,
          isThumbnail: widget.isThumbnail,
          animated: widget.animated,
        );
      } else if (event != null) {
        final data = await event.downloadAndDecryptAttachment(
          getThumbnail: widget.isThumbnail,
        );
        if (data.detectFileType is MatrixImageFile) {
          loadedBytes = data.bytes;
        }
      }

      if (!mounted) {
        ImageDownloadSemaphore.release();
        return;
      }

      if (loadedBytes != null && loadedBytes.isNotEmpty) {
        _saveToCache(loadedBytes);
        setState(() {
          _currentData = loadedBytes;
          _isLoading = false;
          _retryCount = 0; // Success! Reset retries.
        });
      } else {
        _scheduleRetry();
        return; // Don't release semaphore - retry will call _doLoad again
      }
    } on IOException catch (_) {
      _scheduleRetry();
      return; // Don't release semaphore - retry will call _doLoad again
    } catch (e, s) {
      Logs().d('Unexpected error loading mxc image', e, s);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
    
    // Release semaphore on success or final failure
    ImageDownloadSemaphore.release();
  }

  void _scheduleRetry() {
    if (!mounted) {
      ImageDownloadSemaphore.release();
      return;
    }

    setState(() => _isLoading = false);

    _retryCount++;

    // Exponential backoff: 2s, 4s, 8s, 16s...
    final delay = widget.retryDuration * pow(2, _retryCount - 1);

    Future.delayed(delay, () {
      // Release semaphore before retry
      ImageDownloadSemaphore.release();
      if (mounted && _currentData == null) {
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

    // If we have no data and have given up retrying, show error
    if (data == null || data.isEmpty) {
      if (_retryCount >= _maxRetries && !_isLoading) {
        return _buildError(context);
      }

      return KeyedSubtree(
        key: const ValueKey('placeholder'),
        child: _buildPlaceholder(context),
      );
    }

    final imageWidget = Image.memory(
      data,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      gaplessPlayback: true,
      filterQuality: widget.isThumbnail
          ? FilterQuality.low
          : FilterQuality.medium,
      errorBuilder: (context, e, s) {
        Logs().d('Unable to render mxc image bytes', e, s);
        return _buildError(context);
      },
    );

    return ClipRRect(
      key: ValueKey(widget.cacheKey ?? widget.uri),
      borderRadius: widget.borderRadius,
      child: imageWidget,
    );
  }
}
