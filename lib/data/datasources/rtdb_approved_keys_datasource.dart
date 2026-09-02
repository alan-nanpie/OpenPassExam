import '../models/ai_model_config.dart';

class RtdbApprovedKeysDatasource {
  // 模擬 Firebase RTDB approvedKeys 記憶體/遠端索引快取
  final Map<String, Map<String, bool>> _approvedKeysIndex = {};
  AiModelConfig? _broadcastConfig;

  RtdbApprovedKeysDatasource() {
    // 預設填充 CCNA 考題 approvedKeys
    _approvedKeysIndex['cisco-200-301'] = {
      'ccna_q001': true,
      'ccna_q002': true,
      'ccna_q003': true,
      'ccna_q004': true,
      'ccna_q005': true,
    };
    _approvedKeysIndex['cisco-350-401'] = {
      'encor_q001': true,
      'encor_q002': true,
    };
    _approvedKeysIndex['cisco-300-410'] = {
      'enarsi_q001': true,
    };
    _approvedKeysIndex['cisco-300-435'] = {
      'enauto_q001': true,
    };
    _approvedKeysIndex['cisco-350-701'] = {
      'scor_q001': true,
    };
  }

  bool isQuestionApproved(String examId, String questionId) {
    return _approvedKeysIndex[examId]?[questionId] ?? true;
  }

  void setQuestionApproval(String examId, String questionId, bool isApproved) {
    if (!_approvedKeysIndex.containsKey(examId)) {
      _approvedKeysIndex[examId] = {};
    }
    _approvedKeysIndex[examId]![questionId] = isApproved;
  }

  void approveAllForSubject(String examId, List<String> questionIds) {
    if (!_approvedKeysIndex.containsKey(examId)) {
      _approvedKeysIndex[examId] = {};
    }
    for (final qId in questionIds) {
      _approvedKeysIndex[examId]![qId] = true;
    }
  }

  // AI 廣播節點
  AiModelConfig? getBroadcastAiConfig() => _broadcastConfig;

  void publishBroadcastAiConfig(AiModelConfig config) {
    _broadcastConfig = config.copyWith(sourceLayer: AiConfigLayer.rtdbBroadcast);
  }
}
