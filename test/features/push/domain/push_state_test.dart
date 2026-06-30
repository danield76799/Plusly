import 'package:flutter_test/flutter_test.dart';
import 'package:Pulsly/features/push/domain/push_state.dart';
import 'package:Pulsly/features/push/domain/push_provider.dart';

void main() {
  group('PushState', () {
    test('initial state heeft correcte defaults', () {
      const state = PushState.initial();

      expect(state.status, PushStatus.initial);
      expect(state.activeProvider, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isActive, isFalse);
      expect(state.isFailed, isFalse);
      expect(state.isInitializing, isFalse);
    });

    test('copyWith behoudt niet-gespecificeerde velden', () {
      const state = PushState.initial();
      final updated = state.copyWith(status: PushStatus.active);

      expect(updated.status, PushStatus.active);
      expect(updated.activeProvider, isNull); // behouden
      expect(updated.errorMessage, isNull); // behouden
    });

    test('isActive is true bij status active', () {
      const state = PushState(
        status: PushStatus.active,
        activeProvider: PushProviderType.unifiedPush,
      );
      expect(state.isActive, isTrue);
      expect(state.isFailed, isFalse);
      expect(state.isInitializing, isFalse);
    });

    test('isFailed is true bij status failed', () {
      const state = PushState(
        status: PushStatus.failed,
        errorMessage: 'Netwerk fout',
      );
      expect(state.isFailed, isTrue);
      expect(state.isActive, isFalse);
      expect(state.errorMessage, 'Netwerk fout');
    });

    test('isInitializing is true bij status initializing', () {
      const state = PushState(status: PushStatus.initializing);
      expect(state.isInitializing, isTrue);
    });

    test('disabled status is niet active', () {
      const state = PushState(status: PushStatus.disabled);
      expect(state.isActive, isFalse);
      expect(state.isFailed, isFalse);
      expect(state.isInitializing, isFalse);
    });

    test('copyWith vervangt meerdere velden', () {
      const state = PushState.initial();
      final updated = state.copyWith(
        status: PushStatus.failed,
        activeProvider: PushProviderType.unifiedPush,
        errorMessage: 'Timeout',
      );

      expect(updated.status, PushStatus.failed);
      expect(updated.activeProvider, PushProviderType.unifiedPush);
      expect(updated.errorMessage, 'Timeout');
    });

    test('equality: gelijke states zijn gelijk', () {
      const a = PushState(
        status: PushStatus.active,
        activeProvider: PushProviderType.unifiedPush,
      );
      const b = PushState(
        status: PushStatus.active,
        activeProvider: PushProviderType.unifiedPush,
      );

      expect(a.status, b.status);
      expect(a.activeProvider, b.activeProvider);
      expect(a.errorMessage, b.errorMessage);
    });
  });

  group('PushStatus', () {
    test('alle statuses bestaan', () {
      expect(PushStatus.values.length, 5);
      expect(PushStatus.values, contains(PushStatus.initial));
      expect(PushStatus.values, contains(PushStatus.initializing));
      expect(PushStatus.values, contains(PushStatus.active));
      expect(PushStatus.values, contains(PushStatus.failed));
      expect(PushStatus.values, contains(PushStatus.disabled));
    });
  });
}
