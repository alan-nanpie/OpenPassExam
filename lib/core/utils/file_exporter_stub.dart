import 'dart:typed_data';

Future<bool> saveAndDownloadFile({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) async {
  // 非 Web 原生平台 (桌面與行動端) 預設處理
  return true;
}
