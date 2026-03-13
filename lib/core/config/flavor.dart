enum Flavor { dev, uat, prod }

class AppEnv {
  static late Flavor flavor;

  static bool get isDev => flavor == Flavor.dev;
  static bool get isUat => flavor == Flavor.uat;
  static bool get isProd => flavor == Flavor.prod;
}
