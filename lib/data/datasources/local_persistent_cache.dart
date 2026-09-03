import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../models/question.dart';
import '../models/wrong_question.dart';
import '../models/note_item.dart';
import '../models/exam_session.dart';
import '../models/study_artifact.dart';
import '../models/ai_model_config.dart';
import '../models/question_comment.dart';
import '../models/exam_subject.dart';
import '../../services/secure_vault_service.dart';

class LocalPersistentCache {
  final SharedPreferences _prefs;
  final ISecureVaultService? _secureVault;

  LocalPersistentCache(this._prefs, [this._secureVault]);

  // 1. 考題快取
  Future<void> saveQuestions(String examId, List<Question> questions) async {
    final key = 'questions_cache_$examId';
    final jsonList = questions.map((q) => q.toMap()).toList();
    await _prefs.setString(key, jsonEncode(jsonList));
  }

  List<Question>? getCachedQuestions(String examId) {
    final key = 'questions_cache_$examId';
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Question.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return null;
    }
  }

  // 2. 錯題本快取
  Future<void> saveWrongQuestions(List<WrongQuestion> wrongQuestions) async {
    final jsonList = wrongQuestions.map((w) => w.toMap()).toList();
    await _prefs.setString('wrong_questions_cache', jsonEncode(jsonList));
  }

  List<WrongQuestion> getWrongQuestions() {
    final raw = _prefs.getString('wrong_questions_cache');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => WrongQuestion.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  // 3. 筆記快取
  Future<void> saveNotes(List<NoteItem> notes) async {
    final jsonList = notes.map((n) => n.toMap()).toList();
    await _prefs.setString('notes_cache', jsonEncode(jsonList));
  }

  List<NoteItem> getNotes() {
    final raw = _prefs.getString('notes_cache');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => NoteItem.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  // 4. 模擬考成績紀錄快取
  Future<void> saveExamSessions(List<ExamSession> sessions) async {
    final jsonList = sessions.map((s) => s.toMap()).toList();
    await _prefs.setString('exam_sessions_cache', jsonEncode(jsonList));
  }

  List<ExamSession> getExamSessions() {
    final raw = _prefs.getString('exam_sessions_cache');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => ExamSession.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  // 5. NotebookLM Artifacts 快取
  Future<void> saveStudyArtifacts(List<StudyArtifact> artifacts) async {
    final jsonList = artifacts.map((a) => a.toMap()).toList();
    await _prefs.setString('study_artifacts_cache', jsonEncode(jsonList));
  }

  List<StudyArtifact> getStudyArtifacts() {
    final raw = _prefs.getString('study_artifacts_cache');
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => StudyArtifact.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }

  // 6. 離線寫入佇列 (Mutation Queue)
  Future<void> enqueueMutation(Map<String, dynamic> mutation) async {
    final queue = getMutationQueue();
    queue.add(mutation);
    await _prefs.setString(AppConstants.prefKeyOfflineQueue, jsonEncode(queue));
  }

  List<Map<String, dynamic>> getMutationQueue() {
    final raw = _prefs.getString(AppConstants.prefKeyOfflineQueue);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clearMutationQueue() async {
    await _prefs.remove(AppConstants.prefKeyOfflineQueue);
  }

  // 7. AI 本機覆寫設定
  Future<void> saveLocalAiConfig(AiModelConfig config) async {
    await _prefs.setString(AppConstants.prefKeyAiConfigOverride, jsonEncode(config.toMap()));
  }

  AiModelConfig? getLocalAiConfig() {
    final raw = _prefs.getString(AppConstants.prefKeyAiConfigOverride);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return AiModelConfig.fromMap(
        Map<String, dynamic>.from(decoded),
        layer: AiConfigLayer.localOverride,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearLocalAiConfig() async {
    await _prefs.remove(AppConstants.prefKeyAiConfigOverride);
  }

  // 8. 使用者自備 Gemini API 金鑰 (BYOK) - 雙層硬體安全保護
  Future<void> saveUserGeminiApiKey(String apiKey) async {
    final trimmed = apiKey.trim();
    if (_secureVault != null) {
      await _secureVault.writeSecret(AppConstants.prefKeyUserGeminiApiKey, trimmed);
    }
    await _prefs.setString(AppConstants.prefKeyUserGeminiApiKey, trimmed);
  }

  String? getUserGeminiApiKey() {
    final key = _prefs.getString(AppConstants.prefKeyUserGeminiApiKey);
    if (key == null || key.trim().isEmpty) return null;
    return key.trim();
  }

  Future<String?> getSecureUserGeminiApiKey() async {
    if (_secureVault != null) {
      final secret = await _secureVault.readSecret(AppConstants.prefKeyUserGeminiApiKey);
      if (secret != null && secret.isNotEmpty) return secret;
    }
    return getUserGeminiApiKey();
  }

  Future<void> clearUserGeminiApiKey() async {
    if (_secureVault != null) {
      await _secureVault.deleteSecret(AppConstants.prefKeyUserGeminiApiKey);
    }
    await _prefs.remove(AppConstants.prefKeyUserGeminiApiKey);
  }

  // 9. 考題討論區留言快取
  Future<void> saveComments(String questionId, List<QuestionComment> comments) async {
    final key = 'comments_cache_$questionId';
    final jsonList = comments.map((c) => c.toMap()).toList();
    await _prefs.setString(key, jsonEncode(jsonList));
  }

  List<QuestionComment>? getCachedComments(String questionId) {
    final key = 'comments_cache_$questionId';
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => QuestionComment.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return null;
    }
  }

  // 10. 學員社群自建考試科目快取 (UGC Custom Exam Subjects)
  Future<void> saveCustomSubjects(List<ExamSubject> subjects) async {
    const key = 'custom_exam_subjects_cache';
    final jsonList = subjects.map((s) => s.toMap()).toList();
    await _prefs.setString(key, jsonEncode(jsonList));
  }

  List<ExamSubject> getCachedCustomSubjects() {
    const key = 'custom_exam_subjects_cache';
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((e) => ExamSubject.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }
}
