import 'package:base_library/base_library.dart';
import 'package:dio/dio.dart';

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
}
