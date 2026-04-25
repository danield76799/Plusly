import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import 'package:extera_next/config/setting_keys.dart';
import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:extera_next/pages/sign_in/view_model/model/public_homeserver_data.dart';
import 'package:extera_next/utils/localized_exception_extension.dart';
import 'package:extera_next/utils/platform_infos.dart';
import 'package:extera_next/utils/sign_in_flows/oidc_login.dart';
import 'package:extera_next/utils/sign_in_flows/sso_login.dart';
import 'package:extera_next/widgets/adaptive_dialogs/show_modal_action_popup.dart';
import 'package:extera_next/widgets/adaptive_dialogs/show_ok_cancel_alert_dialog.dart';
import 'package:extera_next/widgets/matrix.dart';

Future<void> connectToHomeserverFlow(
  PublicHomeserverData homeserverData,
  BuildContext context,
  void Function(AsyncSnapshot<bool>) setState,
  bool signUp,
) async {
  setState(AsyncSnapshot.waiting());
  try {
    final homeserverInput = homeserverData.name!;
    var homeserver = Uri.parse(homeserverInput);
    if (homeserver.scheme.isEmpty) {
      homeserver = Uri.https(homeserverInput, '');
    }
    final l10n = L10n.of(context);
    final client = await Matrix.of(context).getLoginClient();
    final (_, _, loginFlows, authMetadata) = await client.checkHomeserver(
      homeserver,
      fetchAuthMetadata: true,
    );

    final regLink = homeserverData.regLink;
    final supportsSso = loginFlows.any((flow) => flow.type == 'm.login.sso');

    if ((kIsWeb || PlatformInfos.isLinux) &&
        (supportsSso || authMetadata != null || (signUp && regLink != null))) {
      if (!context.mounted) return;
      final consent = await showOkCancelAlertDialog(
        context: context,
        title: l10n.appWantsToUseForLogin(homeserverInput),
        message: l10n.appWantsToUseForLoginDescription,
        okLabel: l10n.continueText,
      );
      if (consent != OkCancelResult.ok) return;
      if (!context.mounted) return;
    }
    if (!context.mounted) return;

    final hasOidc =
        authMetadata != null && AppSettings.enableMatrixNativeOIDC.value;

    if (signUp) {
      // When signing up, the user may have multiple options available.
      // Always advertise password-based registration alongside any SSO/OIDC.
      const signUpOidc = 'oidc';
      const signUpSso = 'sso';
      const signUpPassword = 'password';

      final actions = <AdaptiveModalAction<String>>[
        if (hasOidc)
          AdaptiveModalAction(
            label: L10n.of(context).continueOIDC,
            value: signUpOidc,
            icon: const Icon(Icons.login_outlined),
          ),
        if (supportsSso)
          AdaptiveModalAction(
            label: L10n.of(context).continueSSO,
            value: signUpSso,
            icon: const Icon(Icons.login_outlined),
          ),
        AdaptiveModalAction(
          label: L10n.of(context).registerWithPassword,
          value: signUpPassword,
          icon: const Icon(Icons.password_outlined),
          isDefaultAction: !hasOidc && !supportsSso,
        ),
      ];

      String? choice;
      if (actions.length == 1) {
        choice = actions.single.value;
      } else {
        if (!context.mounted) return;
        choice = await showModalActionPopup<String>(
          context: context,
          title: L10n.of(context).howWouldYouLikeToSignUp,
          actions: actions,
          cancelLabel: l10n.cancel,
        );
      }

      if (choice == null) return;
      if (!context.mounted) return;

      switch (choice) {
        case signUpOidc:
          await oidcLoginFlow(client, context, true);
          break;
        case signUpSso:
          await ssoLoginFlow(client, context, true, loginFlows);
          break;
        case signUpPassword:
          if (!context.mounted) return;
          final pathSegments = List.of(
            GoRouter.of(
              context,
            ).routeInformationProvider.value.uri.pathSegments,
          );
          pathSegments.removeLast();
          pathSegments.add('register');
          context.go('/${pathSegments.join('/')}', extra: client);
          await AppSettings.defaultHomeserver.setItem(homeserverInput);
          setState(AsyncSnapshot.withData(ConnectionState.done, true));
          return;
      }
    } else if (hasOidc) {
      await oidcLoginFlow(client, context, false);
    } else if (supportsSso) {
      await ssoLoginFlow(client, context, false, loginFlows);
    } else {
      if (!context.mounted) return;
      final pathSegments = List.of(
        GoRouter.of(context).routeInformationProvider.value.uri.pathSegments,
      );
      pathSegments.removeLast();
      pathSegments.add('login');
      context.go('/${pathSegments.join('/')}', extra: client);
      setState(AsyncSnapshot.withData(ConnectionState.done, true));
      return;
    }

    await AppSettings.defaultHomeserver.setItem(homeserverInput);

    if (context.mounted) {
      setState(AsyncSnapshot.withData(ConnectionState.done, true));
      context.go('/backup');
    }
  } catch (e, s) {
    Logs().w('Unable to login', e, s);
    setState(AsyncSnapshot.withError(ConnectionState.done, e, s));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toLocalizedString(context, ExceptionContext.checkHomeserver),
        ),
      ),
    );
  }
}
