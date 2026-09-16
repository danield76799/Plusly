import 'dart:ui';

import 'package:crop_image/crop_image.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/widgets/adaptive_dialogs/image_edit_geometry.dart';

void main() {
  group('imageEditorRotationForQuarterTurns', () {
    test('maps quarter turns to CropRotation', () {
      expect(imageEditorRotationForQuarterTurns(0), CropRotation.up);
      expect(imageEditorRotationForQuarterTurns(1), CropRotation.right);
      expect(imageEditorRotationForQuarterTurns(2), CropRotation.down);
      expect(imageEditorRotationForQuarterTurns(3), CropRotation.left);
      // negative wraps
      expect(imageEditorRotationForQuarterTurns(-1), CropRotation.left);
      // large wraps
      expect(imageEditorRotationForQuarterTurns(4), CropRotation.up);
      expect(imageEditorRotationForQuarterTurns(7), CropRotation.left);
    });
  });

  group('imageEditorLocalToImagePx', () {
    test('identity when crop covers whole image and sizes match', () {
      final out = imageEditorLocalToImagePx(
        const Offset(10, 20),
        const Size(100, 100),
        const Rect.fromLTWH(0, 0, 100, 100),
      );
      expect(out, const Offset(10, 20));
    });

    test('scales logical to image pixels inside crop region', () {
      final out = imageEditorLocalToImagePx(
        const Offset(50, 25),
        const Size(100, 100),
        const Rect.fromLTWH(100, 200, 200, 200),
      );
      // scale = 200/100 = 2 → (100+100, 200+50)
      expect(out, const Offset(200, 250));
    });
  });
}
