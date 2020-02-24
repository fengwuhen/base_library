import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

import 'interceptors/error_interceptor.dart';
import 'interceptors/log_interceptor.dart';

Dio _dio = Dio();

Dio get dio => _dio;

class DioManager {
  static Future init() async {
    dio.options.baseUrl = 'https://www.wanandroid.com/';
    dio.options.connectTimeout = 30 * 1000;
    dio.options.sendTimeout = 30 * 1000;
    dio.options.receiveTimeout = 30 * 1000;
    dio.options.contentType = Headers.formUrlEncodedContentType;

    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    dio.interceptors.add(LogInterceptors());
    dio.interceptors.add(ErrorInterceptors());
  }
}
