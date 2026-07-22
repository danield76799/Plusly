import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import 'package:Pulsly/config/themes.dart';
import 'package:Pulsly/pages/image_viewer/image_viewer_view.dart';
import 'package:Pulsly/utils/platform_infos.dart';
import 'package:Pulsly/utils/show_scaffold_dialog.dart';
import 'package:Pulsly/widgets/share_scaffold_dialog.dart';
import '../../utils/matrix_sdk_extensions/event_extension.dart';

class ImageViewer extends StatefulWidget {
  final Event event;
  final Timeline? timeline;
  final BuildContext outerContext;

  const ImageViewer(
    this.event, {
    required this.outerContext,
    this.timeline,
    super.key,
  });

  @override
  ImageViewerController createState() => ImageViewerController();
}

class ImageViewerController extends State<ImageViewer> {
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    allEvents =
        widget.timeline?.events
            .where(
              (event) => {
                MessageTypes.Image,
                MessageTypes.Sticker,
                if (PlatformInfos.supportsVideoPlayer) MessageTypes.Video,
              }.contains(event.messageType),
            )
            .toList()
            .reversed
            .toList() ??
        [widget.event];
    var index = allEvents.indexWhere(
      (event) => event.eventId == widget.event.eventId,
    );
    if (index < 0) index = 0;
    pageController = PageController(initialPage: index);
    WidgetsBinding.instance.addPostFrameCallback((_) => _preloadAdjacent());
  }

  late final PageController pageController;

  late final List<Event> allEvents;

  void onKeyEvent(KeyEvent event) {
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        if (canGoBack) prevImage();
        break;
      case LogicalKeyboardKey.arrowRight:
        if (canGoNext) nextImage();
        break;
    }
  }

  void prevImage() async {
    await pageController.previousPage(
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
    );
    if (!mounted) return;
    setState(() {});
  }

  void nextImage() async {
    await pageController.nextPage(
      duration: FluffyThemes.animationDuration,
      curve: FluffyThemes.animationCurve,
    );
    if (!mounted) return;
    setState(() {});
  }

  int get _index => pageController.page?.toInt() ?? 0;

  Event get currentEvent => allEvents[_index];

  bool get canGoNext => _index < allEvents.length - 1;

  bool get canGoBack => _index > 0;

  void _preloadAdjacent() {
    final currentIndex = _index;
    if (currentIndex < allEvents.length - 1) {
      unawaited(allEvents[currentIndex + 1].downloadAndDecryptAttachment(
        getThumbnail: false,
      ));
    }
    if (currentIndex > 0) {
      unawaited(allEvents[currentIndex - 1].downloadAndDecryptAttachment(
        getThumbnail: false,
      ));
    }
  }

  void forwardAction() => showScaffoldDialog(
    context: context,
    builder: (context) =>
        ShareScaffoldDialog(items: [ContentShareItem(currentEvent.content)]),
  );

  void saveFileAction(BuildContext context) => currentEvent.saveFile(context);

  void shareFileAction(BuildContext context) => currentEvent.shareFile(context);

  @override
  void dispose() {
    pageController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ImageViewerView(this);
}
