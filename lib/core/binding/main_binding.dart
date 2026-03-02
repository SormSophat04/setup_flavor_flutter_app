import 'package:get/get.dart';
import 'package:setup_flavor/core/security/device_security.dart';
import 'package:setup_flavor/modules/auth/controller/auth_controller.dart';
import 'package:setup_flavor/modules/security/controller/security_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeviceSecurity>(() => DeviceSecurity());
    Get.lazyPut<SecurityController>(() => SecurityController());

    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(), permanent: true);
    }
  }
}
