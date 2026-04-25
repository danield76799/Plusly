import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:flutter/material.dart';

import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import 'package:extera_next/pages/register/register.dart';

class MsisdnStage extends StatefulWidget {
  final RegisterController controller;

  const MsisdnStage({required this.controller, super.key});

  @override
  State<MsisdnStage> createState() => _MsisdnStageState();
}

class _MsisdnStageState extends State<MsisdnStage> {
  bool _codeSent = false;
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendVerification() async {
    final raw = widget.controller.phoneNumberController.text.trim();
    if (raw.isEmpty) {
      widget.controller.updateState(() {
        widget.controller.phoneError = L10n.of(context).pleaseEnterPhoneNumber;
      });
      return;
    }

    PhoneNumber parsed;
    try {
      parsed = PhoneNumber.parse(raw);
    } catch (_) {
      widget.controller.updateState(() {
        widget.controller.phoneError = L10n.of(context).invalidPhoneNumber;
      });
      return;
    }

    if (!parsed.isValid()) {
      widget.controller.updateState(() {
        widget.controller.phoneError = L10n.of(context).invalidPhoneNumber;
      });
      return;
    }

    final country = parsed.isoCode.name;
    final nationalNumber = parsed.nsn;

    widget.controller.phoneCountryController.text = country;

    await widget.controller.requestMsisdnToken(country, nationalNumber);
    if (widget.controller.phoneError == null) {
      setState(() => _codeSent = true);
    }
  }

  Future<void> _submitCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      widget.controller.updateState(() {
        widget.controller.phoneError = L10n.of(context).invalidVerificationCode;
      });
      return;
    }
    final ok = await widget.controller.submitMsisdnToken(code);
    if (ok) {
      await widget.controller.completeMsisdnStage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const .all(24),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  L10n.of(context).phoneVerification,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _codeSent
                      ? (widget.controller.msisdnNeedsCodeInput
                            ? L10n.of(context).enterVerificationCode
                            : L10n.of(context).verificationCodeSent2)
                      : L10n.of(context).serverRequiresPhone,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!_codeSent)
                  TextField(
                    readOnly: widget.controller.loading,
                    controller: widget.controller.phoneNumberController,
                    keyboardType: TextInputType.phone,
                    autocorrect: false,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.phone_outlined),
                      labelText: L10n.of(context).phoneNumber,
                      hintText: '+44 7911 123456',
                      errorText: widget.controller.phoneError,
                      errorStyle: TextStyle(color: theme.colorScheme.error),
                    ),
                    onChanged: (_) {
                      if (widget.controller.phoneError != null) {
                        widget.controller.updateState(() {
                          widget.controller.phoneError = null;
                        });
                      }
                    },
                  )
                else if (widget.controller.msisdnNeedsCodeInput)
                  TextField(
                    readOnly: widget.controller.loading,
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    autocorrect: false,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      letterSpacing: 8,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    decoration: InputDecoration(
                      labelText: L10n.of(context).verificationCode,
                      hintText: '000000',
                      errorText: widget.controller.phoneError,
                      errorStyle: TextStyle(color: theme.colorScheme.error),
                    ),
                    onChanged: (_) {
                      if (widget.controller.phoneError != null) {
                        widget.controller.updateState(() {
                          widget.controller.phoneError = null;
                        });
                      }
                    },
                    onSubmitted: (_) =>
                        widget.controller.loading ? null : _submitCode(),
                  )
                else
                  Text(
                    L10n.of(context).verificationCodeSent,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          if (!_codeSent)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: widget.controller.loading ? null : _sendVerification,
              child: widget.controller.loading
                  ? const LinearProgressIndicator()
                  : Text(L10n.of(context).sendVerificationCode),
            )
          else ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              onPressed: widget.controller.loading
                  ? null
                  : (widget.controller.msisdnNeedsCodeInput
                        ? _submitCode
                        : widget.controller.completeMsisdnStage),
              child: widget.controller.loading
                  ? const LinearProgressIndicator()
                  : Text(
                      widget.controller.msisdnNeedsCodeInput
                          ? L10n.of(context).verify
                          : L10n.of(context).continueText,
                    ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: widget.controller.loading
                  ? null
                  : () {
                      _codeController.clear();
                      setState(() => _codeSent = false);
                    },
              child: Text(L10n.of(context).useDifferentNumber),
            ),
          ],
        ],
      ),
    );
  }
}
