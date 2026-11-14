import 'package:flutter/widgets.dart';

import 'package:file_picker/file_picker.dart';
import 'package:file_selector/file_selector.dart';

import 'package:Pulsly/widgets/app_lock.dart';
import 'package:Pulsly/widgets/future_loading_dialog.dart';

Future<List<XFile>> selectFiles(
  BuildContext context, {
  String? title,
  FileType type = FileType.any,
  bool allowMultiple = false,
}) async {
  final result = await AppLock.of(context).pauseWhile(
    showFutureLoadingDialog(
      context: context,
      future: () async {
        if (allowMultiple) {
          return FilePicker.pickFiles(
            compressionQuality: 0,
            type: type,
          );
        }
        final single = await FilePicker.pickFile(
          compressionQuality: 0,
          type: type,
        );
        return single == null ? <PlatformFile>[] : [single];
      },
    ),
  );
  final picked = result.asValue?.value;
  return picked?.map((f) => f.xFile).toList() ?? <XFile>[];
}
