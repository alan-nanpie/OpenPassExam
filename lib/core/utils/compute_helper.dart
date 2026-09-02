import 'dart:convert';
import 'package:flutter/foundation.dart';

class ComputeHelper {
  ComputeHelper._();

  /// 在背景 Isolate 執行大量文字處理、日誌串接與格式化，杜絕 StringBuffer._addPart 引發之 ANR
  static Future<String> processLargeString(String rawData) async {
    if (rawData.length < 5000 && !rawData.contains('\n')) {
      return rawData;
    }
    return await compute(_backgroundStringProcessor, rawData);
  }

  /// 在背景 Isolate 解析大量 JSON 列表 (如 5000+ 考題)
  static Future<List<Map<String, dynamic>>> parseLargeJsonList(String jsonString) async {
    return await compute(_backgroundJsonListParser, jsonString);
  }

  /// 在背景 Isolate 格式化 RAG 教科書切片
  static Future<String> formatRagKnowledgeChunks(List<Map<String, dynamic>> chunks) async {
    return await compute(_backgroundRagFormatter, chunks);
  }

  // 頂層 Isolate 執行函式
  static String _backgroundStringProcessor(String input) {
    final buffer = StringBuffer();
    final lines = input.split('\n');
    for (int i = 0; i < lines.length; i++) {
      buffer.writeln(lines[i]);
    }
    return buffer.toString();
  }

  static List<Map<String, dynamic>> _backgroundJsonListParser(String jsonStr) {
    final decoded = jsonDecode(jsonStr);
    if (decoded is List) {
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  static String _backgroundRagFormatter(List<Map<String, dynamic>> rawChunks) {
    final sb = StringBuffer();
    sb.writeln('### 官方教科書精華知識庫 (GCS 6,688 Chunks)');
    for (final c in rawChunks) {
      sb.writeln('---');
      sb.writeln('**來源書目**: ${c['bookTitle']} (第 ${c['pageNumber']} 頁)');
      sb.writeln('**章節/考點**: ${c['chapter']} - ${c['topic']}');
      sb.writeln('**教材內容**:');
      sb.writeln(c['content']);
    }
    return sb.toString();
  }
}
