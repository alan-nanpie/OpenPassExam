import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import '../data/datasources/local_persistent_cache.dart';
import '../data/datasources/rtdb_approved_keys_datasource.dart';
import '../data/models/ai_model_config.dart';
import '../data/models/question.dart';
import '../data/models/rag_knowledge_chunk.dart';
import 'remote_config_service.dart';
import 'offline_model_manager.dart';
import 'ai_offline_reasoning_engine.dart';
import 'ai_debug_log_service.dart';

enum AiPersona {
  friendlyTutor, // 該技術領域首席顧問與頂尖技術專家 (全方位詳細解析)
  cliEngineer, // 頂尖系統與網路工程師 (實戰配置與深入排錯)
  ccieArchitect, // 企業級首席系統與網路架構師 (高階設計、性能與權衡)
}

class AiService {
  final LocalPersistentCache localCache;
  final RtdbApprovedKeysDatasource rtdbDatasource;
  final RemoteConfigService remoteConfigService;
  final Connectivity connectivity;
  final OfflineModelManager? offlineModelManager;

  AiService({
    required this.localCache,
    required this.rtdbDatasource,
    required this.remoteConfigService,
    required this.connectivity,
    this.offlineModelManager,
  });

  /// 四層階層式 AI 調度解析
  AiModelConfig resolveEffectiveAiConfig() {
    // 1. 本機覆寫
    final localOverride = localCache.getLocalAiConfig();
    if (localOverride != null) {
      // 若本機覆寫中殘留舊版預設模型或過小 maxTokens，自動平滑升級
      var effective = localOverride;
      if (effective.primaryModel == 'gemini-2.5-flash' || effective.primaryModel.contains('gemini-2.0')) {
        effective = effective.copyWith(primaryModel: 'gemini-3.8-flash');
      }
      if (effective.fallbackModel == 'gemini-2.5-flash' || effective.fallbackModel.contains('gemini-2.0')) {
        effective = effective.copyWith(fallbackModel: 'gemini-3.6-flash');
      }
      if (effective.maxTokens < 16384) {
        effective = effective.copyWith(maxTokens: 16384, thinkingBudget: 4096);
      }
      if (effective != localOverride) {
        localCache.saveLocalAiConfig(effective);
      }
      return effective;
    }

    // 2. Firebase RTDB 廣播
    final rtdbBroadcast = rtdbDatasource.getBroadcastAiConfig();
    if (rtdbBroadcast != null) {
      return rtdbBroadcast;
    }

    // 3. Firebase Remote Config
    return remoteConfigService.currentConfig;
  }

