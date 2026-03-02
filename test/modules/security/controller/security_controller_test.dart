import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:setup_flavor/modules/security/controller/security_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const jailbreakChannel = MethodChannel('jailbreak_root_detection');

  late Map<String, dynamic> methodResults;

  setUp(() {
    methodResults = <String, dynamic>{
      'isJailBroken': true,
      'isDevMode': true,
      'isNotTrust': true,
      'isRealDevice': false,
      'isOnExternalStorage': true,
      'checkForIssues': <String>['jailbreak', 'devMode', 'unexpectedIssue'],
    };

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(jailbreakChannel, (call) async {
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

  test('checkSecurityStatus maps plugin values into observable flags', () async {
    final controller = SecurityController();

    await controller.checkSecurityStatus();

    expect(controller.isJailBroken.value, isTrue);
    expect(controller.isDevMode.value, isTrue);
    expect(controller.isNotTrust.value, isTrue);
    expect(controller.isRealDevice.value, isFalse);
    expect(controller.isOnExternalStorage.value, isTrue);
    expect(
      controller.securityIssues,
      <String>['jailbreak', 'devMode', 'unknown'],
    );
  });

  test('checkSecurityStatus updates values on subsequent checks', () async {
    final controller = SecurityController();

    await controller.checkSecurityStatus();

    methodResults = <String, dynamic>{
      'isJailBroken': false,
      'isDevMode': false,
      'isNotTrust': false,
      'isRealDevice': true,
      'isOnExternalStorage': false,
      'checkForIssues': <String>[],
    };

    await controller.checkSecurityStatus();

    expect(controller.isJailBroken.value, isFalse);
    expect(controller.isDevMode.value, isFalse);
    expect(controller.isNotTrust.value, isFalse);
    expect(controller.isRealDevice.value, isTrue);
    expect(controller.isOnExternalStorage.value, isFalse);
    expect(controller.securityIssues, isEmpty);
  });
}
