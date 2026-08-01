import 'dart:developer';

class ApiLogger {
  static void logInfo(String message) {
    log('ℹ️ INFO: $message', name: 'API');
  }

  static void logError(String message,
      [dynamic error, StackTrace? stackTrace]) {
    log('❌ ERROR: $message', name: 'API', error: error, stackTrace: stackTrace);
  }

  static void logWarning(String message) {
    log('⚠️ WARNING: $message', name: 'API');
  }
}
