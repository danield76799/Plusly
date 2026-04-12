import 'package:flutter/material.dart';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/download_manager/download_manager.dart';
import 'package:extera_next/utils/adaptive_bottom_sheet.dart';
import 'package:extera_next/widgets/layouts/max_width_body.dart';

class DownloadManagerView extends StatefulWidget {
  const DownloadManagerView({super.key});

  static void showDownloads(BuildContext context) {
    showAdaptiveBottomSheet(
      context: context,
      builder: (context) => const DownloadManagerView(),
    );
  }

  @override
  State<DownloadManagerView> createState() => _DownloadManagerViewState();
}

class _DownloadManagerViewState extends State<DownloadManagerView> {
  DownloadEventSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    final dlm = DownloadManager.of(context);
    _subscription = dlm.onEvent((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dlm = DownloadManager.of(context);
    final downloads = dlm.downloads;
    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.of(context).downloads, textAlign: TextAlign.center),
      ),
      body: downloads.isEmpty
          ? Center(
              child: Text(
                L10n.of(context).noDownloadsYet,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : MaxWidthBody(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: downloads.length,
                itemBuilder: (context, index) {
                  final download = downloads[index];
                  return ListTile(
                    title: Text(download.name),
                    subtitle: LinearProgressIndicator(
                      value: download.progress / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        download.cancel();
                      },
                      child: Text(L10n.of(context).cancel),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
