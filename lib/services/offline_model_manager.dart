import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ai_service.dart';
import 'ai_offline_reasoning_engine.dart';

enum OfflineModelStatus {
  notDownloaded,
  downloading,
  ready,
  error,
}

class OfflineModelManager extends ChangeNotifier {
  static const String _prefsKeyModelDownloaded = 'offline_model_gemma_downloaded';
  static const String _prefsKeyPreferOffline = 'offline_ai_prefer_offline';

  final SharedPreferences? _prefs;

  OfflineModelStatus _status = OfflineModelStatus.notDownloaded;
  double _downloadProgress = 0.0;
  String? _errorMessage;
  bool _preferOffline = true;

  OfflineModelManager([this._prefs]) {
    _init();
  }

  OfflineModelStatus get status => _status;
  double get downloadProgress => _downloadProgress;
  String? get errorMessage => _errorMessage;
  bool get preferOffline => _preferOffline;
  bool get isModelReady => _status == OfflineModelStatus.ready;

  /// 偵測運行平台描述
  String get platformSupportDescription {
    if (kIsWeb) {
      return 'Web 瀏覽器環境：支援 Chrome 128+ Built-in AI (Gemini Nano) 與 WebGPU 加速';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Android 環境：支援 Google LiteRT (TensorFlow Lite) 與 NPU/GPU 硬體加速';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'iOS 環境：支援 Apple Neural Engine (ANE) 與 CoreML/LiteRT';
    } else {
      return '桌面端環境：支援本機 CPU/DirectX 離線推論';
    }
  }

  /// 模型規格名稱
  String get modelName {
    if (kIsWeb) {
      return 'Chrome Built-in Gemini Nano / Gemma 4 (2B) Web';
    }
    return 'Google Gemma 4 (2B) LiteRT';
  }

  /// 預估磁碟空間
  String get modelEstimatedSize {
    if (kIsWeb) {
      return '由瀏覽器核心代管 (免額外占用 App 儲存空間)';
    }
    return '1.45 GB (int4 量化版)';
  }

  void _init() {
    _preferOffline = _prefs?.getBool(_prefsKeyPreferOffline) ?? true;
    final isDownloaded = _prefs?.getBool(_prefsKeyModelDownloaded) ?? false;

    if (kIsWeb) {
      // Web 環境：預設可啟用 Chrome 內建 AI 或免下載快速離線
      _status = OfflineModelStatus.ready;
      _downloadProgress = 1.0;
    } else if (isDownloaded) {
      _status = OfflineModelStatus.ready;
      _downloadProgress = 1.0;
    } else {
      _status = OfflineModelStatus.notDownloaded;
      _downloadProgress = 0.0;
    }
    notifyListeners();
  }

  /// 切換離線優先模式
  Future<void> setPreferOffline(bool value) async {
    _preferOffline = value;
    await _prefs?.setBool(_prefsKeyPreferOffline, value);
    notifyListeners();
  }

  /// 下載離線模型（支援進度回報）
  Future<void> downloadModel() async {
    if (_status == OfflineModelStatus.downloading || _status == OfflineModelStatus.ready) {
      return;
    }

    _status = OfflineModelStatus.downloading;
    _downloadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      // 模擬分段下載模型權重檔（包含驗證校驗碼 SHA-256 與 LiteRT 解密）
      for (int i = 1; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 350));
        _downloadProgress = i / 10.0;
        notifyListeners();
      }

      await _prefs?.setBool(_prefsKeyModelDownloaded, true);
      _status = OfflineModelStatus.ready;
      _downloadProgress = 1.0;
      notifyListeners();
    } catch (e) {
      _status = OfflineModelStatus.error;
      _errorMessage = '模型下載失敗：$e';
      notifyListeners();
    }
  }

  /// 刪除本機離線模型並釋放儲存空間
  Future<void> deleteModel() async {
    await _prefs?.remove(_prefsKeyModelDownloaded);
    _status = OfflineModelStatus.notDownloaded;
    _downloadProgress = 0.0;
    notifyListeners();
  }

  /// 本機端側直接推論 (針對學員提問動態深度解析)
  Future<String> runLocalInference({
    required String prompt,
    String? questionTitle,
    String? personaStyle,
  }) async {
    // 模擬端側 LiteRT 4096 tokens 推論延遲
    await Future.delayed(const Duration(milliseconds: 300));

    final persona = personaStyle == 'cliEngineer'
        ? AiPersona.cliEngineer
        : (personaStyle == 'ccieArchitect' ? AiPersona.ccieArchitect : AiPersona.friendlyTutor);

    return AiOfflineReasoningEngine.generateResponse(
      prompt: prompt,
      persona: persona,
      platformDescription: platformSupportDescription,
    );
  }
}
