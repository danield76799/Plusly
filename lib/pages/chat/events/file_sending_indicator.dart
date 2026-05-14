import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

class FileSendingStatusIndicator extends StatelessWidget {
  final FileSendingStatus status;
  final Color? color;
  final double? size;

  const FileSendingStatusIndicator(
    this.status, {
    this.color,
    this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      switch (status) {
        .encrypting => Icons.lock_outline,
        .generatingThumbnail => Icons.compress_outlined,
        .uploading => Icons.upload_outlined,
      },
      color: color,
      size: size,
    );
  }
}
