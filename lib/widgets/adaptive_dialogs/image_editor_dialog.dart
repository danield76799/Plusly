// SPDX-FileCopyrightText: 2019-Present Christian Kußowski
// SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
//
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Image editor for the send flow: crop, 90° rotate, horizontal mirror,
// freehand draw and free text, ported from FluffyChat's
// `send_file_dialog.dart` (commit 91fccc3c7) with an added text mode.
//
// Returns the edited image bytes (PNG) via [Navigator.pop], or null if the
// user cancelled or made no changes (in which case the original file is kept).

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'image_edit_geometry.dart';

enum _EditMode { crop, draw, text }

/// The crop (a normalized rectangle held by [CropController]), the rotation
/// (quarter turns), the drawn strokes and the placed text blocks are only
/// composited into a single full-resolution bitmap when the user saves.
class ImageEditPage extends StatefulWidget {
  final Uint8List bytes;

  const ImageEditPage({required this.bytes, super.key});

  @override
  State<ImageEditPage> createState() => _ImageEditPageState();
}

class _ImageEditPageState extends State<ImageEditPage> {
  static const List<Color> _palette = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.black,
    Colors.white,
  ];

  /// Public alias so [_ColorPalette] can iterate the same palette.
  static const List<Color> _paletteColors = _palette;

  static const Rect _fullCrop = Rect.fromLTWH(0, 0, 1, 1);

  final CropController _cropController = CropController();

  /// Source image, decoded once at full resolution. Never mutated.
  ui.Image? _image;
  Object? _decodeError;

  _EditMode _mode = _EditMode.crop;

  /// Clockwise quarter turns applied on top of the crop. Kept separate from the
  /// crop controller so the crop rectangle always stays in the un-rotated image
  /// coordinate space, which keeps all stroke/text math rotation-free.
  int _quarterTurns = 0;

  /// Strokes, stored in source-image pixel coordinates (crop- and
  /// rotation-independent) so they stay anchored to the image content.
  final List<_Stroke> _strokes = [];
  Color _color = Colors.red;
  double _strokeWidth = 4.0;
  bool _eraser = false;
  bool _saving = false;

  /// Text blocks, stored in source-image pixel coordinates (crop- and
  /// rotation-independent). Each entry keeps its own colour, size and
  /// font-scale so a later resize/zoom does not move or rescale placed text.
  final List<_TextBlock> _texts = [];

  /// View transform for the draw/text surface (two-finger pinch to zoom).
  /// Drawing happens with one finger; two fingers zoom via [InteractiveViewer].
  final TransformationController _drawTransform = TransformationController();

  /// Horizontal mirror (flip), applied together with rotation at save time.
  bool _mirror = false;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void dispose() {
    _cropController.dispose();
    _drawTransform.dispose();
    // Note: [_image] is intentionally not disposed here. A save may still be
    // rasterizing from it asynchronously when this page is popped; the engine's
    // finalizer reclaims the decoded image once it is no longer referenced.
    super.dispose();
  }

  Future<void> _decode() async {
    try {
      final codec = await ui.instantiateImageCodec(widget.bytes);
      final frame = await codec.getNextFrame();
      if (!mounted) {
        frame.image.dispose();
        return;
      }
      setState(() => _image = frame.image);
    } catch (e, s) {
      Logs().w('Unable to decode image for editing', e, s);
      if (mounted) setState(() => _decodeError = e);
    }
  }

  Rect _cropRectPx(ui.Image image) {
    final c = _cropController.crop;
    return Rect.fromLTRB(
      c.left * image.width,
      c.top * image.height,
      c.right * image.width,
      c.bottom * image.height,
    );
  }

  bool get _hasEdits =>
      _strokes.isNotEmpty ||
      _texts.isNotEmpty ||
      _quarterTurns % 4 != 0 ||
      _mirror ||
      _cropController.crop != _fullCrop;

  void _rotate(int direction) {
    if (_saving) return;
    setState(() => _quarterTurns += direction);
  }

  void _toggleMirror() {
    if (_saving) return;
    setState(() => _mirror = !_mirror);
  }

  /// Returns a horizontally mirrored copy of [image] (lossless, axis-aligned).
  Future<ui.Image> _flippedHorizontally(ui.Image image) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.translate(image.width.toDouble(), 0);
    canvas.scale(-1, 1);
    canvas.drawImage(image, Offset.zero, Paint());
    return recorder.endRecording().toImage(image.width, image.height);
  }

  /// Composites the current edits into a single full-resolution PNG.
  Future<Uint8List?> _compose(ui.Image image) async {
    // 1. Bake strokes AND text onto the full-resolution image (only if any).
    var painted = image;
    if (_strokes.isNotEmpty || _texts.isNotEmpty) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final size = Size(image.width.toDouble(), image.height.toDouble());
      canvas.drawImage(image, Offset.zero, Paint());
      _OverlayPainter(
        strokes: _strokes,
        texts: _texts,
        sourceRect: Offset.zero & size,
      ).paint(canvas, size);
      painted = await recorder.endRecording().toImage(
        image.width,
        image.height,
      );
    }

    // 2. Crop (without rotation — the crop rect lives in the un-rotated frame).
    final cropped = await CropController.getCroppedBitmap(
      crop: _cropController.crop,
      rotation: CropRotation.up,
      image: painted,
    );
    if (!identical(painted, image)) painted.dispose();

    // 3. Mirror, then rotation — both lossless and in the same order as the
    //    on-screen preview (flip inside, rotation outside).
    var staged = cropped;
    if (_mirror) {
      staged = await _flippedHorizontally(cropped);
      cropped.dispose();
    }

    final rotation = imageEditorRotationForQuarterTurns(_quarterTurns);
    var output = staged;
    if (rotation != CropRotation.up) {
      output = await CropController.getCroppedBitmap(
        crop: _fullCrop,
        rotation: rotation,
        image: staged,
      );
      staged.dispose();
    }

    // 4. Encode to PNG.
    final data = await output.toByteData(format: ui.ImageByteFormat.png);
    output.dispose();
    return data?.buffer.asUint8List();
  }

  Future<void> _save() async {
    if (_saving) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final image = _image;
    // Nothing was changed: keep the original file untouched (pop with null).
    if (image == null || !_hasEdits) {
      navigator.pop();
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await _compose(image);
      if (!mounted) return;
      navigator.pop(result);
    } catch (e, s) {
      Logs().w('Unable to save edited image', e, s);
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  /// Opens a text-input dialog and places/updates a text block on the image.
  Future<void> _addOrEditText([_TextBlock? existing]) async {
    if (_saving) return;
    final image = _image;
    if (image == null) return;
    final l10n = L10n.of(context);
    final controller = TextEditingController(text: existing?.text ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(l10n.addText),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(hintText: l10n.enterText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (result == null) return;
    if (result.isEmpty) {
      // Empty text on an existing block = delete it.
      setState(() => _texts.remove(existing));
      return;
    }
    setState(() {
      if (existing != null) {
        existing
          ..text = result
          ..color = _color
          ..fontSizePx = _textFontSizePx(image);
      } else {
        _texts.add(
          _TextBlock(
            text: result,
            centerPx: _cropRectPx(image).center,
            color: _color,
            fontSizePx: _textFontSizePx(image),
          ),
        );
      }
    });
  }

  /// Default font size for a new text block: 8% of the crop height, so text
  /// reads well regardless of the image resolution.
  double _textFontSizePx(ui.Image image) =>
      (_cropRectPx(image).height * 0.08).clamp(12.0, 200.0);

  void _selectColor(Color color) {
    setState(() {
      _color = color;
      _eraser = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final theme = Theme.of(context);
    final image = _image;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editImage),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              tooltip: l10n.save,
              icon: const Icon(Icons.check),
              onPressed: image == null ? null : _save,
            ),
        ],
        bottom: image == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SegmentedButton<_EditMode>(
                    segments: [
                      ButtonSegment(
                        value: _EditMode.crop,
                        icon: const Icon(Icons.crop),
                        label: Text(l10n.crop),
                      ),
                      ButtonSegment(
                        value: _EditMode.draw,
                        icon: const Icon(Icons.brush_outlined),
                        label: Text(l10n.draw),
                      ),
                      ButtonSegment(
                        value: _EditMode.text,
                        icon: const Icon(Icons.text_fields),
                        label: Text(l10n.addText),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: _saving
                        ? null
                        : (s) => setState(() {
                            _mode = s.first;
                            // Start each draw session at the un-zoomed fit.
                            _drawTransform.value = Matrix4.identity();
                          }),
                  ),
                ),
              ),
      ),
      body: _decodeError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.broken_image_outlined, size: 64),
                    const SizedBox(height: 16),
                    Text(l10n.oopsSomethingWentWrong),
                  ],
                ),
              ),
            )
          : image == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Column(
              children: [
                Expanded(
                  // Inset from the screen edges so dragging crop handles or
                  // drawing near the border doesn't trigger the system back-
                  // swipe gesture.
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12.0,
                    ),
                    child: RotatedBox(
                      quarterTurns: _quarterTurns,
                      child: Transform.flip(
                        flipX: _mirror,
                        child: _buildEditSurface(image),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: _buildBottomBar(image, l10n, theme),
                ),
              ],
            ),
    );
  }

  Widget _buildEditSurface(ui.Image image) {
    switch (_mode) {
      case _EditMode.crop:
        return CropImage(
          controller: _cropController,
          // Decode a separate image from the original bytes for the crop
          // widget. Sharing our [_image] via a provider is unsafe: when
          // CropImage is unmounted (switching to draw), its Image widget
          // disposes the underlying ui.Image — which would be our [_image],
          // breaking draw mode and save.
          image: Image.memory(widget.bytes),
          overlayPainter: _texts.isEmpty && _strokes.isEmpty
              ? null
              : _OverlayPainter(
                  strokes: _strokes,
                  texts: _texts,
                  sourceRect:
                      Offset.zero &
                      Size(image.width.toDouble(), image.height.toDouble()),
                ),
        );
      case _EditMode.draw:
        return _DrawSurface(
          image: image,
          cropPx: _cropRectPx(image),
          strokes: _strokes,
          color: _color,
          strokeWidth: _strokeWidth,
          eraser: _eraser,
          transformController: _drawTransform,
          onStrokesChanged: () => setState(() {}),
        );
      case _EditMode.text:
        return _TextSurface(
          image: image,
          cropPx: _cropRectPx(image),
          texts: _texts,
          transformController: _drawTransform,
          onTap: (centerPx) async {
            final existing = _texts.cast<_TextBlock?>().firstWhere(
                  (t) => (t!.centerPx - centerPx).distance < 60,
                  orElse: () => null,
                );
            await _addOrEditText(existing);
          },
        );
    }
  }

  Widget _buildBottomBar(ui.Image image, L10n l10n, ThemeData theme) {
    switch (_mode) {
      case _EditMode.crop:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                tooltip: l10n.rotateLeft,
                icon: const Icon(Icons.rotate_left),
                onPressed: () => _rotate(-1),
              ),
              IconButton(
                tooltip: l10n.rotateRight,
                icon: const Icon(Icons.rotate_right),
                onPressed: () => _rotate(1),
              ),
              IconButton(
                tooltip: l10n.mirror,
                isSelected: _mirror,
                icon: const Icon(Icons.flip),
                onPressed: _toggleMirror,
              ),
            ],
          ),
        );
      case _EditMode.draw:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l10n.draw,
                  isSelected: !_eraser,
                  icon: const Icon(Icons.brush_outlined),
                  selectedIcon: const Icon(Icons.brush),
                  onPressed: () => setState(() => _eraser = false),
                ),
                IconButton(
                  tooltip: l10n.eraser,
                  isSelected: _eraser,
                  icon: const Icon(
                    Icons.cleaning_services_outlined,
                  ),
                  selectedIcon: const Icon(
                    Icons.cleaning_services,
                  ),
                  onPressed: () => setState(() => _eraser = true),
                ),
                Expanded(
                  child: Slider(
                    min: 1,
                    max: 30,
                    value: _strokeWidth,
                    onChanged: (v) => setState(() => _strokeWidth = v),
                  ),
                ),
                IconButton(
                  tooltip: l10n.undo,
                  icon: const Icon(Icons.undo),
                  onPressed: _strokes.isEmpty
                      ? null
                      : () => setState(_strokes.removeLast),
                ),
                IconButton(
                  tooltip: l10n.clear,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _strokes.isEmpty
                      ? null
                      : () => setState(_strokes.clear),
                ),
              ],
            ),
            _ColorPalette(theme: theme, state: this),
          ],
        );
      case _EditMode.text:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: _texts.isEmpty
                      ? null
                      : () => setState(_texts.clear),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.clear),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _addOrEditText(),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.addText),
                  ),
                ),
              ],
            ),
            _ColorPalette(theme: theme, state: this),
          ],
        );
    }
  }
}

