import 'package:logger/logger.dart';

class LogUtil {
  static LogUtil _singleton;

  Logger logger;

  LogUtil._();

  factory LogUtil() {
    return _singleton;
  }

  static LogUtil init() {
    if (_singleton == null) {
      Logger _logger = Logger(level: Level.debug, printer: PrettyPrinter());
      _singleton = LogUtil._();
      _singleton.logger = _logger;
    }
    return _singleton;
  }

  static Logger getInstance() {
    if (_singleton == null) {
      init();
    }
    return _singleton.logger;
  }

  static void writeLog(String log) {
    _singleton.logger.d(log);
  }
}