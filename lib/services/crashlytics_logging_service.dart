import 'dart:developer' as developer;

class CrashlyticsLoggingService {
  CrashlyticsLoggingService._();

  static void log(String message, {String tag = 'PassExam'}) {
    developer.log('[$tag] $message');
  }

  static void recordError(dynamic error, StackTrace? stack, {String? reason}) {
    developer.log(
      '❌ [ERROR] ${reason ?? ''}: $error',
      error: error,
      stackTrace: stack,
    );
  }
}
