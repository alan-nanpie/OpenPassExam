import '../datasources/local_persistent_cache.dart';
import '../datasources/rtdb_approved_keys_datasource.dart';
import 'question_repository.dart';

class RepositoryFactory {
  final LocalPersistentCache localCache;
  final RtdbApprovedKeysDatasource rtdbDatasource;
  final Map<String, IQuestionRepository> _repositoryPool = {};

  RepositoryFactory({
    required this.localCache,
    required this.rtdbDatasource,
  });

  /// 根據科目 ID (如 cisco-200-301, cisco-350-401) 取得或建立專屬 QuestionRepository
  IQuestionRepository getQuestionRepository(String subjectId) {
    if (!_repositoryPool.containsKey(subjectId)) {
      _repositoryPool[subjectId] = FirestoreQuestionRepository(
        subjectId: subjectId,
        localCache: localCache,
        rtdbDatasource: rtdbDatasource,
      );
    }
    return _repositoryPool[subjectId]!;
  }
}