  /// 檢查是否斷網（若斷網則強制離線端側模型）
  Future<bool> isOffline() async {
    try {
      final results = await connectivity.checkConnectivity();
      if (results.contains(ConnectivityResult.none)) {
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// 過濾 Gemini 3.8 / 3.7 Flash Dynamic Thinking 的思考標記
  String filterThinkingOutput(String rawText) {
    // 移除 <thought>...</thought> 標籤及其中內容
    final thoughtRegex = RegExp(r'<thought>[\s\S]*?<\/thought>', multiLine: true);
    var filtered = rawText.replaceAll(thoughtRegex, '').trim();

    // 移除開頭或結尾殘留的 thought 標記
    if (filtered.startsWith('thought:')) {
      final idx = filtered.indexOf('\n\n');
      if (idx >= 0) {
        filtered = filtered.substring(idx + 2).trim();
      }
    }
    return filtered;
  }

  /// 核心推理接口：實施【三層階層調度策略】
  /// 1. 第一優先：端側離線 AI 模型 (Gemma 4 2B / Chrome Built-in Nano)
  /// 2. 第二優先：雲端 Google 最新多模態模型 (Gemini 3.8 Flash)
  /// 3. 第三優先：主流最穩定備用多模態模型 (Gemini 2.5 Flash / Gemini 1.5 Pro)
  Future<String> askAiTutor({
    required String prompt,
    Question? questionContext,
    List<RagKnowledgeChunk>? ragChunks,
    AiPersona persona = AiPersona.friendlyTutor,
    String? apiKey,
    bool forceCloud = false,
  }) async {
    final result = await askAiTutorDetailed(
      prompt: prompt,
      questionContext: questionContext,
      ragChunks: ragChunks,
      persona: persona,
      apiKey: apiKey,
      forceCloud: forceCloud,
    );
    return result.text;
  }

  /// 精準推論接口：回傳回答文本與實際調度成功之模型名稱
  Future<({String text, String modelUsed, String? failureReason})> askAiTutorDetailed({
    required String prompt,
    Question? questionContext,
    List<RagKnowledgeChunk>? ragChunks,
    AiPersona persona = AiPersona.friendlyTutor,
    String? apiKey,
    bool forceCloud = false,
  }) async {
    final offline = await isOffline();
    final config = resolveEffectiveAiConfig();
    final offlineReady = offlineModelManager?.isModelReady ?? true;
    final isPreferOffline = offlineModelManager?.preferOffline ?? config.preferOffline;
    final hasApiKey = apiKey != null && apiKey.trim().isNotEmpty;

    // === 使用者明確要求雲端模式但沒有填入 API Key ===
    if (forceCloud && !hasApiKey) {
      final text = '⚠️ **[雲端模式需要 Gemini API Key]**\n\n'
          '您目前選擇了雲端 Gemini 旗艦推論模式，但尚未設定 API Key。\n\n'
          '**如何啟用雲端模式（3 步驟、100% 免費）**：\n'
          '1. 點擊右上角 🔑 **金鑰圖示**，或點擊上方黃色提示列\n'
          '2. 開啟 [Google AI Studio](https://aistudio.google.com/app/apikey)，以 Google 帳號登入\n'
          '3. 點擊「Create API Key」→ 複製 `AIzaSy...` 開頭的金鑰 → 貼回本 App\n\n'
          '> 📌 金鑰只存放在您的瀏覽器本機快取中，絕不上傳至任何伺服器！\n\n'
          '---\n'
          '🛡️ **以下由本機端側智能引擎為您即時回答：**\n\n'
          '${_generateOnDeviceGemmaResponse(prompt: prompt, question: questionContext, persona: persona, ragChunks: ragChunks)}';
      return (text: text, modelUsed: 'Gemma 4 (2B) 離線', failureReason: '未配置 Google Gemini API Key (BYOK)');
    }

    // === 【第 1 優先】：端側離線 AI 模型 (Gemma 4 2B / Chrome Nano) ===
    if (offline || (!forceCloud && !hasApiKey) || (!forceCloud && isPreferOffline && offlineReady)) {
      if (offlineModelManager != null && offlineModelManager!.isModelReady) {
        final text = await offlineModelManager!.runLocalInference(
          prompt: prompt,
          questionTitle: questionContext?.title,
          personaStyle: persona.name,
        );
        return (text: text, modelUsed: 'Gemma 4 (2B) 離線', failureReason: null);
      }
      final text = _generateOnDeviceGemmaResponse(
        prompt: prompt,
        question: questionContext,
        persona: persona,
        ragChunks: ragChunks,
      );
      return (text: text, modelUsed: 'Gemma 4 (2B) 離線', failureReason: null);
    }

    // === 【第 2 優先】：雲端 Google 最新 AI 多模態模型 (支援金鑰池自動輪替 Failover) ===
    // 取得所有可用金鑰清單
    final keyPool = localCache.getUserGeminiApiKeys();
    final candidateKeys = <String>{
      if (apiKey != null && apiKey.trim().isNotEmpty) apiKey.trim(),
      ...keyPool,
    }.toList();

    AiDebugLogService.instance.info(
      'AiService',
      '進入雲端推論排程，金鑰池共 ${candidateKeys.length} 組金鑰',
      {
        'primaryModel': config.primaryModel,
        'fallbackModel': config.fallbackModel,
        'thinkingLevel': config.thinkingLevel,
        'keyCount': candidateKeys.length,
      },
    );

    var quotaExhaustedCount = 0;
    var invalidKeyCount = 0;
    String? lastFailureReason;

    for (var i = 0; i < candidateKeys.length; i++) {
      final currentKey = candidateKeys[i];
      final maskedKey = currentKey.length > 8
          ? '${currentKey.substring(0, 4)}...${currentKey.substring(currentKey.length - 4)}'
          : '***';

      AiDebugLogService.instance.info('AiService', '開始以金鑰 #${i + 1} ($maskedKey) 呼叫主推論模型 [${config.primaryModel}]');

      try {
        final cloudResponse = await _callGeminiMultimodalApi(
          modelName: config.primaryModel, // gemini-3.8-flash
          prompt: prompt,
          apiKey: currentKey,
          config: config,
          question: questionContext,
          ragChunks: ragChunks,
          persona: persona,
        );
        return (
          text: filterThinkingOutput(cloudResponse.text),
          modelUsed: cloudResponse.modelUsed,
          failureReason: null,
        );
      } catch (e) {
        final errStr = e.toString();
        if (errStr.contains('RESOURCE_EXHAUSTED') || errStr.contains('429')) {
          quotaExhaustedCount++;
        } else if (errStr.contains('API_KEY_INVALID') || errStr.contains('API key not valid')) {
          invalidKeyCount++;
        }
        lastFailureReason = errStr;

        AiDebugLogService.instance.warn(
          'AiService',
          '金鑰 #${i + 1} ($maskedKey) 呼叫失敗: $errStr',
          {
            'hasMoreKeys': i < candidateKeys.length - 1,
            'keyIndex': i + 1,
          },
        );

        // 若還有下一把備用金鑰，自動輪替並繼續重試
        if (i < candidateKeys.length - 1) {
          AiDebugLogService.instance.info('AiService', '自動切換至金鑰池下一把金鑰 #${i + 2}');
          continue;
        }
      }
    }

    // 雙雲端模型與所有金鑰池均連線失敗時，由本地智能推理引擎無縫接管
    final localAnswer = _generateSimulatedHighQualityResponse(
      prompt: prompt,
      question: questionContext,
      ragChunks: ragChunks,
      persona: persona,
      config: config,
    );

    String errorDiagnosis;
    final totalKeys = candidateKeys.length;
    if (totalKeys > 0 && quotaExhaustedCount >= totalKeys) {
      errorDiagnosis = '⚠️ **您所設定的 $totalKeys 組 Gemini API Key 今日免費額度皆已全數耗盡 (429 RESOURCE_EXHAUSTED)**。\n'
          '> 建議：請至 [Google AI Studio](https://aistudio.google.com/app/apikey) 免費建立新金鑰並加入金鑰池，或等待 Google 每日配額重設。';
    } else if (totalKeys > 0 && invalidKeyCount >= totalKeys) {
      errorDiagnosis = '您設定的 $totalKeys 組 Google Gemini API Key 皆無效或尚未啟用。請至 [Google AI Studio](https://aistudio.google.com/app/apikey) 免費重新建立正確的金鑰 (支援 AQ... 與 AIzaSy... 格式)。';
    } else if (lastFailureReason != null) {
      if (lastFailureReason.contains('API_KEY_INVALID') || lastFailureReason.contains('API key not valid')) {
        errorDiagnosis = '您設定的 Google Gemini API Key 無效或尚未啟用。請點擊右上角金鑰圖示 🔑，至 [Google AI Studio](https://aistudio.google.com/app/apikey) 免費建立正確金鑰。';
      } else if (lastFailureReason.contains('RESOURCE_EXHAUSTED') || lastFailureReason.contains('429')) {
        errorDiagnosis = 'Gemini API Key 免費配額已耗盡 (429 RESOURCE_EXHAUSTED)。請更換或新增金鑰。';
      } else if (lastFailureReason.contains('PERMISSION_DENIED')) {
        errorDiagnosis = '該 API Key 缺乏 Generative Language API 存取權限。';
      } else if (lastFailureReason.contains('XMLHttpRequest') || lastFailureReason.contains('ClientException')) {
        errorDiagnosis = '瀏覽器發送網路請求失敗（可能是網路連線不穩或受廣告攔截插件阻擋）。';
      } else if (lastFailureReason.contains('TimeoutException')) {
        errorDiagnosis = 'Google 雲端 API 伺服器連線逾時 (超過 15 秒)。';
      } else {
        errorDiagnosis = lastFailureReason;
      }
    } else {
      errorDiagnosis = 'Google 雲端 API 連線中斷';
    }

    final text = '⚠️ **[雲端 API 連線異常提示]**\n> 🔍 **診斷原因**：$errorDiagnosis\n> 🛡️ **已自動由本機端側智能引擎接管推論**\n\n$localAnswer';
    return (text: text, modelUsed: 'Gemma 4 (2B) 接管', failureReason: errorDiagnosis);
  }

  Future<({String text, String modelUsed})> _callGeminiMultimodalApi({
    required String modelName,
    required String prompt,
    required String apiKey,
    required AiModelConfig config,
    Question? question,
    List<RagKnowledgeChunk>? ragChunks,
    required AiPersona persona,
  }) async {
    final cleanApiKey = apiKey.trim().replaceAll('"', '').replaceAll("'", '');

    final candidateModels = <String>{
      modelName,
      'gemini-3.8-flash',
      'gemini-3.7-flash',
      'gemini-3.6-flash',
    }.toList();

    Exception? lastException;
    final maskedKey = cleanApiKey.length > 8
        ? '${cleanApiKey.substring(0, 4)}...${cleanApiKey.substring(cleanApiKey.length - 4)}'
        : '***';

    var timeoutCount = 0;

    for (var mIdx = 0; mIdx < candidateModels.length; mIdx++) {
      final targetModel = candidateModels[mIdx];
      final stopwatch = Stopwatch()..start();
      // 若該金鑰在此輪已發生過 1 次逾時，備用模型只給予 5 秒快速探測，避免長時間卡住
      final timeoutDuration = (timeoutCount > 0)
          ? const Duration(seconds: 5)
          : const Duration(seconds: 10);
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$targetModel:generateContent?key=$cleanApiKey',
        );

        final systemInstruction = _buildSystemInstruction(persona, ragChunks);
        final userContent = StringBuffer();
        if (question != null) {
          userContent.writeln('【考題資訊】: ${question.title}');
          userContent.writeln('【考題選項】: ${question.options.join(" | ")}');
          userContent.writeln('【官方詳解】: ${question.explanation}');
          if (question.imageUrl != null && question.imageUrl!.isNotEmpty) {
            userContent.writeln('【考題拓撲圖片連結】: ${question.imageUrl}');
          }
        }
        userContent.writeln('【學員提問】: $prompt');

        final isGemini3Family = targetModel.startsWith('gemini-3');
        final generationConfig = <String, dynamic>{
          'maxOutputTokens': config.maxTokens,
        };

        if (isGemini3Family) {
          // Gemini 3.x Flash 規範：
          // 1. 移除 temperature, top_p, top_k, frequency_penalty, presence_penalty, candidate_count
          // 2. thinkingConfig 採用 thinkingLevel 列舉 (LOW, MEDIUM, HIGH)，禁止 MINIMAL
          final level = config.thinkingLevel.toUpperCase();
          final validLevel = (level == 'LOW' || level == 'HIGH') ? level : 'MEDIUM';
          generationConfig['thinkingConfig'] = {
            'thinkingLevel': validLevel,
          };
        } else {
          // 針對舊版備用模型 (如 gemini-2.5-flash) 保持相容參數
          generationConfig['temperature'] = config.temperature;
          if (targetModel.contains('thinking') && config.thinkingBudget > 0) {
            generationConfig['thinkingConfig'] = {
              'thinkingBudget': config.thinkingBudget,
            };
          }
        }

        final bodyMap = {
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': userContent.toString()}]
            }
          ],
          'systemInstruction': {
            'parts': [{'text': systemInstruction}]
          },
          'generationConfig': generationConfig,
        };
        final body = jsonEncode(bodyMap);

        AiDebugLogService.instance.info(
          'GeminiApi',
          '發送請求至模型 [$targetModel] (金鑰: $maskedKey, 超時上限: ${timeoutDuration.inSeconds}s, maxTokens: ${config.maxTokens})',
          {
            'model': targetModel,
            'endpoint': 'https://generativelanguage.googleapis.com/v1beta/models/$targetModel:generateContent',
            'generationConfig': generationConfig,
            'promptLength': prompt.length,
            'timeoutSec': timeoutDuration.inSeconds,
            'hasQuestionContext': question != null,
          },
        );

        var response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        ).timeout(timeoutDuration);

        // 遇到 503 (High Demand 暫時性壅塞)，若為 gemini-3.8-flash 則進行一次 0.5 秒退避重試
        if (response.statusCode == 503 && targetModel == 'gemini-3.8-flash') {
          AiDebugLogService.instance.warn(
            'GeminiApi',
            '模型 [$targetModel] 遭遇 503 暫時尖峰壅塞，進行退避 500ms 快速重試...',
            {'statusCode': 503, 'retryAfterMs': 500},
          );
          await Future.delayed(const Duration(milliseconds: 500));
          response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: body,
          ).timeout(timeoutDuration);
        }

