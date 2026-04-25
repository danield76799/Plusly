import 'package:extera_next/config/themes.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher_string.dart';

import 'package:extera_next/pages/register/register.dart';

class TermsStage extends StatefulWidget {
  final RegisterController controller;

  const TermsStage({required this.controller, super.key});

  @override
  State<TermsStage> createState() => _TermsStageState();
}

class _TermsStageState extends State<TermsStage> {
  final Set<String> _acceptedPolicies = {};

  List<_PolicyInfo> get _policies {
    final policies = widget.controller.termsPolices;
    if (policies == null) return [];

    final result = <_PolicyInfo>[];
    for (final entry in policies.entries) {
      final policyId = entry.key;
      final policyData = entry.value;
      if (policyData is! Map<String, dynamic>) continue;

      final locale = Localizations.localeOf(context).languageCode;
      final localizedData = policyData[locale] ?? policyData['en'];
      Map<String, dynamic>? policyInfo;

      if (localizedData is Map<String, dynamic>) {
        policyInfo = localizedData;
      } else {
        for (final value in policyData.values) {
          if (value is Map<String, dynamic> && value.containsKey('url')) {
            policyInfo = value;
            break;
          }
        }
      }

      if (policyInfo != null) {
        result.add(
          _PolicyInfo(
            id: policyId,
            name: policyInfo['name'] as String? ?? policyId,
            url: policyInfo['url'] as String? ?? '',
          ),
        );
      }
    }
    return result;
  }

  bool get _allAccepted {
    final policies = _policies;
    if (policies.isEmpty) return true;
    return policies.every((p) => _acceptedPolicies.contains(p.id));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final policies = _policies;

    return Padding(
      padding: const .all(24),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                Icon(
                  Icons.policy_outlined,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  L10n.of(context).termsOfService,
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  L10n.of(context).pleaseReviewAndAcceptPolicies,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (policies.isEmpty)
                  Text(L10n.of(context).noPolicies, textAlign: TextAlign.center)
                else
                  ...policies.map((policy) {
                    final isAccepted = _acceptedPolicies.contains(policy.id);
                    return Padding(
                      padding: const .only(bottom: 12),
                      child: AnimatedContainer(
                        duration: FluffyThemes.animationDuration,
                        curve: Curves.easeOutCubic,
                        decoration: BoxDecoration(
                          color: isAccepted
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: .circular(20),
                          border: Border.all(
                            color: isAccepted
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                            width: isAccepted ? 1.5 : 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                if (isAccepted) {
                                  _acceptedPolicies.remove(policy.id);
                                } else {
                                  _acceptedPolicies.add(policy.id);
                                }
                              });
                            },
                            child: Padding(
                              padding: const .symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                crossAxisAlignment: .start,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeOutCubic,
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isAccepted
                                          ? theme.colorScheme.primary
                                          : theme
                                                .colorScheme
                                                .surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(
                                        isAccepted ? 14 : 20,
                                      ),
                                    ),
                                    child: Icon(
                                      isAccepted
                                          ? Icons.check_rounded
                                          : Icons.description_outlined,
                                      color: isAccepted
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurfaceVariant,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: .start,
                                      children: [
                                        Text(
                                          policy.name,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: isAccepted
                                                    ? theme
                                                          .colorScheme
                                                          .onPrimaryContainer
                                                    : theme
                                                          .colorScheme
                                                          .onSurface,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        if (policy.url.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          InkWell(
                                            onTap: () =>
                                                launchUrlString(policy.url),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Padding(
                                              padding: const .symmetric(
                                                vertical: 2,
                                              ),
                                              child: Row(
                                                mainAxisSize: .min,
                                                children: [
                                                  Icon(
                                                    Icons.open_in_new_rounded,
                                                    size: 14,
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    L10n.of(context).readPolicy,
                                                    style: theme
                                                        .textTheme
                                                        .labelLarge
                                                        ?.copyWith(
                                                          color: theme
                                                              .colorScheme
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            onPressed: _allAccepted && !widget.controller.loading
                ? widget.controller.completeTermsStage
                : null,
            child: widget.controller.loading
                ? const LinearProgressIndicator()
                : Text(L10n.of(context).acceptAndContinue),
          ),
        ],
      ),
    );
  }
}

class _PolicyInfo {
  final String id;
  final String name;
  final String url;

  const _PolicyInfo({required this.id, required this.name, required this.url});
}
