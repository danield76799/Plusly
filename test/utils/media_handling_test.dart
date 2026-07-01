import 'package:flutter_test/flutter_test.dart';

import 'package:Pulsly/utils/clean_exif.dart' as clean_exif;

/// Tests voor EXIF/image handling utilities.
///
/// NOTE: De echte removeExifData() vereist een geldige JPEG/PNG decode,
/// wat het `image` package nodig heeft. We testen hier alleen de
/// format-detectie logica die geen decoding vereist.
void main() {
  group('Image Format Detection', () {
    test('detecteert JPEG uit magic bytes', () {
      final bytes = [0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10];
      expect(clean_exif.ExifCleaner.getImageFormat(bytes), 'JPEG');
    });

    test('detecteert PNG uit magic bytes', () {
      final bytes = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
      expect(clean_exif.ExifCleaner.getImageFormat(bytes), 'PNG');
    });

    test('detecteert GIF uit magic bytes', () {
      final bytes = [0x47, 0x49, 0x46, 0x38, 0x39, 0x61];
      expect(clean_exif.ExifCleaner.getImageFormat(bytes), 'GIF');
    });

    test('detecteert BMP uit magic bytes', () {
      final bytes = [0x42, 0x4D, 0x00, 0x00];
      expect(clean_exif.ExifCleaner.getImageFormat(bytes), 'BMP');
    });

    test('retourneert Unknown voor ongeldige bytes', () {
      expect(clean_exif.ExifCleaner.getImageFormat([0x00]), 'Unknown');
    });

    test('retourneert Unknown voor lege lijst', () {
      expect(clean_exif.ExifCleaner.getImageFormat([]), 'Unknown');
    });
  });
}
