import '../data/models/ai_model_config.dart';

class RemoteConfigService {
  AiModelConfig _remoteConfig = AiModelConfig(
    primaryModel: 'gemini-3.8-flash',
    fallbackModel: 'gemini-3.6-flash',
    temperature: 1.0,
    maxTokens: 16384,
    thinkingBudget: 4096,
    thinkingLevel: 'MEDIUM',
    sourceLayer: AiConfigLayer.remoteConfig,
  );

  AiModelConfig get currentConfig => _remoteConfig;

  Future<void> fetchAndActivate() async {
    // 模擬從 Firebase Remote Config 拉取最新參數
  }

  void updateRemoteConfig(AiModelConfig config) {
    _remoteConfig = config.copyWith(sourceLayer: AiConfigLayer.remoteConfig);
  }
}
