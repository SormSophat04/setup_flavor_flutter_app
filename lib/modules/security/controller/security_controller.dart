import 'package:get/get.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';

class SecurityController extends GetxController {
  final RxBool isJailBroken = false.obs;
  final RxBool isDevMode = false.obs;
  final RxBool isNotTrust = false.obs;
  final RxBool isRealDevice = true.obs;
  final RxBool isOnExternalStorage = false.obs;
  final RxList<String> securityIssues = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    checkSecurityStatus();
  }

  Future<void> checkSecurityStatus() async {
    final instance = JailbreakRootDetection.instance;

    isJailBroken.value = await instance.isJailBroken;
    isDevMode.value = await instance.isDevMode;
    isNotTrust.value = await instance.isNotTrust;
    isRealDevice.value = await instance.isRealDevice;
    isOnExternalStorage.value = await instance.isOnExternalStorage;

    final issues = await instance.checkForIssues;
    securityIssues.assignAll(issues.map((e) => e.name).toList());
  }
}