        stopwatch.stop();

        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          final candidates = json['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final firstCand = candidates[0] as Map<String, dynamic>;
            final finishReason = firstCand['finishReason'] as String? ?? 'NORMAL';
            final parts = firstCand['content']?['parts'] as List?;
            if (parts != null && parts.isNotEmpty) {
              final text = parts.map((p) => p['text'] ?? '').join('\n');
              AiDebugLogService.instance.success(
                'GeminiApi',
                '模型 [$targetModel] 成功回傳 (耗時: ${stopwatch.elapsedMilliseconds}ms, finishReason: $finishReason)',
                {
                  'model': targetModel,
                  'statusCode': 200,
                  'finishReason': finishReason,
                  'responseLength': text.length,
                  'durationMs': stopwatch.elapsedMilliseconds,
                },
              );
              return (text: text, modelUsed: targetModel);
            }
          }
        }

        final errDetail = 'HTTP ${response.statusCode}: ${response.body}';

        // 若為 401/403 (金鑰未授權)、400 (金鑰無效) 或 429 (整把金鑰額度耗盡 RESOURCE_EXHAUSTED)
        // 代表該金鑰無法服務，立即中斷該金鑰拋出給外層換下一把金鑰
        final isFatalKeyError = response.statusCode == 401 ||
            response.statusCode == 403 ||
            response.statusCode == 429 ||
            (response.statusCode == 400 && response.body.contains('API_KEY_INVALID')) ||
            response.body.contains('RESOURCE_EXHAUSTED');

        AiDebugLogService.instance.warn(
          'GeminiApi',
          '模型 [$targetModel] 呼叫未成功 (狀態碼: ${response.statusCode}, 耗時: ${stopwatch.elapsedMilliseconds}ms)',
          {
            'model': targetModel,
            'statusCode': response.statusCode,
            'responseBody': response.body,
            'action': isFatalKeyError
                ? (response.statusCode == 429 ? '金鑰配額已耗盡 (429)，立即跳至下一把金鑰' : '金鑰無效，立即跳至下一把金鑰')
                : (mIdx < candidateModels.length - 1 ? '切換下一候選模型: ${candidateModels[mIdx + 1]}' : '無下一模型'),
          },
        );

        lastException = Exception('Gemini API Error ($targetModel): $errDetail');
        if (isFatalKeyError) {
          throw lastException;
        }
      } catch (e) {
        stopwatch.stop();
        final errStr = e.toString();
        if (errStr.contains('TimeoutException')) {
          timeoutCount++;
        }

        // 遇到 401/403/429 立即斷定該金鑰網路阻滯，中斷當前金鑰直接換下一把！
        final isFatalAuthOrQuota = errStr.contains('401') ||
            errStr.contains('403') ||
            errStr.contains('429') ||
            errStr.contains('RESOURCE_EXHAUSTED') ||
            errStr.contains('API_KEY_INVALID') ||
            errStr.contains('ACCESS_TOKEN_TYPE_UNSUPPORTED');

        // 若此金鑰累計逾時達 2 次（例如 3.8 等 10s + 3.7 等 5s），代表此金鑰連線嚴重受阻，啟動熔斷換下一把！
        final shouldBreakKey = isFatalAuthOrQuota || (timeoutCount >= 2);

        AiDebugLogService.instance.error(
          'GeminiApi',
          '模型 [$targetModel] 發送異常: $e',
          {
            'model': targetModel,
            'exception': errStr,
            'durationMs': stopwatch.elapsedMilliseconds,
            'timeoutCount': timeoutCount,
            'action': shouldBreakKey
                ? (isFatalAuthOrQuota ? '觸發極速換金鑰 (Auth/Quota 異常)' : '金鑰累計逾時達 2 次，觸發連線熔斷，換下一把金鑰')
                : (mIdx < candidateModels.length - 1 ? '切換下一候選模型: ${candidateModels[mIdx + 1]}' : '無下一模型'),
          },
        );
        lastException = Exception('Gemini API Exception ($targetModel): $e');
        if (shouldBreakKey) {
          throw lastException;
        }
      }
    }

    throw lastException ?? Exception('Gemini API 連線失敗');
  }

  String _buildSystemInstruction(AiPersona persona, List<RagKnowledgeChunk>? ragChunks) {
    final sb = StringBuffer();
    sb.writeln('你是一位在該問題所屬技術領域擁有 20 年以上經驗的頂尖技術專家與首席顧問（包括但不限於網路架構、雲端系統、分散式計算、資料庫、資安、軟體工程與全方位專業認證領域）。');
    sb.writeln('請一律使用台灣繁體中文（採用台灣繁體標準專業技術術語，如：封包、路由器、交換器、拓撲、虛擬機器、容器、子網路、中繼埠、路由表等）回答。');
    sb.writeln('\n【核心回答指導原則】：');
    sb.writeln('1. **頂尖專家與資深顧問角色**：你將以該技術領域最頂尖的專家或首席顧問身分，針對使用者提出的問題提供最權威、最深入且具備實務洞察力的解答。');
    sb.writeln('2. **內容極致詳盡**：請勿簡略或流於表面，必須深入探討底層運作機制、通訊協定細節、資料結構與狀態機轉移、RFC 標準規格、架構設計權衡（Trade-offs）以及生產環境下的實務經驗。');
    sb.writeln('3. **結構清晰完整**：採用專業結構化 Markdown 排版（包含架構原理、詳細步驟、完整配置指令、狀態驗證與排錯心法）。');
    sb.writeln('4. **直接切入核心**：避免空泛贅詞，直指問題技術核心。');

    switch (persona) {
      case AiPersona.friendlyTutor:
        sb.writeln('\n【顧問風格】：技術領域首席顧問。提供全方位、高度詳盡的技術白皮書級別深度剖析，從底層協定規範到企業級最佳實務一應俱全。');
        break;
      case AiPersona.cliEngineer:
        sb.writeln('\n【顧問風格】：頂尖系統與網路資深工程師。提供精準且完整的實戰 CLI / 程式配置、端到端佈署流程、完整驗證（Show / Debug / Log）指令及排錯方法論。');
        break;
      case AiPersona.ccieArchitect:
        sb.writeln('\n【顧問風格】：企業級首席系統與網路架構師。從全局架構設計、高可用性（HA）、負載平衡、容災（DR）、資安合規、效能瓶頸突破與維運成本權衡出發提供戰略級諮詢。');
        break;
    }

    if (ragChunks != null && ragChunks.isNotEmpty) {
      sb.writeln('\n【參考官方教材與規範 RAG 切片知識庫】：');
      for (final chunk in ragChunks) {
        sb.writeln('- [${chunk.bookTitle} p.${chunk.pageNumber}] ${chunk.content}');
      }
    }

    return sb.toString();
  }

  String _generateOnDeviceGemmaResponse({
    required String prompt,
    Question? question,
    required AiPersona persona,
    List<RagKnowledgeChunk>? ragChunks,
  }) {
    return AiOfflineReasoningEngine.generateResponse(
      prompt: prompt,
      question: question,
      persona: persona,
      platformDescription: offlineModelManager?.platformSupportDescription,
      ragChunks: ragChunks,
      isSimulatedCloud: false,
    );
  }

  /// 驗證使用者輸入的 Gemini API Key 是否有效
  Future<String?> testGeminiApiKey(String apiKey) async {
    final cleanKey = apiKey.trim().replaceAll('"', '').replaceAll("'", '');
    if (cleanKey.isEmpty) return 'API Key 不能為空';
    
    final probeModels = ['gemini-3.8-flash', 'gemini-3.7-flash', 'gemini-3.6-flash'];
    final maskedKey = cleanKey.length > 8
        ? '${cleanKey.substring(0, 4)}...${cleanKey.substring(cleanKey.length - 4)}'
        : '***';

    String? lastError;

    for (final model in probeModels) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$cleanKey',
        );
        final body = jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': 'ping'}]
            }
          ],
        });
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: body,
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          AiDebugLogService.instance.success(
            'ApiKeyTest',
            '金鑰 ($maskedKey) 測試通過 (驗證模型: $model)',
            {'model': model, 'statusCode': 200},
          );
          return null; // 成功無錯誤
        }

        try {
          final json = jsonDecode(response.body);
          final msg = json['error']?['message'] ?? 'HTTP ${response.statusCode}';
          lastError = msg.toString();
        } catch (_) {
          lastError = 'HTTP ${response.statusCode}：${response.body}';
        }

        AiDebugLogService.instance.warn(
          'ApiKeyTest',
          '金鑰 ($maskedKey) 探測模型 [$model] 回應非 200: $lastError',
          {'model': model, 'statusCode': response.statusCode},
        );

        // 如果是 404 (模型名稱不支援)，繼續探測下一個模型
        if (response.statusCode == 404) {
          continue;
        }

        // 若是 400 API key invalid 或 429 quota exhausted，則直接回報
        return lastError;
      } catch (e) {
        lastError = e.toString();
        AiDebugLogService.instance.error(
          'ApiKeyTest',
          '金鑰 ($maskedKey) 探測模型 [$model] 發生異常: $e',
          {'model': model, 'exception': e.toString()},
        );
      }
    }

    return lastError;
  }

  String _generateSimulatedHighQualityResponse({
    required String prompt,
    Question? question,
    List<RagKnowledgeChunk>? ragChunks,
    required AiPersona persona,
    required AiModelConfig config,
  }) {
    return AiOfflineReasoningEngine.generateResponse(
      prompt: prompt,
      question: question,
      persona: persona,
      platformDescription: offlineModelManager?.platformSupportDescription,
      ragChunks: ragChunks,
      isSimulatedCloud: true,
    );
  }
}
