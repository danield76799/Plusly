import 'dart:io';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/download_manager/download_manager_view.dart';
import 'package:extera_next/widgets/matrix.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';

class Download {
  final String url;
  final String name;
  final BuildContext context;
  late Future<Response<dynamic>> response;
  late int receivedBytes = 0;
  late int totalBytes = 1;
  late double progress = 0;
  Download(this.context, this.url, this.name);

  void start() async {
    try {
      final mx = Matrix.of(context).client;
      final directory = await getExternalStorageDirectory();
      final downloadPath =
          directory != null ? "${directory.path}/Download" : null;

      if (downloadPath != null) {
        // Create Dio instance
        final dio = Dio();
        // Progress status variables

        // Download the file
        response = dio.download(
          url,
          "$downloadPath/$name",
          onReceiveProgress: (received, total) {
            receivedBytes = received;
            totalBytes = total;
            progress = (receivedBytes / totalBytes) * 100;
            print("Download progress: $progress%");
          },
          options: Options(
              responseType: ResponseType.bytes,
              headers: {'authorization': "Bearer ${mx.accessToken}"}),
        );
        print("Download completed and saved to $downloadPath/$name");
      }
    } catch (e) {
      print("Error during download: $e");
    }
  }
}

class DownloadManager extends StatefulWidget {
  final BuildContext context;

  const DownloadManager(this.context);

  @override
  State<StatefulWidget> createState() =>
      Provider.of<DownloadManagerController>(this.context);
}

class DownloadManagerController extends State<DownloadManager>
    with ChangeNotifier {
  @override
  Widget build(BuildContext context) => DownloadManagerView(this);

  final List<Download> downloads = [];
}
