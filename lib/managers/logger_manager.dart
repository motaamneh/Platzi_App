import 'package:logger/logger.dart';

class LoggerManager {
  static final LoggerManager _instance = LoggerManager._internal();
  factory LoggerManager() => _instance;
  LoggerManager._internal();
  
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  
  void debug(String message) {
    _logger.d(message);
  }
  
  void info(String message) {
    _logger.i(message);
  }
  
  void warning(String message) {
    _logger.w(message);
  }
  
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}