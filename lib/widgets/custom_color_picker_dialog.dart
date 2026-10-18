import 'package:flutter/material.dart';

/// Een vrije kleurenkiezer (hue/saturation/value + hex-veld) waarmee de
/// gebruiker élke accentkleur kan kiezen, niet alleen de vaste Material-
/// kleuren. Retourneert de gekozen [Color] via [onColorSelected], of sluit
/// zonder wijziging bij [onCancel].
class CustomColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final void Function(Color) onColorSelected;
  final VoidCallback onCancel;

  const CustomColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onColorSelected,
    required this.onCancel,
  });

  @override
  State<CustomColorPickerDialog> createState() =>
      _CustomColorPickerDialogState();
}

class _CustomColorPickerDialogState extends State<CustomColorPickerDialog> {
  late HSVColor _hsv;

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor);
  }

  void _updateFromHsv(HSVColor value) {
    setState(() => _hsv = value);
  }

  void _onHexSubmitted(String raw) {
    var text = raw.trim();
    if (text.startsWith('#')) text = text.substring(1);
    if (text.length == 6) {
      final parsed = int.tryParse(text, radix: 16);
      if (parsed != null) {
        setState(() {
          _hsv = HSVColor.fromColor(Color(0xFF000000 | parsed));
        });
      }
    }
  }

  String get _hexLabel {
    final c = _hsv.toColor();
    final r = (c.r * 255).round();
    final g = (c.g * 255).round();
    final b = (c.b * 255).round();
    return '#${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _hsv.toColor();
    return AlertDialog(
      title: const Text('Aangepaste kleur'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
          ),
          const SizedBox(height: 16),
          _labeledSlider(
            label: 'Kleur',
            slider: Slider(
              value: _hsv.hue,
              min: 0,
              max: 360,
              onChanged: (v) =>
                  _updateFromHsv(_hsv.withHue(v)),
            ),
          ),
          _labeledSlider(
            label: 'Verzadiging',
            slider: Slider(
              value: _hsv.saturation,
              min: 0,
              max: 1,
              onChanged: (v) =>
                  _updateFromHsv(_hsv.withSaturation(v)),
            ),
          ),
          _labeledSlider(
            label: 'Helderheid',
            slider: Slider(
              value: _hsv.value,
              min: 0,
              max: 1,
              onChanged: (v) => _updateFromHsv(_hsv.withValue(v)),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              labelText: 'Hex-code',
              hintText: 'RRGGBB',
              border: const OutlineInputBorder(),
            ),
            onSubmitted: _onHexSubmitted,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _hexLabel,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => widget.onColorSelected(color),
          child: const Text('Toepassen'),
        ),
      ],
    );
  }

  Widget _labeledSlider({
    required String label,
    required Widget slider,
  }) {
    return Row(
      children: [
        SizedBox(width: 88, child: Text(label)),
        Expanded(child: slider),
      ],
    );
  }
}
