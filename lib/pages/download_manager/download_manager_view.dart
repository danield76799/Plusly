import 'package:extera_next/pages/download_manager/download_manager.dart';
import 'package:flutter/material.dart';

class DownloadManagerView extends StatelessWidget {
  final DownloadManagerController controller;
  const DownloadManagerView(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: controller.downloads.length,
        itemBuilder: (context, index) {
          final download = controller.downloads[index];
          return ListTile(
            title: Text(download.name),
            subtitle: LinearProgressIndicator(
              value: download.progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            trailing: ElevatedButton(
              onPressed: () {
                // "Cancel" button action can be added here
              },
              child: Text("Cancel"),
            ),
          );
        },
      ),
    );
  }
}
