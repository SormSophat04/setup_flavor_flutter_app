import 'package:setup_flavor/core/config/flavor.dart';
import 'package:setup_flavor/core/security/device_security.dart';
import 'package:setup_flavor/core/security/security_exception.dart';

class SecurityService {
  final DeviceSecurity _deviceSecurity = DeviceSecurity();

  Future<void> enforceSecurity() async {
    if (AppEnv.isDev || AppEnv.isUat) {
      return;
    }

    final compromised = await _deviceSecurity.isCompromised();

    if (compromised) {
      throw SecurityException();
    }
  }
}
