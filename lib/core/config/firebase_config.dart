import 'package:firebase_core/firebase_core.dart';
import 'package:setup_flavor/core/config/app_config.dart';
import 'package:setup_flavor/core/config/flavor.dart';

class FirebaseConfig {
  static Future<void> init() async {
    switch (AppConfig.flavor) {
      case Flavor.dev:
        await Firebase.initializeApp();
        break;
      case Flavor.uat:
        await Firebase.initializeApp();
        break;
      case Flavor.prod:
        await Firebase.initializeApp();
        break;
    }
  }
}
