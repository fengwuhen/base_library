import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

import 'interceptors/log_interceptor.dart';

Dio _dio = Dio();

Dio get dio => _dio;

class DioManager {
  static Future init({String baseUrl, int time = 30 * 1000}) async {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = time;
    dio.options.sendTimeout = time;
    dio.options.receiveTimeout = time;
    dio.options.contentType = Headers.formUrlEncodedContentType;

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    dio.interceptors.add(LogInterceptors());
    // dio.interceptors.add(ErrorInterceptors());
  }
}
