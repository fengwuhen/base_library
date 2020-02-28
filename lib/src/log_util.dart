import 'package:logger/logger.dart';

class LogUtil {
  static Logger _logger;

  static Future init({Logger logger}) async {
    _logger = logger ?? Logger(level: Level.debug, printer: PrettyPrinter());
  }

  static void writeLog(String message) {
    _logger.d(message);
  }
}
