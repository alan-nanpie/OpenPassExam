import 'package:flutter/foundation.dart';
import '../data/datasources/local_persistent_cache.dart';
import '../data/datasources/rtdb_approved_keys_datasource.dart';
import '../data/models/ai_model_config.dart';
import '../data/models/question.dart';
import '../data/repositories/repository_factory.dart';
import '../services/ai_service.dart';
import '../services/remote_config_service.dart';

class AdminController extends ChangeNotifier {
  final RepositoryFactory repositoryFactory;
  final LocalPersistentCache localCache;
  final RtdbApprovedKeysDatasource rtdbDatasource;
  final RemoteConfigService remoteConfigService;
  final AiService aiService;

  List<Question> _pendingQuestions = [];
  bool _isLoading = false;
  String? _statusMessage;

  // AI 管理配置狀態
  late AiModelConfig currentEditableAiConfig;

  AdminController({
    required this.repositoryFactory,
    required this.localCache,
    required this.rtdbDatasource,
    required this.remoteConfigService,
    required this.aiService,
  }) {
    currentEditableAiConfig = aiService.resolveEffectiveAiConfig();
  }

  List<Question> get pendingQuestions => _pendingQuestions;
  bool get isLoading => _isLoading;
  String? get statusMessage => _statusMessage;

  Future<void> loadPendingQuestions(String subjectId) async {
    _isLoading = true;
    _statusMessage = null;
    notifyListeners();

    final repo = repositoryFactory.getQuestionRepository(subjectId);
    final all = await repo.getQuestions();
    _pendingQuestions = all.where((q) => !q.isApproved).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveAll(String subjectId) async {
    _isLoading = true;
    notifyListeners();

    final repo = repositoryFactory.getQuestionRepository(subjectId);
    await repo.approveAllQuestions();

    _pendingQuestions.clear();
    _statusMessage = '✅ 已成功核准 $subjectId 的所有考題並同步至 Firebase RTDB approvedKeys！';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveQuestion({
    required String subjectId,
    required Question question,
  }) async {
    _isLoading = true;
    notifyListeners();

    final repo = repositoryFactory.getQuestionRepository(subjectId);
    await repo.saveQuestion(question);

    await loadPendingQuestions(subjectId);
    _statusMessage = '✅ 考題已成功儲存！';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteQuestion({
    required String subjectId,
    required String questionId,
  }) async {
    _isLoading = true;
    notifyListeners();

    final repo = repositoryFactory.getQuestionRepository(subjectId);
    await repo.deleteQuestion(questionId);

    await loadPendingQuestions(subjectId);
    _statusMessage = '🗑️ 考題已成功刪除！';
    _isLoading = false;
    notifyListeners();
  }

  // AI 模型調度管理
  void updateEditableAiConfig(AiModelConfig newConfig) {
    currentEditableAiConfig = newConfig;
    notifyListeners();
  }

  Future<void> saveAsLocalOverride() async {
    final configWithLayer = currentEditableAiConfig.copyWith(
      sourceLayer: AiConfigLayer.localOverride,
    );
    await localCache.saveLocalAiConfig(configWithLayer);
    _statusMessage = '💾 已儲存為本機覆寫 (Local Override)！';
    notifyListeners();
  }

  Future<void> clearLocalOverride() async {
    await localCache.clearLocalAiConfig();
    currentEditableAiConfig = aiService.resolveEffectiveAiConfig();
    _statusMessage = '🧹 已清除本機覆寫，回退至上一層級！';
    notifyListeners();
  }

  Future<void> publishToRemoteConfigAndRtdb() async {
    // 廣播至 RTDB
    rtdbDatasource.publishBroadcastAiConfig(currentEditableAiConfig);
    // 發布至 Remote Config
    remoteConfigService.updateRemoteConfig(currentEditableAiConfig);

    _statusMessage = '🚀 已成功廣播發布至 Firebase Remote Config 與 RTDB！';
    notifyListeners();
  }
}
