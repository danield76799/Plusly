import 'package:flutter/material.dart';

import 'package:Pulsly/utils/error_reporter.dart';

class PluslyErrorWidget extends StatefulWidget {
  final FlutterErrorDetails details;
  const PluslyErrorWidget(this.details, {super.key});

  @override
  State<PluslyErrorWidget> createState() => _PluslyErrorWidgetState();
}

class _PluslyErrorWidgetState extends State<PluslyErrorWidget> {
  static final Set<String> knownExceptions = {};
  @override
  void initState() {
    super.initState();

    if (knownExceptions.contains(widget.details.exception.toString())) {
      return;
    }
    knownExceptions.add(widget.details.exception.toString());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ErrorReporter(
        context,
        'Error Widget',
      ).onErrorCallback(widget.details.exception, widget.details.stack);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.error,
      child: Placeholder(
        color: theme.colorScheme.error,
        child: Center(
          child: Material(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(230),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
