import 'package:dio/dio.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.137.22/screenify/',
        connectTimeout: Duration(seconds: 30),
        receiveTimeout: Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    // dio.interceptors.add(LogInterceptor(responseBody: true));

    return dio;
  }
}
