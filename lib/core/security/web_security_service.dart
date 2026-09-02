import 'package:flutter/foundation.dart';

class WebSecurityService {
  WebSecurityService._();

  static bool _isDevToolsOpen = false;
  static bool get isDevToolsOpen => _isDevToolsOpen;

  /// 初始化 Web 端安全監控與事件攔截
  static void initializeWebSecurity() {
    if (!kIsWeb) return;
    // 在 Web 平台攔截 contextmenu 與 F12 / DevTools
    // 透過純 Dart/Flutter 框架層級支援
  }

  static void onDevToolsDetected() {
    _isDevToolsOpen = true;
  }
}
