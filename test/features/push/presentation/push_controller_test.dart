import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:Pulsly/features/push/domain/push_state.dart';

void main() {
  group('PushController', () {
    test('initial state has correct default values', () {
      final state = const PushState.initial();

      expect(state.status, PushStatus.initial);
      expect(state.activeProvider, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isInitial, isTrue);
      expect(state.isActive, isFalse);
      expect(state.isFailed, isFalse);
      expect(state.isInitializing, isFalse);
    });

    group('PushState copyWith', () {
      test('should update status', () {
        final state = const PushState.initial();
        final updated = state.copyWith(status: PushStatus.active);

        expect(updated.status, PushStatus.active);
        expect(updated.isActive, isTrue);
      });

      test('should update activeProvider', () {
        final state = const PushState.initial();
        final updated = state.copyWith(activeProvider: PushProviderType.unifiedPush);

        expect(updated.activeProvider, PushProviderType.unifiedPush);
      });

      test('should update errorMessage', () {
        final state = const PushState.initial();
        final updated = state.copyWith(errorMessage: 'Test error');

        expect(updated.errorMessage, 'Test error');
        expect(updated.isFailed, isTrue);
      });
    });
  });
}
