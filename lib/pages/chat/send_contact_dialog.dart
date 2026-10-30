import 'dart:async';

import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';

import 'package:Pulsly/generated/l10n/l10n.dart';
import 'package:Pulsly/pages/chat/events/contact_bubble.dart';
import 'package:Pulsly/widgets/adaptive_dialogs/adaptive_dialog_action.dart';
import 'package:Pulsly/widgets/future_loading_dialog.dart';

/// Dialoog om een contact te delen.
///
/// Het contact bestaat uit een naam (verplicht) en optioneel een
/// Matrix-ID, telefoonnummer en e-mailadres. Het Matrix-ID is het
/// waardevolst: daarmee kan de ontvanger meteen een chat beginnen.
class SendContactDialog extends StatefulWidget {
  final Room room;

  const SendContactDialog({required this.room, super.key});

  @override
  SendContactDialogState createState() => SendContactDialogState();
}

class SendContactDialogState extends State<SendContactDialog> {
  final _naamController = TextEditingController();
  final _matrixIdController = TextEditingController();
  final _telefoonController = TextEditingController();
  final _emailController = TextEditingController();
  final _naamFocus = FocusNode();
  bool _isSending = false;
  String? _fout;

  @override
  void initState() {
    super.initState();
    // De naam is het enige verplichte veld.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _naamFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _naamController.dispose();
    _matrixIdController.dispose();
    _telefoonController.dispose();
    _emailController.dispose();
    _naamFocus.dispose();
    super.dispose();
  }

  Future<void> sendAction() async {
    final naam = _naamController.text.trim();
    if (naam.isEmpty) {
      setState(() => _fout = L10n.of(context).contactNameRequired);
      return;
    }
    setState(() {
      _isSending = true;
      _fout = null;
    });

    final contact = <String, dynamic>{
      'display_name': naam,
      if (_matrixIdController.text.trim().isNotEmpty)
        'matrix_id': _matrixIdController.text.trim(),
      if (_telefoonController.text.trim().isNotEmpty)
        'phone': _telefoonController.text.trim(),
      if (_emailController.text.trim().isNotEmpty)
        'email': _emailController.text.trim(),
    };

    await showFutureLoadingDialog(
      context: context,
      future: () => widget.room.sendEvent(
        {
          'msgtype': contactMessageType,
          'body': naam,
          'm.contact': contact,
        },
        type: EventTypes.Message,
      ),
    );
    if (!mounted) return;
    Navigator.of(context, rootNavigator: false).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    return AlertDialog.adaptive(
      title: Text(l10n.sendContact),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _veld(
              context,
              controller: _naamController,
              label: l10n.contactName,
              focusNode: _naamFocus,
              autofocus: true,
            ),
            _veld(
              context,
              controller: _matrixIdController,
              label: l10n.contactMatrixId,
              hint: '@gebruiker:server',
            ),
            _veld(
              context,
              controller: _telefoonController,
              label: l10n.contactPhone,
            ),
            _veld(
              context,
              controller: _emailController,
              label: l10n.contactEmail,
            ),
            if (_fout != null) ...[
              const SizedBox(height: 8),
              Text(
                _fout!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        AdaptiveDialogAction(
          onPressed: Navigator.of(context, rootNavigator: false).pop,
          child: Text(l10n.cancel),
        ),
        AdaptiveDialogAction(
          onPressed: _isSending ? null : sendAction,
          child: Text(l10n.send),
        ),
      ],
    );
  }

  Widget _veld(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    String? hint,
    FocusNode? focusNode,
    bool autofocus = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        textInputAction: TextInputAction.next,
        keyboardType: label == L10n.of(context).contactEmail
            ? TextInputType.emailAddress
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
