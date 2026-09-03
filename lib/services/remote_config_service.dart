import '../data/models/ai_model_config.dart';

class RemoteConfigService {
  AiModelConfig _remoteConfig = AiModelConfig(
    primaryModel: 'gemini-2.5-flash',
    fallbackModel: 'gemini-2.5-flash',
    temperature: 1.0,
    maxTokens: 4096,
    thinkingBudget: 2048,
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
