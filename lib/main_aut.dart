import 'package:setup_flavor/core/config/app_config.dart';
import 'package:setup_flavor/core/config/flavor.dart';
import 'package:setup_flavor/main_common.dart';

void main(){
  AppConfig.init(Flavor.uat);
  bootstrap();
}