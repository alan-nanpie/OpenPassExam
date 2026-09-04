import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:passexam/data/datasources/local_persistent_cache.dart';
import 'package:passexam/data/datasources/rtdb_approved_keys_datasource.dart';
import 'package:passexam/data/models/ai_model_config.dart';
import 'package:passexam/services/ai_service.dart';
import 'package:passexam/services/remote_config_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AI Service Hierarchy & Thinking Filter Tests', () {
    late LocalPersistentCache localCache;
    late RtdbApprovedKeysDatasource rtdbDatasource;
    late RemoteConfigService remoteConfigService;
    late AiService aiService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      localCache = LocalPersistentCache(prefs);
      rtdbDatasource = RtdbApprovedKeysDatasource();
      remoteConfigService = RemoteConfigService();
      aiService = AiService(
        localCache: localCache,
        rtdbDatasource: rtdbDatasource,
        remoteConfigService: remoteConfigService,
        connectivity: Connectivity(),
      );
    });

    test('預設應解析出 Remote Config / 預設配置層級', () {
      final config = aiService.resolveEffectiveAiConfig();
      expect(config.primaryModel, 'gemini-3.8-flash');
      expect(config.thinkingLevel, 'MEDIUM');
      expect(config.sourceLayer, AiConfigLayer.remoteConfig);
    });

    test('RTDB 廣播應優先於 Remote Config (第 2 層 > 第 3 層)', () {
      rtdbDatasource.publishBroadcastAiConfig(
        AiModelConfig(primaryModel: 'gemini-3.7-pro-custom'),
      );
      final config = aiService.resolveEffectiveAiConfig();
      expect(config.primaryModel, 'gemini-3.7-pro-custom');
      expect(config.sourceLayer, AiConfigLayer.rtdbBroadcast);
    });

    test('本機覆寫應擁有最高優先權 (第 1 層 > 第 2 層)', () async {
      rtdbDatasource.publishBroadcastAiConfig(
        AiModelConfig(primaryModel: 'gemini-3.7-pro-custom'),
      );
      await localCache.saveLocalAiConfig(
        AiModelConfig(primaryModel: 'gemini-ultra-local', sourceLayer: AiConfigLayer.localOverride),
      );

      final config = aiService.resolveEffectiveAiConfig();
      expect(config.primaryModel, 'gemini-ultra-local');
      expect(config.sourceLayer, AiConfigLayer.localOverride);
    });

    test('應該正確過濾 Gemini 3.7 / 3.8 Flash 的 <thought>...</thought> 思考內容', () {
      const rawOutput = '''
<thought>
這是模型內部的自我驗證推理流程，正在計算 OSPF 的 AD 值是否為 110...
答案確認為 110。
</thought>
OSPF 協定的預設管理距離為 110，採用 Dijkstra 最短路徑演算法。
''';

      final cleanOutput = aiService.filterThinkingOutput(rawOutput);
      expect(cleanOutput.contains('<thought>'), false);
      expect(cleanOutput.contains('這是模型內部的自我驗證'), false);
      expect(cleanOutput.contains('OSPF 協定的預設管理距離為 110'), true);
    });

    test('Gemini 3.8 Flash 配置應嚴格防護 MINIMAL 並正確序列化 thinking_level', () {
      // 預設值驗證
      final defaultConfig = AiModelConfig();
      expect(defaultConfig.primaryModel, 'gemini-3.8-flash');
      expect(defaultConfig.thinkingLevel, 'MEDIUM');

      // 序列化成 Map
      final map = defaultConfig.toMap();
      expect(map['thinking_level'], 'MEDIUM');
      expect(map['primary_model'], 'gemini-3.8-flash');

      // 反序列化合法列舉
      final highConfig = AiModelConfig.fromMap({'thinking_level': 'HIGH'});
      expect(highConfig.thinkingLevel, 'HIGH');

      final lowConfig = AiModelConfig.fromMap({'thinking_level': 'low'});
      expect(lowConfig.thinkingLevel, 'LOW');

      // 嚴格阻擋 MINIMAL（官方禁止，回退為 MEDIUM）
      final minimalAttempt = AiModelConfig.fromMap({'thinking_level': 'MINIMAL'});
      expect(minimalAttempt.thinkingLevel, 'MEDIUM');
    });
  });
}
