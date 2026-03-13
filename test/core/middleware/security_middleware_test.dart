import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:safe_device/safe_device.dart';
import 'package:setup_flavor/core/config/flavor.dart';
import 'package:setup_flavor/core/middleware/security_middleware.dart';
import 'package:setup_flavor/routes/app_route.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const safeDeviceChannel = MethodChannel('safe_device');
  const jailbreakChannel = MethodChannel('jailbreak_root_detection');

  late bool developmentModeEnabled;
  late Object? jailbreakError;
  late Map<String, dynamic> jailbreakMethodResults;
  late int jailbreakMethodCallCount;

  setUp(() {
    Get.testMode = true;
    Get.clearRouteTree();
    Get.addPages(<GetPage<dynamic>>[
      GetPage<dynamic>(name: '/target', page: () => const SizedBox.shrink()),
      GetPage<dynamic>(
        name: AppRoute.securityBlocked,
        page: () => const SizedBox.shrink(),
      ),
    ]);

    AppEnv.flavor = Flavor.prod;
    SafeDevice.isInitiated = false;
    developmentModeEnabled = true;
    jailbreakError = null;
    jailbreakMethodCallCount = 0;
    jailbreakMethodResults = <String, dynamic>{
      'isJailBroken': false,
      'isDevMode': false,
      'isRealDevice': true,
      'isOnExternalStorage': false,
      'checkForIssues': <String>[],
    };

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(safeDeviceChannel, (call) async {
      if (call.method == 'init') {
        return null;
      }
      if (call.method == 'isDevelopmentModeEnable') {
        return developmentModeEnabled;
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(jailbreakChannel, (call) async {
      jailbreakMethodCallCount += 1;
      if (jailbreakError != null && call.method == 'isJailBroken') {
        throw jailbreakError!;
      }
      if (jailbreakMethodResults.containsKey(call.method)) {
        return jailbreakMethodResults[call.method];
      }
      return null;
    });
  });

  tearDown(() {
    SafeDevice.isInitiated = false;
    Get.clearRouteTree();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(safeDeviceChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(jailbreakChannel, null);
  });

  test('redirectDelegate returns null when development mode is disabled', () async {
    developmentModeEnabled = false;
    final middleware = SecurityMiddleware();
    final route = GetNavConfig.fromRoute('/target')!;

    final redirected = await middleware.redirectDelegate(route);

    expect(redirected, isNull);
    expect(jailbreakMethodCallCount, 0);
  });

  test('redirectDelegate keeps current route when security checks pass', () async {
    developmentModeEnabled = true;
    final middleware = SecurityMiddleware();
    final route = GetNavConfig.fromRoute('/target')!;

    final redirected = await middleware.redirectDelegate(route);

    expect(identical(redirected, route), isTrue);
  });

  test('redirectDelegate sends user to blocked route when compromised', () async {
    developmentModeEnabled = true;
    jailbreakMethodResults['isJailBroken'] = true;
    final middleware = SecurityMiddleware();
    final route = GetNavConfig.fromRoute('/target')!;

    final redirected = await middleware.redirectDelegate(route);

    expect(redirected?.locationString, AppRoute.securityBlocked);
  });

  test('redirectDelegate sends user to blocked route when security check throws', () async {
    developmentModeEnabled = true;
    jailbreakError = PlatformException(
      code: 'jailbreak_error',
      message: 'jailbreak check failed',
    );
    final middleware = SecurityMiddleware();
    final route = GetNavConfig.fromRoute('/target')!;

    final redirected = await middleware.redirectDelegate(route);

    expect(redirected?.locationString, AppRoute.securityBlocked);
  });
}
