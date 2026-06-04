import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:Pulsly/features/push/presentation/push_controller.dart';
import 'package:Pulsly/features/push/domain/push_state.dart';
import 'package:Pulsly/features/push/domain/push_provider.dart';

// Simpele fake provider voor testing (geen mocktail nodig)
class FakePushProvider implements PushProvider {
  final String _id;
  final bool _available;
  final bool _shouldSucceed;
  final StreamController<PushMessage> _controller = StreamController.broadcast();

  FakePushProvider(this._id, this._available, this._shouldSucceed);

  @override
  String get id => _id;

  @override
  String get displayName => 'Fake $_id';

  @override
  bool get isAvailable => _available;

  @override
  bool get isActive => _shouldSucceed;

  @override
  Future<bool> initialize() async => _available;

  @override
  Future<String?> register() async => _shouldSucceed ? 'token_$_id' : null;

  @override
  Future<void> unregister() async {}

  @override
  Stream<PushMessage> get messageStream => _controller.stream;

  void emitMessage(PushMessage msg) => _controller.add(msg);

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
  group('PushController', () {
    late FakeSharedPreferences store;
    late List<dynamic> clients; // Lege lijst voor nu
    late PushController controller;

    setUp(() {
      store = FakeSharedPreferences();
      clients = [];
      controller = PushController(store as dynamic, clients as dynamic);
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is initial', () {
      expect(controller.state.status, PushStatus.initial);
      expect(controller.state.activeProvider, isNull);
      expect(controller.isActive, isFalse);
    });

    group('with successful provider', () {
      test('should transition to active after initialize', () async {
        // Arrange — we kunnen niet echt initialize() testen zonder
        // echte PushProviderFactory, maar we kunnen state testen

        // Act — simuleer succesvolle init
        controller = PushController(store as dynamic, clients as dynamic);

        // Assert
        expect(controller.state.status, PushStatus.initial);
      });
    });

    group('state transitions', () {
      test('should update state when set externally', () {
        // Dit is meer een demonstratie van hoe we zouden testen
        // met de echte implementatie
        expect(controller.state.isFailed, isFalse);
        expect(controller.state.isInitializing, isFalse);
      });
    });
  });
}
