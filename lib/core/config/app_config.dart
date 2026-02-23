import 'package:setup_flavor/core/config/env.dart';
import 'package:setup_flavor/core/config/flavor.dart';

class AppConfig {
  static late Flavor flavor;
  static late Env env;

  static void init(Flavor f) {
    flavor = f;

    switch (f) {
      case Flavor.dev:
        env = const Env(
          appName: 'App DEV',
          baseUrl: 'https://dev.com',
          enableLog: true,
        );
        break;
      case Flavor.uat:
        env = const Env(
          appName: 'App UAT',
          baseUrl: 'https://aut.com',
          enableLog: true,
        );
        break;
      case Flavor.prod:
        env = const Env(
          appName: 'App PRODUCTION',
          baseUrl: 'https://production.com',
          enableLog: false,
        );
        break;
    }
  }
}
