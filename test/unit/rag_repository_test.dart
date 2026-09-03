import 'package:flutter_test/flutter_test.dart';
import 'package:passexam/data/repositories/rag_repository.dart';

void main() {
  late RagRepository repo;

  setUp(() {
    repo = RagRepository();
  });

  group('RagRepository Tests', () {
    test('loadOfficialRagChunks 應依據最低品質門檻過濾切片', () async {
      final chunks = await repo.loadOfficialRagChunks(minQualityScore: 0.95);
      expect(chunks, isNotEmpty);
      expect(chunks.every((c) => c.qualityScore >= 0.95), isTrue);
    });

    test('searchChunks 應根據主題或關鍵字檢索並按品質分數降序排序', () async {
      final results = await repo.searchChunks('RSTP');
      expect(results, isNotEmpty);
      expect(results.first.topic, contains('Rapid Spanning Tree Protocol'));

      // 驗證排序
      if (results.length > 1) {
        expect(results[0].qualityScore >= results[1].qualityScore, isTrue);
      }
    });

    test('無匹配查詢時回傳空清單', () async {
      final results = await repo.searchChunks('xyz_non_existent_protocol_query_123');
      expect(results, isEmpty);
    });
  });
}
