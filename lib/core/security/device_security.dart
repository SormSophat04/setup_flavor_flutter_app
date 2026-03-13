import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';

class DeviceSecurity {
  Future<bool> isCompromised() async {
    final isNotTrust = await JailbreakRootDetection.instance.isNotTrust;
    final isRealDevice = await JailbreakRootDetection.instance.isRealDevice;
    final isOnExternalStorage =
        await JailbreakRootDetection.instance.isOnExternalStorage;
    final checkForIssues = await JailbreakRootDetection.instance.checkForIssues;

    final isJailBroken = await JailbreakRootDetection.instance.isJailBroken;
    final isDevMode = await JailbreakRootDetection.instance.isDevMode;

    return isJailBroken ||
        isDevMode ||
        isNotTrust ||
        !isRealDevice ||
        checkForIssues.isNotEmpty ||
        isOnExternalStorage;
  }
}
