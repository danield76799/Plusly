import 'dart:async';

import 'push_provider.dart';

/// State van het push systeem — gebruikt door UI om status te tonen
class PushState {
  final PushStatus status;
  final PushProviderType? activeProvider;
  final String? errorMessage;

  const PushState({
    required this.status,
    this.activeProvider,
    this.errorMessage,
  });

  const PushState.initial()
      : status = PushStatus.initial,
        activeProvider = null,
        errorMessage = null;

  PushState copyWith({
    PushStatus? status,
    PushProviderType? activeProvider,
    String? errorMessage,
  }) {
    return PushState(
      status: status ?? this.status,
      activeProvider: activeProvider ?? this.activeProvider,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isActive => status == PushStatus.active;
  bool get isFailed => status == PushStatus.failed;
  bool get isInitializing => status == PushStatus.initializing;
}

enum PushStatus {
  initial,
  initializing,
  active,
  failed,
  disabled,
}
