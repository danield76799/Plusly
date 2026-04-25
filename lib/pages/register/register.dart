import 'dart:async';
import 'dart:convert';

import 'package:extera_next/generated/l10n/l10n.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:matrix/matrix.dart';

import 'package:extera_next/utils/platform_infos.dart';
import 'register_view.dart';

class Register extends StatefulWidget {
  final Client client;
  const Register({required this.client, super.key});

  @override
  RegisterController createState() => RegisterController();
}

class RegisterController extends State<Register> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneCountryController = TextEditingController(
    text: 'GB',
  );
  final TextEditingController phoneNumberController = TextEditingController();

  final PageController pageController = PageController();

  String? usernameError;
  String? passwordError;
  String? confirmPasswordError;
  String? emailError;
  String? phoneError;
  bool loading = false;
  bool showPassword = false;
  bool usernameAvailable = false;
  bool checkingUsername = false;

  int currentStep = 0;

  String? _session;

  List<AuthenticationFlow> _flows = [];

  List<String> _stages = [];

  List<String> _completedStages = [];

  Map<String, dynamic> _params = {};

  bool registrationComplete = false;

  String? _emailClientSecret;
  String? _emailSid;
  static int _emailSendAttempt = 0;

  String? _msisdnClientSecret;
  String? _msisdnSid;
  Uri? _msisdnSubmitUrl;
  static int _msisdnSendAttempt = 0;

  XFile? avatarFile;

  Timer? _usernameCheckTimer;

  List<String> get wizardPages {
    final pages = <String>['credentials'];
    pages.addAll(_stages);
    pages.add('profile');
    return pages;
  }

  String get currentPageType {
    if (currentStep < 0 || currentStep >= wizardPages.length) {
      return 'credentials';
    }
    return wizardPages[currentStep];
  }

  int get totalPages => wizardPages.length;

  bool get isLastPage => currentStep == totalPages - 1;

  void updateState(VoidCallback fn) => setState(fn);

  void toggleShowPassword() =>
      setState(() => showPassword = !loading && !showPassword);

  void checkUsernameWithCoolDown(String username) {
    _usernameCheckTimer?.cancel();
    setState(() {
      usernameAvailable = false;
      checkingUsername = false;
      usernameError = null;
    });
    if (username.isEmpty) return;
    setState(() => checkingUsername = true);
    _usernameCheckTimer = Timer(
      const Duration(milliseconds: 600),
      () => _checkUsernameAvailability(username),
    );
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (!mounted) return;
    try {
      final available = await widget.client.checkUsernameAvailability(username);
      if (!mounted) return;
      setState(() {
        checkingUsername = false;
        usernameAvailable = available ?? true;
        usernameError = (available ?? true)
            ? null
            : L10n.of(context).usernameAlreadyTaken;
      });
    } on MatrixException catch (e) {
      if (!mounted) return;
      setState(() {
        checkingUsername = false;
        usernameAvailable = false;
        usernameError = e.errorMessage;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        checkingUsername = false;
        usernameAvailable = false;
        usernameError = e.toString();
      });
    }
  }

  Future<void> startRegistration() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    var hasError = false;

    if (username.isEmpty) {
      setState(() => usernameError = L10n.of(context).pleaseEnterUsername);
      hasError = true;
    } else {
      setState(() => usernameError = null);
    }

    if (password.isEmpty) {
      setState(() => passwordError = L10n.of(context).pleaseEnterPassword);
      hasError = true;
    } else if (password.length < 8) {
      setState(() => passwordError = L10n.of(context).passwordMinLengthMessage);
      hasError = true;
    } else {
      setState(() => passwordError = null);
    }

    if (confirmPassword != password) {
      setState(
        () => confirmPasswordError = L10n.of(context).passwordsDoNotMatch,
      );
      hasError = true;
    } else {
      setState(() => confirmPasswordError = null);
    }

    if (hasError) return;

    setState(() => loading = true);

    try {
      await _attemptRegister(null);
    } catch (e) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> _attemptRegister(AuthenticationData? auth) async {
    try {
      await widget.client.register(
        username: usernameController.text.trim(),
        password: passwordController.text,
        auth: auth,
        initialDeviceDisplayName: PlatformInfos.clientName,
        kind: AccountKind.user,
      );

      if (!mounted) return;
      setState(() {
        loading = false;
        registrationComplete = true;
      });

      _goToPage(wizardPages.length - 1);
    } on MatrixException catch (e) {
      if (e.requireAdditionalAuthentication) {
        _session = e.session;
        _flows = e.authenticationFlows ?? [];
        _params = e.authenticationParams ?? {};
        _completedStages = e.completedAuthenticationFlows;

        if (_stages.isEmpty && _flows.isNotEmpty) {
          _stages = _pickBestFlow(_flows, _completedStages);
        }

        if (!mounted) return;
        setState(() => loading = false);

        _advanceToNextStage();
      } else {
        if (!mounted) return;
        setState(() {
          loading = false;
          _handleRegistrationError(e);
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        passwordError = L10n.of(context).registrationFailed(e.toString());
      });
    }
  }

  List<String> _pickBestFlow(
    List<AuthenticationFlow> flows,
    List<String> completed,
  ) {
    if (flows.isEmpty) return [];

    final knownStages = {
      AuthenticationTypes.dummy,
      AuthenticationTypes.recaptcha,
      AuthenticationTypes.emailIdentity,
      AuthenticationTypes.msisdn,
      'm.login.terms',
      AuthenticationTypes.password,
    };

    final sortedFlows = List<AuthenticationFlow>.from(flows);
    sortedFlows.sort((a, b) {
      final aAllKnown = a.stages.every((s) => knownStages.contains(s));
      final bAllKnown = b.stages.every((s) => knownStages.contains(s));
      if (aAllKnown && !bAllKnown) return -1;
      if (!aAllKnown && bAllKnown) return 1;
      return a.stages.length.compareTo(b.stages.length);
    });

    return sortedFlows.first.stages;
  }

  void _advanceToNextStage() {
    for (var i = 0; i < _stages.length; i++) {
      if (!_completedStages.contains(_stages[i])) {
        final pageIndex = 1 + i;
        _goToPage(pageIndex);

        if (_stages[i] == AuthenticationTypes.dummy) {
          completeDummyStage();
        }
        return;
      }
    }

    _attemptRegister(AuthenticationData(session: _session));
  }

  void _goToPage(int page) {
    setState(() => currentStep = page);
    if (pageController.hasClients) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleRegistrationError(MatrixException e) {
    switch (e.error) {
      case MatrixError.M_USER_IN_USE:
        usernameError = L10n.of(context).usernameAlreadyTaken;
        _goToPage(0);
        break;
      case MatrixError.M_INVALID_USERNAME:
        usernameError = L10n.of(context).invalidUsername;
        _goToPage(0);
        break;
      case MatrixError.M_THREEPID_IN_USE:
        emailError = L10n.of(context).emailAlreadyUsed;
        break;
      case MatrixError.M_THREEPID_DENIED:
        emailError = L10n.of(context).emailNotAllowed;
        break;
      case MatrixError.M_CAPTCHA_INVALID:
        passwordError = L10n.of(context).captchaFailed;
        break;
      default:
        passwordError = e.errorMessage;
        break;
    }
  }

  Future<void> completeDummyStage() async {
    setState(() => loading = true);
    await _attemptRegister(
      AuthenticationData(type: AuthenticationTypes.dummy, session: _session),
    );
  }

  /// Called after the user completes the reCAPTCHA in the homeserver's
  /// fallback webview. The server has already recorded the stage completion
  /// for this session, so we just re-attempt /register with the session id.
  Future<void> completeRecaptchaViaFallback() async {
    setState(() => loading = true);
    await _attemptRegister(AuthenticationData(session: _session));
  }

  Future<void> completeTermsStage() async {
    setState(() => loading = true);
    await _attemptRegister(
      AuthenticationData(type: 'm.login.terms', session: _session),
    );
  }

  Future<void> requestEmailToken(String email) async {
    setState(() {
      loading = true;
      emailError = null;
    });

    try {
      _emailClientSecret = DateTime.now().millisecondsSinceEpoch.toString();
      _emailSendAttempt++;

      final response = await widget.client.requestTokenToRegisterEmail(
        _emailClientSecret!,
        email,
        _emailSendAttempt,
      );

      _emailSid = response.sid;

      if (!mounted) return;
      setState(() => loading = false);
    } on MatrixException catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        if (e.error == MatrixError.M_THREEPID_IN_USE) {
          emailError = L10n.of(context).emailAlreadyUsed;
        } else {
          emailError = e.errorMessage;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        emailError = e.toString();
      });
    }
  }

  Future<void> completeEmailStage() async {
    if (_emailSid == null || _emailClientSecret == null) {
      setState(
        () => emailError = L10n.of(context).requestAVerificationEmailFirst,
      );
      return;
    }

    setState(() => loading = true);
    await _attemptRegister(
      AuthenticationThreePidCreds(
        session: _session,
        type: AuthenticationTypes.emailIdentity,
        threepidCreds: ThreepidCreds(
          sid: _emailSid!,
          clientSecret: _emailClientSecret!,
        ),
      ),
    );
  }

  Future<void> requestMsisdnToken(String country, String phoneNumber) async {
    setState(() {
      loading = true;
      phoneError = null;
    });

    try {
      _msisdnClientSecret = DateTime.now().millisecondsSinceEpoch.toString();
      _msisdnSendAttempt++;

      final response = await widget.client.requestTokenToRegisterMSISDN(
        _msisdnClientSecret!,
        country,
        phoneNumber,
        _msisdnSendAttempt,
      );

      _msisdnSid = response.sid;
      _msisdnSubmitUrl = response.submitUrl;

      if (!mounted) return;
      setState(() => loading = false);
    } on MatrixException catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        if (e.error == MatrixError.M_THREEPID_IN_USE) {
          phoneError = L10n.of(context).phoneNumberAlreadyUsed;
        } else {
          phoneError = e.errorMessage;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        phoneError = e.toString();
      });
    }
  }

  /// Submit the SMS verification code to the homeserver/IS submit_url.
  /// Returns true on success.
  Future<bool> submitMsisdnToken(String token) async {
    if (_msisdnSid == null ||
        _msisdnClientSecret == null ||
        _msisdnSubmitUrl == null) {
      setState(
        () => phoneError = L10n.of(context).requestAVerificationCodeFirst,
      );
      return false;
    }

    setState(() {
      loading = true;
      phoneError = null;
    });

    try {
      final response = await widget.client.httpClient.post(
        _msisdnSubmitUrl!,
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'sid': _msisdnSid,
          'client_secret': _msisdnClientSecret,
          'token': token.trim(),
        }),
      );

      final body = jsonDecode(response.body);
      final success = body is Map<String, dynamic> && body['success'] == true;

      if (!mounted) return success;
      setState(() {
        loading = false;
        if (!success) {
          phoneError = (body is Map<String, dynamic> && body['error'] is String)
              ? body['error'] as String
              : L10n.of(context).invalidVerificationCode;
        }
      });
      return success;
    } catch (e) {
      if (!mounted) return false;
      setState(() {
        loading = false;
        phoneError = e.toString();
      });
      return false;
    }
  }

  Future<void> completeMsisdnStage() async {
    if (_msisdnSid == null || _msisdnClientSecret == null) {
      setState(
        () => phoneError = L10n.of(context).requestAVerificationCodeFirst,
      );
      return;
    }

    setState(() => loading = true);
    await _attemptRegister(
      AuthenticationThreePidCreds(
        session: _session,
        type: AuthenticationTypes.msisdn,
        threepidCreds: ThreepidCreds(
          sid: _msisdnSid!,
          clientSecret: _msisdnClientSecret!,
        ),
      ),
    );
  }

  /// True if the homeserver returned a submit_url (i.e. we need to ask
  /// the user for the SMS code ourselves before calling /register again).
  bool get msisdnNeedsCodeInput => _msisdnSubmitUrl != null;

  Future<void> completeFallbackStage(String stageType) async {
    setState(() => loading = true);
    await _attemptRegister(AuthenticationData(session: _session));
  }

  Uri getFallbackUrl(String stage) {
    final stageParams = _params[stage];
    if (stageParams is Map<String, dynamic>) {
      final url = stageParams['url'];
      if (url is String) {
        final parsed = Uri.tryParse(url);
        if (parsed != null) return parsed;
      }
    }
    return widget.client.homeserver!.replace(
      path: '/_matrix/client/v3/auth/$stage/fallback/web',
      queryParameters: {'session': _session ?? ''},
    );
  }

  String? get recaptchaPublicKey {
    final recaptchaParams = _params[AuthenticationTypes.recaptcha];
    if (recaptchaParams is Map<String, dynamic>) {
      return recaptchaParams['public_key'] as String?;
    }
    return null;
  }

  Map<String, dynamic>? get termsPolices {
    final termsParams = _params['m.login.terms'];
    if (termsParams is Map<String, dynamic>) {
      return termsParams['policies'] as Map<String, dynamic>?;
    }
    return null;
  }

  Future<void> pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => avatarFile = picked);
  }

  Future<void> completeProfile() async {
    setState(() => loading = true);

    try {
      final client = widget.client;

      final displayName = displayNameController.text.trim();
      if (displayName.isNotEmpty) {
        await client.setProfileField(client.userID!, 'displayname', {
          'displayname': displayName,
        });
      }

      if (avatarFile != null) {
        final bytes = await avatarFile!.readAsBytes();
        final mimeType = avatarFile!.mimeType ?? 'image/png';
        final uploaded = await client.uploadContent(
          bytes,
          filename: avatarFile!.name,
          contentType: mimeType,
        );
        await client.setProfileField(client.userID!, 'avatar_url', {
          'avatar_url': uploaded.toString(),
        });
      }
    } catch (e) {
      Logs().w('Failed to set profile during registration', e);
    }

    if (!mounted) return;
    setState(() => loading = false);
    context.go('/backup');
  }

  void skipProfile() {
    context.go('/backup');
  }

  void goBack() {
    if (currentStep > 0 && !registrationComplete) {
      _goToPage(currentStep - 1);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    displayNameController.dispose();
    emailController.dispose();
    phoneCountryController.dispose();
    phoneNumberController.dispose();
    pageController.dispose();
    _usernameCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RegisterView(this);
}
