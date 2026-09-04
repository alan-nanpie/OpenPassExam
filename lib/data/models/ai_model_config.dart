enum AiConfigLayer {
  localOverride,
  rtdbBroadcast,
  remoteConfig,
  builtInDefault,
}

class AiModelConfig {
  final String primaryModel;
  final String fallbackModel;
  final String onDeviceModel;
  final double temperature;
  final int maxTokens;
  final int thinkingBudget; // 舊版備用模型相容用
  final String thinkingLevel; // 'LOW', 'MEDIUM', 'HIGH' (Gemini 3.8 Flash 規範，禁止 MINIMAL)
  final bool preferOffline;
  final AiConfigLayer sourceLayer;

  AiModelConfig({
    this.primaryModel = 'gemini-3.8-flash',
    this.fallbackModel = 'gemini-2.5-flash',
    this.onDeviceModel = 'gemma-4-2b',
    this.temperature = 1.0,
    this.maxTokens = 4096,
    this.thinkingBudget = 2048,
    this.thinkingLevel = 'MEDIUM',
    this.preferOffline = true,
    this.sourceLayer = AiConfigLayer.builtInDefault,
  });

  Map<String, dynamic> toMap() {
    return {
      'primary_model': primaryModel,
      'fallback_model': fallbackModel,
      'on_device_model': onDeviceModel,
      'temperature': temperature,
      'max_tokens': maxTokens,
      'thinking_budget': thinkingBudget,
      'thinking_level': thinkingLevel,
      'prefer_offline': preferOffline,
      'source_layer': sourceLayer.name,
    };
  }

  factory AiModelConfig.fromMap(Map<String, dynamic> map, {AiConfigLayer layer = AiConfigLayer.builtInDefault}) {
    final rawLevel = (map['thinking_level'] ?? map['thinkingLevel'])?.toString().toUpperCase();
    final validLevel = (rawLevel == 'LOW' || rawLevel == 'MEDIUM' || rawLevel == 'HIGH')
        ? rawLevel!
        : 'MEDIUM';

    return AiModelConfig(
      primaryModel: (map['primary_model'] ?? map['primaryModel'] ?? 'gemini-3.8-flash').toString(),
      fallbackModel: (map['fallback_model'] ?? map['fallbackModel'] ?? 'gemini-2.5-flash').toString(),
      onDeviceModel: (map['on_device_model'] ?? map['onDeviceModel'] ?? 'gemma-4-2b').toString(),
      temperature: (map['temperature'] as num?)?.toDouble() ?? 1.0,
      maxTokens: (map['max_tokens'] ?? map['maxTokens'] as num?)?.toInt() ?? 4096,
      thinkingBudget: (map['thinking_budget'] ?? map['thinkingBudget'] as num?)?.toInt() ?? 2048,
      thinkingLevel: validLevel,
      preferOffline: (map['prefer_offline'] ?? map['preferOffline']) as bool? ?? true,
      sourceLayer: layer,
    );
  }

  AiModelConfig copyWith({
    String? primaryModel,
    String? fallbackModel,
    String? onDeviceModel,
    double? temperature,
    int? maxTokens,
    int? thinkingBudget,
    String? thinkingLevel,
    bool? preferOffline,
    AiConfigLayer? sourceLayer,
  }) {
    return AiModelConfig(
      primaryModel: primaryModel ?? this.primaryModel,
      fallbackModel: fallbackModel ?? this.fallbackModel,
      onDeviceModel: onDeviceModel ?? this.onDeviceModel,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      thinkingBudget: thinkingBudget ?? this.thinkingBudget,
      thinkingLevel: thinkingLevel ?? this.thinkingLevel,
      preferOffline: preferOffline ?? this.preferOffline,
      sourceLayer: sourceLayer ?? this.sourceLayer,
    );
  }
}
