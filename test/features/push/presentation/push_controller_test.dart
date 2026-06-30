import 'package:flutter_test/flutter_test.dart';
import 'package:Pulsly/features/push/domain/push_state.dart';
import 'package:Pulsly/features/push/domain/push_provider.dart';

void main() {
  group('PushState', () {
    test('initial state has correct default values', () {
      final state = const PushState.initial();

      expect(state.status, PushStatus.initial);
      expect(state.activeProvider, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isActive, isFalse);
      expect(state.isFailed, isFalse);
      expect(state.isInitializing, isFalse);
    });

    group('copyWith', () {
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
        expect(updated.isFailed, isFalse); // status unchanged
      });

      test('failed state should set isFailed to true', () {
        final state = const PushState(status: PushStatus.failed, errorMessage: 'Oops');

        expect(state.isFailed, isTrue);
        expect(state.errorMessage, 'Oops');
      });
    });
  });
}
