import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'package:extera_next/pages/register/register.dart';
import 'package:extera_next/pages/register/stages/email_stage.dart';
import 'package:extera_next/pages/register/stages/fallback_stage.dart';
import 'package:extera_next/pages/register/stages/msisdn_stage.dart';
import 'package:extera_next/pages/register/stages/profile_stage.dart';
import 'package:extera_next/pages/register/stages/recaptcha_stage.dart';
import 'package:extera_next/pages/register/stages/terms_stage.dart';
import 'package:extera_next/pages/register/stages/username_password_stage.dart';
import 'package:extera_next/widgets/layouts/login_scaffold.dart';

class RegisterView extends StatelessWidget {
  final RegisterController controller;

  const RegisterView(this.controller, {super.key});

  Widget _buildStagePage(BuildContext context, String pageType) {
    switch (pageType) {
      case 'credentials':
        return UsernamePasswordStage(controller: controller);
      case 'profile':
        return ProfileStage(controller: controller);
      case AuthenticationTypes.recaptcha:
        return RecaptchaStage(controller: controller);
      case 'm.login.terms':
        return TermsStage(controller: controller);
      case AuthenticationTypes.emailIdentity:
        return EmailStage(controller: controller);
      case AuthenticationTypes.msisdn:
        return MsisdnStage(controller: controller);
      case AuthenticationTypes.dummy:
        // Dummy stage auto-completes; show a loading indicator.
        return const Center(child: CircularProgressIndicator.adaptive());
      default:
        return FallbackStage(controller: controller, stageType: pageType);
    }
  }

  IconData _iconForPage(String pageType) {
    switch (pageType) {
      case 'credentials':
        return Icons.person_outline_rounded;
      case 'profile':
        return Icons.face_outlined;
      case AuthenticationTypes.recaptcha:
        return Icons.verified_user_outlined;
      case 'm.login.terms':
        return Icons.policy_outlined;
      case AuthenticationTypes.emailIdentity:
        return Icons.mail_outline_rounded;
      case AuthenticationTypes.msisdn:
        return Icons.phone_outlined;
      case AuthenticationTypes.dummy:
        return Icons.hourglass_empty_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _titleForPage(BuildContext context, String pageType) {
    switch (pageType) {
      case 'credentials':
        return L10n.of(context).createNewAccount;
      case 'profile':
        return L10n.of(context).setupProfile;
      case AuthenticationTypes.recaptcha:
        return L10n.of(context).captcha;
      case 'm.login.terms':
        return L10n.of(context).termsOfService;
      case AuthenticationTypes.emailIdentity:
        return L10n.of(context).verifyEmail;
      case AuthenticationTypes.msisdn:
        return L10n.of(context).verifyPhone;
      case AuthenticationTypes.dummy:
        return L10n.of(context).pleaseWait;
      default:
        return L10n.of(context).verification;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = controller.wizardPages;
    final currentStep = controller.currentStep.clamp(0, pages.length - 1);
    final currentPageType = pages[currentStep];

    return PopScope(
      canPop: currentStep == 0 || controller.registrationComplete,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        controller.goBack();
      },
      child: LoginScaffold(
        appBar: AppBar(
          leading: controller.loading
              ? null
              : BackButton(onPressed: controller.goBack),
          automaticallyImplyLeading: !controller.loading,
          backgroundColor: theme.colorScheme.surface,
          surfaceTintColor: theme.colorScheme.surface,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(_titleForPage(context, currentPageType)),
          bottom: pages.length > 1
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: _StageStepper(
                    pages: pages,
                    currentStep: currentStep,
                    iconBuilder: _iconForPage,
                  ),
                )
              : null,
        ),
        body: PageView.builder(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pages.length,
          itemBuilder: (context, index) =>
              _buildStagePage(context, pages[index]),
        ),
      ),
    );
  }
}

class _StageStepper extends StatelessWidget {
  final List<String> pages;
  final int currentStep;
  final IconData Function(String pageType) iconBuilder;

  const _StageStepper({
    required this.pages,
    required this.currentStep,
    required this.iconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const .fromLTRB(16, 4, 16, 12),
      child: Row(
        children: List.generate(pages.length * 2 - 1, (i) {
          if (i.isOdd) {
            final leftIdx = i ~/ 2;
            final isPast = leftIdx < currentStep;
            return Expanded(
              child: Padding(
                padding: const .symmetric(horizontal: 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isPast
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            );
          }

          final idx = i ~/ 2;
          final isCurrent = idx == currentStep;
          final isPast = idx < currentStep;
          final isDone = isPast;

          final Color bg;
          final Color fg;
          if (isCurrent) {
            bg = theme.colorScheme.primary;
            fg = theme.colorScheme.onPrimary;
          } else if (isDone) {
            bg = theme.colorScheme.primaryContainer;
            fg = theme.colorScheme.onPrimaryContainer;
          } else {
            bg = theme.colorScheme.surfaceContainerHighest;
            fg = theme.colorScheme.onSurfaceVariant;
          }

          return Semantics(
            label: 'Step ${idx + 1} of ${pages.length}',
            selected: isCurrent,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              width: isCurrent ? 44 : 32,
              height: 32,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(isCurrent ? 14 : 16),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeInCubic,
                child: Icon(
                  isDone ? Icons.check_rounded : iconBuilder(pages[idx]),
                  key: ValueKey('$idx-${isDone ? 'done' : 'pending'}'),
                  size: 18,
                  color: fg,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
