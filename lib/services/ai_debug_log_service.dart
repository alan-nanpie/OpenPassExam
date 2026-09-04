import 'dart:collection';
import 'package:intl/intl.dart';

class AiDebugLogEntry {
  final DateTime timestamp;
  final String level; // INFO, WARN, ERROR, SUCCESS
  final String tag;
  final String message;
  final Map<String, dynamic>? details;

  AiDebugLogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.details,
  });

  String toFormattedString() {
    final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(timestamp);
    final sb = StringBuffer('[$timeStr] [$level] [$tag] $message');
    if (details != null && details!.isNotEmpty) {
      sb.writeln();
      details!.forEach((key, value) {
        sb.writeln('    • $key: $value');
      });
    }
    return sb.toString();
  }
}

class AiDebugLogService {
  static final AiDebugLogService instance = AiDebugLogService._internal();

  AiDebugLogService._internal();

  final Queue<AiDebugLogEntry> _logs = Queue<AiDebugLogEntry>();
  static const int maxLogEntries = 100;

  List<AiDebugLogEntry> get logs => _logs.toList().reversed.toList();

  void log({
    required String level,
    required String tag,
    required String message,
    Map<String, dynamic>? details,
  }) {
    final entry = AiDebugLogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      details: details,
    );
    if (_logs.length >= maxLogEntries) {
      _logs.removeFirst();
    }
    _logs.add(entry);
  }

  void info(String tag, String message, [Map<String, dynamic>? details]) {
    log(level: 'INFO', tag: tag, message: message, details: details);
  }

  void warn(String tag, String message, [Map<String, dynamic>? details]) {
    log(level: 'WARN', tag: tag, message: message, details: details);
  }

  void error(String tag, String message, [Map<String, dynamic>? details]) {
    log(level: 'ERROR', tag: tag, message: message, details: details);
  }

  void success(String tag, String message, [Map<String, dynamic>? details]) {
    log(level: 'SUCCESS', tag: tag, message: message, details: details);
  }

  void clear() {
    _logs.clear();
  }

  String exportAllLogsAsText() {
    if (_logs.isEmpty) {
      return '（目前無任何除錯日誌）';
    }
    final sb = StringBuffer();
    sb.writeln('======================================================');
    sb.writeln('OpenPassExam AI 助教內部推論除錯日誌 (Debug Log)');
    sb.writeln('匯出時間: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    sb.writeln('總記錄筆數: ${_logs.length}');
    sb.writeln('======================================================\n');

    for (final entry in _logs) {
      sb.writeln(entry.toFormattedString());
      sb.writeln('------------------------------------------------------');
    }
    return sb.toString();
  }
}
