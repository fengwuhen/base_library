import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';

import 'base_response.dart';
import 'log_util.dart';

/// 请求方式
class Method {
  static final String get = "GET";
  static final String post = "POST";
  static final String put = "PUT";
  static final String head = "HEAD";
  static final String delete = "DELETE";
  static final String patch = "PATCH";
}

/// http配置
class HttpConfig {
  HttpConfig({
    this.status,
    this.code,
    this.msg,
    this.data,
    this.options,
    this.pem,
    this.pKCSPath,
    this.pKCSPwd,
  });

  /// BaseResponse [String status]字段 key, 默认：status.
  String status;

  /// BaseResponse [int code]字段 key, 默认：errorCode.
  String code;

  /// BaseResponse [String msg]字段 key, 默认：errorMsg.
  String msg;

  /// BaseResponse [T data]字段 key, 默认：data.
  String data;

  /// Options.
  BaseOptions options;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PEM证书内容.
  String pem;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PKCS12 证书路径.
  String pKCSPath;

  /// 详细使用请查看dio官网 https://github.com/flutterchina/dio/blob/flutter/README-ZH.md#Https证书校验.
  /// PKCS12 证书密码.
  String pKCSPwd;
}

/// DioUtil.
/// debug模式下可以打印请求日志. DioUtil.openDebug().
/// dio详细使用请查看dio官网(https://github.com/flutterchina/dio).
class DioUtil {
  static DioUtil _singleton;
  static Dio _dio;

  static DioUtil getInstance() {
    if (_singleton == null) {
      // keep local instance till it is fully initialized.
      // 保持本地实例直到完全初始化。
      var singleton = DioUtil._();
      singleton._init();
      _singleton = singleton;
    }
    return _singleton;
  }

  DioUtil._();

  _init() {
    _dio = Dio(_options);
  }

  /// BaseResp [String status]字段 key, 默认：status.
  static String _statusKey = "status";

  /// BaseResp [int code]字段 key, 默认：errorCode.
  static String _codeKey = "errorCode";

  /// BaseResp [String msg]字段 key, 默认：errorMsg.
  static String _msgKey = "errorMsg";

  /// BaseResp [T data]字段 key, 默认：data.
  static String _dataKey = "data";

  /// Options.
  static BaseOptions _options = getDefaultOptions();

  /// PEM证书内容.
  static String _pem;

  /// PKCS12 证书路径.
  static String _pKCSPath;

  /// PKCS12 证书密码.
  static String _pKCSPwd;

  /// 是否是debug模式.
  static bool _isDebug = false;

  /// 打开debug模式.
  static void openDebug() {
    _isDebug = true;
  }

  static void setCookie(String cookie) {
    Map<String, dynamic> _headers = Map();
    _headers["Cookie"] = cookie;
    _dio.options.headers.addAll(_headers);
  }

