import 'dart:io';

import 'package:dio/dio.dart';

import '../log_util.dart';
import '../toast_util.dart';

/// 请求日志拦截器
class LogInterceptors extends InterceptorsWrapper {
  @override
  Future onRequest(RequestOptions options) async {
    String message =
        '──────────────────────Begin Request─────────────────────\n';
    message += getPrintKV('uri', options.uri) + '\n';
    message += getPrintKV('method', options.method) + '\n';
    message += getPrintKV('queryParameters', options.queryParameters) + '\n';
    message += getPrintKV('contentType', options.contentType.toString()) + '\n';
    message +=
        getPrintKV('responseType', options.responseType.toString()) + '\n';

    StringBuffer stringBuffer = new StringBuffer();
    options.headers.forEach((key, v) => stringBuffer.write('\n  $key: $v'));
    message += getPrintKV('headers', stringBuffer.toString()) + '\n';
    stringBuffer.clear();

    if (options.data != null) {
      message += getPrintKV('body', options.data) + '\n';
    }
    message += '——————————————————————End Request———————————————————————';
    print(message);
    return options;
  }

  @override
  Future onResponse(Response response) async {
    String message =
        '──────────────────────Begin Response—————————————————————\n';
    message += getPrintKV('uri', response.request.uri) + '\n';
    message += getPrintKV('status', response.statusCode) + '\n';
    message +=
        getPrintKV('responseType', response.request.responseType.toString()) +
            '\n';

    StringBuffer stringBuffer = new StringBuffer();
    response.headers.forEach((key, v) => stringBuffer.write('\n  $key: $v'));
    message += getPrintKV('headers', stringBuffer.toString()) + '\n';
    stringBuffer.clear();

    message += '——————————————————————End Response———————————————————————';
    print(message);
    return response;
  }

  @override
  Future onError(DioError err) async {
    String errorMsg = handleError(err);
    ToastUtil.show(errorMsg);
    String message =
        '──────────────────────Begin Dio Error—————————————————————\n';
    message += getPrintKV('error', err.toString()) + '\n';
    message +=
        getPrintKV('error message', (err.response?.toString() ?? '')) + '\n';
    message += '——————————————————————End Dio Error———————————————————————';
    print(message);
    return err;
  }

  void print(String message) {
    LogUtil.writeLog(message);
  }

  String getPrintKV(String key, Object value) {
    return '$key: $value';
  }

  String handleError(error) {
    String errorText = '未知错误';
    if (error is DioError) {
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        errorText = '连接超时';
      } else if (error.type == DioErrorType.SEND_TIMEOUT) {
        errorText = '请求超时';
      } else if (error.type == DioErrorType.RECEIVE_TIMEOUT) {
        errorText = '响应超时';
      } else if (error.type == DioErrorType.CANCEL) {
        errorText = '请求取消';
      } else if (error.type == DioErrorType.RESPONSE) {
        int statusCode = error.response.statusCode;
        String msg = error.response.statusMessage;
        switch (statusCode) {
          case 500:
            errorText = '服务器异常';
            break;
          case 404:
            errorText = '未找到资源';
            break;
          default:
            errorText = '$msg[$statusCode]';
            break;
        }
      } else if (error.type == DioErrorType.DEFAULT) {
        errorText = '${error.message}';
        if (error.error is SocketException) {
          errorText = '网络连接超时';
        }
      } else {
        errorText = '未知错误';
      }
    }
    return errorText;
  }
}
