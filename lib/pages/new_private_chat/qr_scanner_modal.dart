import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';

class QrScannerModal extends StatefulWidget {
  final void Function(String) onScan;
  const QrScannerModal({required this.onScan, super.key});

  @override
  QrScannerModalState createState() => QrScannerModalState();
}

class QrScannerModalState extends State<QrScannerModal> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  StreamSubscription? _scanSub;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _scanSub = null;
    controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_outlined),
          onPressed: Navigator.of(context).pop,
          tooltip: L10n.of(context).close,
        ),
        title: Text(L10n.of(context).scanQrCode),
      ),
      body: Stack(
        children: [
          QRView(
            key: qrKey,
            onQRViewCreated: _onQRViewCreated,
            overlay: QrScannerOverlayShape(
              borderColor: Theme.of(context).colorScheme.primary,
              borderRadius: 10,
              borderLength: 30,
              borderWidth: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    // Workaround for QR Scanner is started in Pause mode
    // https://github.com/juliuscanute/qr_code_scanner/issues/538#issuecomment-1133883828
    if (Platform.isAndroid) {
      controller.pauseCamera();
    }
    controller.resumeCamera();
    _scanSub = controller.scannedDataStream.listen((scanData) {
      _scanSub?.cancel();
      _scanSub = null;
      if (mounted) Navigator.of(context).pop();
      final data = scanData.code;
      if (data != null) widget.onScan(data);
    });
  }
}
