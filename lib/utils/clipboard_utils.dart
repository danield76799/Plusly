import 'dart:io';
import 'dart:typed_data';

Future<Uint8List?> getImageFromClipboardLinux() async {
  final cmds = [
    ['wl-paste', '-t', 'image/png'],
    ['xclip', '-selection', 'clipboard', '-t', 'image/png', '-o'],
    ['xsel', '--clipboard', '--output', '--mime-type', 'image/png'],
  ];

  for (final cmd in cmds) {
    try {
      final result = await Process.run(
        cmd.first,
        cmd.sublist(1),
        stdoutEncoding: null,
      );
      if (result.exitCode != 0) continue;

      final Uint8List stdoutBytes = result.stdout;
      if (stdoutBytes.isNotEmpty) {
        return Uint8List.fromList(stdoutBytes);
      }
      // if (result.stdout is String && (result.stdout as String).isNotEmpty) {
      //   return Uint8List.fromList((result.stdout as String).codeUnits);
      // }
    } catch (_) {}
  }
  return null;
}
