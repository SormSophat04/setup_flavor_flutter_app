import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ApiService extends GetxService {
  final Dio dio;
  ApiService(this.dio);
}
