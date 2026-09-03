import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'file_exporter_stub.dart'
    if (dart.library.js_interop) 'file_exporter_web.dart' as exporter;

class FileExporter {
  FileExporter._();

  /// 產生標準「西元年月日時分秒」格式檔名 (例如: 20260903_230530.md)
  static String generateTimestampFileName([DateTime? customTime]) {
    final time = customTime ?? DateTime.now();
    final formatter = DateFormat('yyyyMMdd_HHmmss');
    return '${formatter.format(time)}.md';
  }

  /// 匯出 Markdown 檔案
  ///
  /// - [markdownContent]: 要匯出的 Markdown 字串
  /// - [customFileName]: 選填，若未提供則預設為「西元年月日時分秒.md」
  static Future<bool> exportMarkdown({
    required String markdownContent,
    String? customFileName,
  }) async {
    final fileName = customFileName ?? generateTimestampFileName();
    try {
      final bytes = utf8.encode(markdownContent);
      return await exporter.saveAndDownloadFile(
        bytes: Uint8List.fromList(bytes),
        fileName: fileName,
        mimeType: 'text/markdown;charset=utf-8',
      );
    } catch (e) {
      debugPrint('FileExporter Error: $e');
      return false;
    }
  }
}
