import 'dart:convert';
import 'dart:io';

import 'package:base_library/index.dart';
import 'package:dio/dio.dart';

import '../toast_util.dart';

class ErrorInterceptors extends InterceptorsWrapper {
  String _statusKey = "status";
  String _codeKey = "errorCode";
  String _msgKey = "errorMsg";
  String _dataKey = 'data';

  @override
  Future onRequest(RequestOptions options) async {
    return options;
  }

  @override
  Future onError(DioError err) async {
    String errorMsg = handleError(err);
    ToastUtil.show(errorMsg);
    return err;
  }

  @override
  Future onResponse(Response response) async {
    String _status;
    int _code;
    String _msg;
    String _data;
    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      var data = response.data;

      if (data is String) {
        data = json.decode(data);
      }

      if (response.data is Map) {
        _status = (response.data[_statusKey] is int)
            ? response.data[_statusKey].toString()
            : response.data[_statusKey];
        _code = (response.data[_codeKey] is String)
            ? int.tryParse(response.data[_codeKey])
            : response.data[_codeKey];
        _msg = response.data[_msgKey];
        _data = response.data[_dataKey].toString();
      } else {
        Map<String, dynamic> _dataMap = _decodeData(response);
        _status = (_dataMap[_statusKey] is int)
            ? _dataMap[_statusKey].toString()
            : _dataMap[_statusKey];
        _code = (_dataMap[_codeKey] is String)
            ? int.tryParse(_dataMap[_codeKey])
            : _dataMap[_codeKey];
        _msg = _dataMap[_msgKey];
        _data = _dataMap[_dataKey].toString();
      }
      return BaseResponse(
          status: _status,
          code: _code,
          data: _data,
          msg: _msg,
          response: response);
    }
    return response;
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

  Map<String, dynamic> _decodeData(Response response) {
    if (response == null ||
        response.data == null ||
        response.data.toString().isEmpty) {
      return Map();
    }
    return json.decode(response.data.toString());
  }
}