/// Shared horizontal colour-picker strip for draw and text modes.
/// Reads/writes the parent editor state via an InheritedWidget-like lookup:
/// the palette is always a direct child of the editor page build tree.
class _ColorPalette extends StatelessWidget {
  final ThemeData theme;
  final _ImageEditPageState state;
  const _ColorPalette({required this.theme, required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: [
          for (final color in _ImageEditPageState._paletteColors)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onTap: () => state._selectColor(color),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: !state._eraser && state._color == color
                          ? theme.colorScheme.primary
                          : Colors.grey,
                      width: !state._eraser && state._color == color ? 3 : 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Freehand drawing surface with pinch-to-zoom.
///
/// This is a widget class (not a helper method on the parent state) so it gets
/// its own [BuildContext] and its own rebuild boundary — a pointer move only
/// invalidates this subtree, not the whole editor page.
///
/// Persistent editor state (the stroke list, current colour/width/eraser flag,
/// zoom transform) lives on the parent and is passed in as props; only the
/// pure gesture state (active stroke, currently-down pointers, multi-touch
/// lock) lives inside this widget. [onStrokesChanged] is called whenever a
/// stroke is added or discarded so the parent can rebuild consumers like the
/// undo/clear button enable state and the crop overlay preview.
class _DrawSurface extends StatefulWidget {
  final ui.Image image;
  final Rect cropPx;
  final List<_Stroke> strokes;
  final Color color;
  final double strokeWidth;
  final bool eraser;
  final TransformationController transformController;
  final VoidCallback onStrokesChanged;

  const _DrawSurface({
    required this.image,
    required this.cropPx,
    required this.strokes,
    required this.color,
    required this.strokeWidth,
    required this.eraser,
    required this.transformController,
    required this.onStrokesChanged,
  });

  @override
  State<_DrawSurface> createState() => _DrawSurfaceState();
}

class _DrawSurfaceState extends State<_DrawSurface> {
  /// The stroke the current one-finger gesture is drawing, or null when no
  /// stroke is active (e.g. during a two-finger zoom). Held by reference so a
  /// stroke can be fully discarded if the gesture turns into a pinch.
  _Stroke? _activeStroke;

  /// Currently active (touching) pointer ids on the draw surface.
  final Set<int> _pointers = {};

  /// True once a second finger has touched, until all fingers lift again. While
  /// set, drawing is suppressed so a pinch never draws — not at its start and
  /// not when lifting back down to one finger on release.
  bool _multiTouch = false;

  /// Removes a lifted pointer. Once all fingers are up, the multi-touch lock is
  /// released so a fresh single touch can draw again.
  void _endPointer(int pointer) {
    _pointers.remove(pointer);
    if (_pointers.isEmpty) {
      setState(() {
        _multiTouch = false;
        _activeStroke = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropPx = widget.cropPx;
    return Center(
      child: AspectRatio(
        aspectRatio: cropPx.width / cropPx.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            // Map a pointer position (viewport pixels) to source-image pixels,
            // going through the current zoom transform first.
            Offset toImagePx(Offset viewportPoint) => imageEditorLocalToImagePx(
              widget.transformController.toScene(viewportPoint),
              size,
              cropPx,
            );
            // Drawing is driven from raw pointer events (not
            // InteractiveViewer's gesture phases) so the real finger count
            // decides draw vs. zoom. The Listener is passive: it never enters
            // the gesture arena, so InteractiveViewer below still handles the
            // two-finger pinch.
            return Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) {
                _pointers.add(e.pointer);
                if (_pointers.length >= 2) {
                  // A pinch: this gesture is a zoom. Drop any stroke it started
                  // and block drawing until every finger has lifted again.
                  _multiTouch = true;
                  final active = _activeStroke;
                  if (active != null) {
                    widget.strokes.remove(active);
                    setState(() => _activeStroke = null);
                    widget.onStrokesChanged();
                  }
                  return;
                }
                if (_multiTouch) return;
                final stroke = _Stroke(
                  color: widget.color,
                  width: widget.strokeWidth * (cropPx.width / size.width),
                  eraser: widget.eraser,
                  points: [toImagePx(e.localPosition)],
                );
                widget.strokes.add(stroke);
                setState(() => _activeStroke = stroke);
                widget.onStrokesChanged();
              },
              onPointerMove: (e) {
                final active = _activeStroke;
                if (active == null || _multiTouch || _pointers.length != 1) {
                  return;
                }
                setState(() => active.points.add(toImagePx(e.localPosition)));
              },
              onPointerUp: (e) => _endPointer(e.pointer),
              onPointerCancel: (e) => _endPointer(e.pointer),
              child: InteractiveViewer(
                transformationController: widget.transformController,
                // One finger draws (via the Listener); two fingers pinch-zoom.
                panEnabled: false,
                minScale: 1,
                maxScale: 8,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(
                      painter: _CroppedImagePainter(
                        image: widget.image,
                        sourceRect: cropPx,
                      ),
                    ),
                    CustomPaint(
                      painter: _OverlayPainter(
                        strokes: widget.strokes,
                        texts: const [],
                        sourceRect: cropPx,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Tap-to-place / tap-to-edit surface for text blocks, with pinch-to-zoom.
/// Shares the same coordinate pipeline as [_DrawSurface].
class _TextSurface extends StatelessWidget {
  final ui.Image image;
  final Rect cropPx;
  final List<_TextBlock> texts;
  final TransformationController transformController;
  final ValueChanged<Offset> onTap;

  const _TextSurface({
    required this.image,
    required this.cropPx,
    required this.texts,
    required this.transformController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: cropPx.width / cropPx.height,
        child: InteractiveViewer(
          transformationController: transformController,
          panEnabled: false,
          minScale: 1,
          maxScale: 8,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _CroppedImagePainter(
                  image: image,
                  sourceRect: cropPx,
                ),
              ),
              CustomPaint(
                painter: _OverlayPainter(
                  strokes: const [],
                  texts: texts,
                  sourceRect: cropPx,
                ),
              ),
              // Tap target layer: converts taps to source-image coordinates.
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(
                      constraints.maxWidth,
                      constraints.maxHeight,
                    );
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapUp: (details) {
                        final scene =
                            transformController.toScene(details.localPosition);
                        onTap(
                          imageEditorLocalToImagePx(scene, size, cropPx),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stroke {
  final Color color;

  /// Stroke width, in source-image pixels.
  final double width;
  final bool eraser;

  /// Points, in source-image pixel coordinates.
  final List<Offset> points;

  _Stroke({
    required this.color,
    required this.width,
    required this.eraser,
    required this.points,
  });
}

/// A placed text block, in source-image pixel coordinates (crop- and
/// rotation-independent) so it stays anchored to the image content.
class _TextBlock {
  String text;

  /// Center of the text, in source-image pixels.
  Offset centerPx;
  Color color;

  /// Font size in source-image pixels (scales with the image, not the screen).
  double fontSizePx;

  _TextBlock({
    required this.text,
    required this.centerPx,
    required this.color,
    required this.fontSizePx,
  });
}

/// Paints the [sourceRect] region (in image pixels) of [image] to fill the
/// canvas. Only repaints when the image or the crop changes, so freehand
/// drawing doesn't continuously re-rasterize the background.
class _CroppedImagePainter extends CustomPainter {
  final ui.Image image;
  final Rect sourceRect;

  const _CroppedImagePainter({
    required this.image,
    required this.sourceRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      sourceRect,
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(covariant _CroppedImagePainter oldDelegate) =>
      oldDelegate.image != image || oldDelegate.sourceRect != sourceRect;
}

/// Paints freehand [strokes] and placed [texts] (stored in source-image pixel
/// coordinates) onto a canvas that shows the image region [sourceRect] scaled
/// to fill the canvas.
class _OverlayPainter extends CustomPainter {
  final List<_Stroke> strokes;
  final List<_TextBlock> texts;
  final Rect sourceRect;

  const _OverlayPainter({
    required this.strokes,
    required this.texts,
    required this.sourceRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty && texts.isEmpty) return;
    final scale = size.width / sourceRect.width;
    // saveLayer so eraser strokes (BlendMode.clear) only erase prior strokes
    // within this layer, not whatever is painted below it.
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.translate(-sourceRect.left * scale, -sourceRect.top * scale);
    canvas.scale(scale);
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      if (stroke.eraser) {
        paint
          ..color = const Color(0xFF000000)
          ..blendMode = BlendMode.clear;
      } else {
        paint.color = stroke.color;
      }
      // A single point (a tap) renders as a dot.
      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          stroke.width / 2,
          Paint()
            ..color = paint.color
            ..blendMode = paint.blendMode
            ..style = PaintingStyle.fill,
        );
        continue;
      }
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final p in stroke.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
    for (final text in texts) {
      final builder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontSize: text.fontSizePx,
          fontFamily: 'Roboto',
        ),
      )
        ..pushStyle(
          ui.TextStyle(
            color: text.color,
            shadows: [
              const Shadow(
                color: Color(0x66000000),
                blurRadius: 4,
              ),
            ],
          ),
        )
        ..addText(text.text);
      final paragraph = builder.build();
      paragraph.layout(ui.ParagraphConstraints(width: sourceRect.width));
      canvas.drawParagraph(
        paragraph,
        text.centerPx - Offset(paragraph.width / 2, paragraph.height / 2),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OverlayPainter oldDelegate) => true;
}
/// Opens the lightweight image editor as an adaptive fullscreen dialog.
/// Returns the edited PNG bytes, or null when cancelled / unchanged.
Future<Uint8List?> showImageEditor({
  required BuildContext context,
  required Uint8List byteArray,
}) {
  return showDialog<Uint8List?>(
    context: context,
    useSafeArea: true,
    useRootNavigator: true,
    builder: (_) => ImageEditPage(bytes: byteArray),
  );
}
