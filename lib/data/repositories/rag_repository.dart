import '../datasources/mock_seed_data.dart';
import '../models/rag_knowledge_chunk.dart';

abstract class IRagRepository {
  Future<List<RagKnowledgeChunk>> loadOfficialRagChunks({double minQualityScore = 0.90});
  Future<List<RagKnowledgeChunk>> searchChunks(String query, {int limit = 5});
}

class RagRepository implements IRagRepository {
  List<RagKnowledgeChunk>? _cachedChunks;

  @override
  Future<List<RagKnowledgeChunk>> loadOfficialRagChunks({double minQualityScore = 0.90}) async {
    if (_cachedChunks != null) {
      return _cachedChunks!
          .where((c) => c.qualityScore >= minQualityScore)
          .toList();
    }

    // 四層防禦 RAG 過濾：載入並套用品質評分過濾
    final rawChunks = MockSeedData.getInitialRagChunks();
    _cachedChunks = rawChunks;

    return _cachedChunks!
        .where((c) => c.qualityScore >= minQualityScore)
        .toList();
  }

  @override
  Future<List<RagKnowledgeChunk>> searchChunks(String query, {int limit = 5}) async {
    final all = await loadOfficialRagChunks();
    final q = query.toLowerCase();
    final results = all.where((c) {
      final inTopic = c.topic.toLowerCase().contains(q);
      final inContent = c.content.toLowerCase().contains(q);
      final inKeywords = c.keywords.any((k) => k.toLowerCase().contains(q));
      return inTopic || inContent || inKeywords;
    }).toList();

    // 依品質分數加權排序
    results.sort((a, b) => b.qualityScore.compareTo(a.qualityScore));
    return results.take(limit).toList();
  }
}
