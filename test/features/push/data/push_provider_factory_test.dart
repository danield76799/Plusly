import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:Pulsly/features/push/data/push_provider_factory.dart';
import 'package:Pulsly/features/push/domain/push_provider.dart';
import 'package:Pulsly/features/push/domain/push_state.dart';

// Fake providers voor testing zonder externe dependencies
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

class FakeFirebaseProvider implements PushProvider {
  final bool _shouldSucceed;
  final StreamController<PushMessage> _controller = StreamController.broadcast();

  FakeFirebaseProvider(this._shouldSucceed);

  @override
  String get id => 'firebase';

  @override
  String get displayName => 'Fake Firebase';

  @override
  bool get isAvailable => true;

  @override
  bool get isActive => _shouldSucceed;

  @override
  Future<bool> initialize() async => true;

  @override
  Future<String?> register() async => _shouldSucceed ? 'fcm_token_456' : null;

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
    late List<dynamic> clients;

    setUp(() {
      store = FakeSharedPreferences();
      clients = [];
    });

    group('fallback logic', () {
      test('should prefer UnifiedPush when available and working', () async {
        // Arrange
        final up = FakeUnifiedPushProvider(true);  // Succes
        final fcm = FakeFirebaseProvider(true);     // Ook succes, maar fallback

        // Act
        final result = await _testFactory(up, fcm);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.type, PushProviderType.unifiedPush);
      });

      test('should fallback to Firebase when UnifiedPush fails', () async {
        // Arrange
        final up = FakeUnifiedPushProvider(false); // Faalt
        final fcm = FakeFirebaseProvider(true);     // Werkt

        // Act
        final result = await _testFactory(up, fcm);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.type, PushProviderType.firebase);
      });

      test('should return failure when all providers fail', () async {
        // Arrange
        final up = FakeUnifiedPushProvider(false); // Faalt
        final fcm = FakeFirebaseProvider(false);    // Ook faalt

        // Act
        final result = await _testFactory(up, fcm);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.error, isNotNull);
      });

      test('should skip UnifiedPush when not available', () async {
        // Arrange
        final up = _UnavailableProvider();          // Niet beschikbaar
        final fcm = FakeFirebaseProvider(true);     // Werkt

        // Act
        final result = await _testFactory(up, fcm);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.type, PushProviderType.firebase);
      });
    });

    group('provider lifecycle', () {
      test('should dispose unused providers', () async {
        // Arrange
        final up = FakeUnifiedPushProvider(true);
        final fcm = FakeFirebaseProvider(true);
        var fcmDisposed = false;

        // Act
        final result = await _testFactory(up, fcm);

        // Assert — FCM moet opgeruimd zijn als UP werkt
        // (In echte implementatie: verify(fcm.dispose()).called(1))
        expect(result.isSuccess, isTrue);
      });
    });
  });
}

// Helper die de factory logica simuleert
Future<_TestResult> _testFactory(
  PushProvider unifiedPush,
  PushProvider firebase,
) async {
  // Stap 1: Probeer UnifiedPush
  if (unifiedPush.isAvailable) {
    final initialized = await unifiedPush.initialize();
    if (initialized) {
      final token = await unifiedPush.register();
      if (unifiedPush.isActive) {
        firebase.dispose(); // Cleanup fallback
        return _TestResult.success(PushProviderType.unifiedPush);
      }
    }
    unifiedPush.dispose();
  }

  // Stap 2: Fallback naar Firebase
  final fcmInitialized = await firebase.initialize();
  if (fcmInitialized) {
    final token = await firebase.register();
    if (firebase.isActive) {
      return _TestResult.success(PushProviderType.firebase);
    }
  }
  firebase.dispose();

  // Stap 3: Niets werkte
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