  /// set Config.
  static void setConfig(HttpConfig config) {
    _statusKey = config.status ?? _statusKey;
    _codeKey = config.code ?? _codeKey;
    _msgKey = config.msg ?? _msgKey;
    _dataKey = config.data ?? _dataKey;
    _mergeOption(config.options);
    _pem = config.pem ?? _pem;
    if (_dio != null) {
      _dio.options = _options;
      if (_pem != null) {
        (_dio.httpClientAdapter as DefaultHttpClientAdapter)
            .onHttpClientCreate = (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
            if (cert.pem == _pem) {
              // 证书一致，则放行
              return true;
            }
            return false;
          };
        };
      }
      if (_pKCSPath != null) {
        (_dio.httpClientAdapter as DefaultHttpClientAdapter)
            .onHttpClientCreate = (HttpClient client) {
          SecurityContext sc = SecurityContext();
          //file为证书路径
          sc.setTrustedCertificates(_pKCSPath, password: _pKCSPwd);
          HttpClient httpClient = HttpClient(context: sc);
          return httpClient;
        };
      }
    }
  }

  /// Make http request with options.
  /// [method] The request method.
  /// [path] The url path.
  /// [data] The request data
  /// [options] The request options.
  /// <BaseResponse<T> 返回 status code msg data .
  static Future<BaseResponse<T>> request<T>(String method, String path,
      {data, Options options, CancelToken cancelToken}) async {
    Response response = await _dio.request(path,
        data: data,
        options: _checkOptions(method, options),
        cancelToken: cancelToken);
    _printHttpLog(response);
    String _status;
    int _code;
    String _msg;
    T _data;
    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      try {
        if (response.data is Map) {
          _status = (response.data[_statusKey] is int)
              ? response.data[_statusKey].toString()
              : response.data[_statusKey];
          _code = (response.data[_codeKey] is String)
              ? int.tryParse(response.data[_codeKey])
              : response.data[_codeKey];
          _msg = response.data[_msgKey];
          _data = response.data[_dataKey];
        } else {
          Map<String, dynamic> _dataMap = _decodeData(response);
          _status = (_dataMap[_statusKey] is int)
              ? _dataMap[_statusKey].toString()
              : _dataMap[_statusKey];
          _code = (_dataMap[_codeKey] is String)
              ? int.tryParse(_dataMap[_codeKey])
              : _dataMap[_codeKey];
          _msg = _dataMap[_msgKey];
          _data = _dataMap[_dataKey];
        }
        return BaseResponse(
            status: _status, code: _code, data: _data, msg: _msg);
      } catch (e) {
        return Future.error(DioError(
          response: response,
          error: "data parsing exception...",
          type: DioErrorType.RESPONSE,
        ));
      }
    }
    return Future.error(DioError(
      response: response,
      error: "statusCode: $response.statusCode, service error",
      type: DioErrorType.RESPONSE,
    ));
  }

  /// Make http request with options.
  /// [method] The request method.
  /// [path] The url path.
  /// [data] The request data
  /// [options] The request options.
  /// <BaseResponse<T> 返回 status code msg data  Response.
  Future<BaseResponse<T>> requestR<T>(String method, String path,
      {data, Options options, CancelToken cancelToken}) async {
    Response response = await _dio.request(path,
        data: data,
        options: _checkOptions(method, options),
        cancelToken: cancelToken);
    _printHttpLog(response);
    String _status;
    int _code;
    String _msg;
    T _data;
    if (response.statusCode == HttpStatus.ok ||
        response.statusCode == HttpStatus.created) {
      try {
        if (response.data is Map) {
          _status = (response.data[_statusKey] is int)
              ? response.data[_statusKey].toString()
              : response.data[_statusKey];
          _code = (response.data[_codeKey] is String)
              ? int.tryParse(response.data[_codeKey])
              : response.data[_codeKey];
          _msg = response.data[_msgKey];
          _data = response.data[_dataKey];
        } else {
          Map<String, dynamic> _dataMap = _decodeData(response);
          _status = (_dataMap[_statusKey] is int)
              ? _dataMap[_statusKey].toString()
              : _dataMap[_statusKey];
          _code = (_dataMap[_codeKey] is String)
              ? int.tryParse(_dataMap[_codeKey])
              : _dataMap[_codeKey];
          _msg = _dataMap[_msgKey];
          _data = _dataMap[_dataKey];
        }
        return BaseResponse(
            status: _status,
            code: _code,
            data: _data,
            msg: _msg,
            response: response);
      } catch (e) {
        return Future.error(DioError(
          response: response,
          error: "data parsing exception...",
          type: DioErrorType.RESPONSE,
        ));
      }
    }
    return Future.error(DioError(
      response: response,
      error: "statusCode: $response.statusCode, service error",
      type: DioErrorType.RESPONSE,
    ));
  }

  /// decode response data.
  static Map<String, dynamic> _decodeData(Response response) {
    if (response == null ||
        response.data == null ||
        response.data.toString().isEmpty) {
      return Map();
    }
    return json.decode(response.data.toString());
  }

  /// check Options.
  static Options _checkOptions(method, options) {
    if (options == null) {
      options = Options();
    }
    options.method = method;
    return options;
  }

  /// merge Option.
  static void _mergeOption(BaseOptions opt) {
    _options.method = opt.method ?? _options.method;
    _options.headers = (Map.from(_options.headers))..addAll(opt.headers);
    _options.baseUrl = opt.baseUrl ?? _options.baseUrl;
    _options.connectTimeout = opt.connectTimeout ?? _options.connectTimeout;
    _options.receiveTimeout = opt.receiveTimeout ?? _options.receiveTimeout;
    _options.responseType = opt.responseType ?? _options.responseType;
    // _options.data = opt.data ?? _options.data;
    _options.extra = (Map.from(_options.extra))..addAll(opt.extra);
    _options.contentType = opt.contentType ?? _options.contentType;
    _options.validateStatus = opt.validateStatus ?? _options.validateStatus;
    _options.followRedirects = opt.followRedirects ?? _options.followRedirects;
  }

  /// print Http Log.
  static void _printHttpLog(Response response) {
    if (!_isDebug) {
      return;
    }
    try {
      String log = '----------------Http Log----------------' +
          '\n[status ]:  ' +
          response.statusCode.toString() +
          '\n[reqdata]:  ' +
          _getRequestData(response.request) +
          '\n[resdata]:  ' +
          response.data.toString();
      LogUtil.getInstance().d(log);
    } catch (ex) {
      String log = '---------------Http Error---------------' + ex.toString();
      LogUtil.getInstance().d(log);
    }
  }

  /// get Options Str.
  static String _getRequestData(RequestOptions request) {
    return 'method: ' +
        request.method +
        '  baseUrl: ' +
        request.baseUrl +
        '  path: ' +
        request.path +
        ((request.data != null && request.data.toString().isNotEmpty)
            ? '  data: ' + request.data.toString()
            : '');
  }

  /// get dio.
  static Dio getDio() {
    return _dio;
  }

  /// create new dio.
  static Dio createNewDio([BaseOptions options]) {
    options = options ?? getDefaultOptions();
    Dio dio = Dio(options);
    return dio;
  }

  /// get Def Options.
  static BaseOptions getDefaultOptions() {
    BaseOptions options = BaseOptions(
        baseUrl: 'https://www.wanandroid.com/',
        connectTimeout: 1000 * 30,
        receiveTimeout: 1000 * 30,
        contentType: Headers.formUrlEncodedContentType);
    return options;
  }
}
