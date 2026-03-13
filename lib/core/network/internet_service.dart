import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetService {
  Future<bool> hasNetworkConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<bool> hasInternetConnection() async {
    return await InternetConnection().hasInternetAccess;
  }

  Future<bool> isOnline() async {
    final network = await hasNetworkConnection();
    final internet = await hasInternetConnection();
    if (!network) {
      return false;
    }
    if (!internet) {
      return false;
    }
    return network && internet;
  }
}
