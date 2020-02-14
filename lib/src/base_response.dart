import 'package:dio/dio.dart';

class BaseResponse<T> {
  String status;
  int code;
  String msg;
  T data;
  Response response;

  BaseResponse({this.status, this.code, this.data, this.msg, this.response});

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('{');
    sb.write("\"status\":\"$status\"");
    sb.write(",\"code\":$code");
    sb.write(",\"msg\":\"$msg\"");
    sb.write(",\"data\":\"$data\"");
    sb.write('}');
    return sb.toString();
  }
}
