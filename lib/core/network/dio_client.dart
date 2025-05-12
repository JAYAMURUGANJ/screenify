import 'package:dio/dio.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.163.2.238/vg/screenify/',
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    // dio.interceptors.add(LogInterceptor(responseBody: true));

    return dio;
  }
}
