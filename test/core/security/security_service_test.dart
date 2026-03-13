import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setup_flavor/core/config/flavor.dart';
import 'package:setup_flavor/core/security/security_exception.dart';
import 'package:setup_flavor/core/security/security_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const jailbreakChannel = MethodChannel('jailbreak_root_detection');

  late Map<String, dynamic> methodResults;
  late int methodCallCount;

  setUp(() {
    methodCallCount = 0;
    methodResults = <String, dynamic>{
      'isJailBroken': false,
      'isDevMode': false,
      'isRealDevice': true,
      'isOnExternalStorage': false,
      'checkForIssues': <String>[],
    };

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(jailbreakChannel, (call) async {
      methodCallCount += 1;
      if (methodResults.containsKey(call.method)) {
        return methodResults[call.method];
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(jailbreakChannel, null);
  });

  test('enforceSecurity bypasses checks in dev flavor', () async {
    AppEnv.flavor = Flavor.dev;
    final service = SecurityService();

    await service.enforceSecurity();

    expect(methodCallCount, 0);
  });

  test('enforceSecurity bypasses checks in uat flavor', () async {
    AppEnv.flavor = Flavor.uat;
    final service = SecurityService();

    await service.enforceSecurity();

    expect(methodCallCount, 0);
  });

  test('enforceSecurity does not throw in prod when device is secure', () async {
    AppEnv.flavor = Flavor.prod;
    final service = SecurityService();

    await service.enforceSecurity();

    expect(methodCallCount, greaterThan(0));
  });

  test('enforceSecurity throws in prod when device is compromised', () async {
    AppEnv.flavor = Flavor.prod;
    methodResults['isJailBroken'] = true;
    final service = SecurityService();

    await expectLater(
      service.enforceSecurity(),
      throwsA(isA<SecurityException>()),
    );
  });
}
