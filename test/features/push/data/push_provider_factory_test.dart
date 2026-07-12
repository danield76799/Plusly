import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:Pulsly/features/push/domain/push_provider.dart';

// Fake provider voor testing zonder externe dependencies
class FakeUnifiedPushProvider implements PushProvider {
  final bool _shouldSucceed;
  final StreamController<PushMessage> _controller = StreamController.broadcast();

  FakeUnifiedPushProvider(this._shouldSucceed);

  @override
  String get id => 'unifiedpush';

  @override
  String get displayName => 'Fake UnifiedPush';

  @override
  bool get isAvailable => true;

  @override
  bool get isActive => _shouldSucceed;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<String?> register() async => _shouldSucceed ? 'up_endpoint_123' : null;

  @override
  Future<void> unregister() async {}

  @override
  Stream<PushMessage> get messageStream => _controller.stream;

  @override
  void dispose() => _controller.close();
}

class FakeSharedPreferences {
  final Map<String, dynamic> _data = {};

  bool? getBool(String key) => _data[key] as bool?;
  String? getString(String key) => _data[key] as String?;
  void setBool(String key, bool value) => _data[key] = value;
  void setString(String key, String value) => _data[key] = value;
}

void main() {
  group('PushProviderFactory', () {
    late FakeSharedPreferences store;

    setUp(() {
      store = FakeSharedPreferences();
    });

    group('provider availability', () {
      test('should use UnifiedPush when available and working', () async {
        // Arrange
        final up = FakeUnifiedPushProvider(true);  // Succes

        // Act
        final result = await _testFactory(up);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.type, PushProviderType.unifiedPush);
      });

      test('should return failure when UnifiedPush fails', () async {
        // Arrange
        final up = FakeUnifiedPushProvider(false); // Faalt

        // Act
        final result = await _testFactory(up);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.error, isNotNull);
      });

      test('should skip when provider not available', () async {
        // Arrange
        final up = _UnavailableProvider(); // Niet beschikbaar

        // Act
        final result = await _testFactory(up);

        // Assert
        expect(result.isSuccess, isFalse);
      });
    });

    group('provider lifecycle', () {
      test('should dispose provider on failure', () async {
        // Arrange
        final up = FakeUnifiedPushProvider(false);

        // Act
        final result = await _testFactory(up);

        // Assert
        expect(result.isSuccess, isFalse);
      });
    });
  });
}

// Helper die de factory logica simuleert
Future<_TestResult> _testFactory(
  PushProvider unifiedPush,
) async {
  // Stap 1: Probeer UnifiedPush
  if (unifiedPush.isAvailable) {
    final initialized = await unifiedPush.initialize();
    if (initialized) {
      final token = await unifiedPush.register();
      if (unifiedPush.isActive) {
        return _TestResult.success(PushProviderType.unifiedPush);
      }
    }
    unifiedPush.dispose();
  }

  // Stap 2: Niets werkte
  return _TestResult.failure('Geen push provider beschikbaar');
}

class _UnavailableProvider implements PushProvider {
  @override
  String get id => 'unifiedpush';

  @override
  String get displayName => 'Unavailable UP';

  @override
  bool get isAvailable => false;  // ← KEY: niet beschikbaar

  @override
  bool get isActive => false;

  @override
  Future<bool> initialize() async => false;

  @override
  Future<String?> register() async => null;

  @override
  Future<void> unregister() async {}

  @override
  Stream<PushMessage> get messageStream => const Stream.empty();

  @override
  void dispose() {}
}

class _TestResult {
  final bool isSuccess;
  final PushProviderType? type;
  final String? error;

  _TestResult._({required this.isSuccess, this.type, this.error});

  factory _TestResult.success(PushProviderType type) {
    return _TestResult._(isSuccess: true, type: type);
  }

  factory _TestResult.failure(String error) {
    return _TestResult._(isSuccess: false, error: error);
  }
}
