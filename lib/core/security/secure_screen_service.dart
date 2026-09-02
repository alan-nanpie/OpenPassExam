import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SecureScreenService {
  SecureScreenService._();

  static const MethodChannel _channel = MethodChannel('com.passexam.app/security');

  /// 啟用原生層 FLAG_SECURE 防截圖、防錄影、防投影
  static Future<void> enableSecureScreen() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('enableSecureScreen');
    } catch (_) {
      // 在未註冊原生通道平台安全略過
    }
  }

  /// 停用原生層 FLAG_SECURE
  static Future<void> disableSecureScreen() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod('disableSecureScreen');
    } catch (_) {
      // 在未註冊原生通道平台安全略過
    }
  }
}
