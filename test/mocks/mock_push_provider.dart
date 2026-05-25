import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:plusly/features/push/domain/push_provider.dart';

class MockPushProvider extends Mock implements PushProvider {}

class FakePushMessage extends Fake implements PushMessage {}

void registerPushFakes() {
  registerFallbackValue(FakePushMessage());
}
