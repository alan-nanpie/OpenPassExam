import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../data/datasources/local_persistent_cache.dart';
import '../data/models/rag_knowledge_chunk.dart';
import '../data/models/study_artifact.dart';
import '../data/repositories/rag_repository.dart';
import '../services/ai_service.dart';

class NotebookLMController extends ChangeNotifier {
  final IRagRepository ragRepository;
  final LocalPersistentCache localCache;
  final AiService aiService;

  List<RagKnowledgeChunk> _loadedChunks = [];
  List<StudyArtifact> _artifacts = [];
  bool _isLoadingGcsRag = false;
  bool _isGeneratingArtifact = false;
  StudioToolType _selectedToolType = StudioToolType.studyGuide;
  String _customFocusPrompt = '';

  NotebookLMController({
    required this.ragRepository,
    required this.localCache,
    required this.aiService,
  }) {
    _artifacts = localCache.getStudyArtifacts();
  }

  List<RagKnowledgeChunk> get loadedChunks => _loadedChunks;
  List<StudyArtifact> get artifacts => _artifacts;
  bool get isLoadingGcsRag => _isLoadingGcsRag;
  bool get isGeneratingArtifact => _isGeneratingArtifact;
  StudioToolType get selectedToolType => _selectedToolType;
  String get customFocusPrompt => _customFocusPrompt;

  void selectToolType(StudioToolType type) {
    _selectedToolType = type;
    notifyListeners();
  }

  void setCustomFocusPrompt(String prompt) {
    _customFocusPrompt = prompt;
    notifyListeners();
  }

  Future<void> loadGcsRagKnowledgePacks() async {
    _isLoadingGcsRag = true;
    notifyListeners();

    _loadedChunks = await ragRepository.loadOfficialRagChunks();

    _isLoadingGcsRag = false;
    notifyListeners();
  }

  Future<StudyArtifact> generateArtifactForExam({
    required String examId,
    required String examTitle,
  }) async {
    _isGeneratingArtifact = true;
    notifyListeners();

    if (_loadedChunks.isEmpty) {
      _loadedChunks = await ragRepository.loadOfficialRagChunks();
    }

    final prompt = StringBuffer();
    prompt.writeln('針對 $examTitle ($examId) 認證考科教材，請產出【${_selectedToolType.title}】：');
    if (_customFocusPrompt.trim().isNotEmpty) {
      prompt.writeln('學員自訂聚焦要求：$_customFocusPrompt');
    }
    prompt.writeln('請使用標準 Markdown 排版，包含表格 (Markdown Tables)、重點標籤與清晰階層。');

    final userApiKey = localCache.getUserGeminiApiKey();
    final content = await aiService.askAiTutor(
      prompt: prompt.toString(),
      ragChunks: _loadedChunks.take(3).toList(),
      persona: AiPersona.friendlyTutor,
      apiKey: userApiKey,
    );

    final artifact = StudyArtifact(
      id: 'artifact_${const Uuid().v4().substring(0, 8)}',
      title: '${_selectedToolType.title} - $examId',
      toolType: _selectedToolType,
      contentMarkdown: content,
      customFocusPrompt: _customFocusPrompt,
      createdAt: DateTime.now(),
      examId: examId,
    );

    _artifacts.insert(0, artifact);
    await localCache.saveStudyArtifacts(_artifacts);

    _isGeneratingArtifact = false;
    notifyListeners();
    return artifact;
  }
}
