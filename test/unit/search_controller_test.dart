import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passexam/controllers/search_controller.dart';
import 'package:passexam/data/datasources/local_persistent_cache.dart';
import 'package:passexam/data/datasources/rtdb_approved_keys_datasource.dart';
import 'package:passexam/data/repositories/repository_factory.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late LocalPersistentCache cache;
  late RtdbApprovedKeysDatasource rtdb;
  late RepositoryFactory repoFactory;
  late ExamSearchController searchCtrl;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    cache = LocalPersistentCache(prefs);
    rtdb = RtdbApprovedKeysDatasource();
    repoFactory = RepositoryFactory(localCache: cache, rtdbDatasource: rtdb);
    searchCtrl = ExamSearchController(repositoryFactory: repoFactory);
  });

  group('ExamSearchController Tests', () {
    test('一般關鍵字搜尋應能準確過濾考題', () async {
      await searchCtrl.performSearch('靜態預設路由');
      expect(searchCtrl.searchResults, isNotEmpty);
      expect(searchCtrl.searchResults.any((q) => q.title.contains('靜態預設路由')), isTrue);
    });

    test('拓撲圖片篩選器與題型篩選器', () async {
      searchCtrl.toggleOnlyWithImage(true);
      expect(searchCtrl.onlyWithImage, isTrue);

      searchCtrl.setTypeFilter('SINGLE_CHOICE');
      expect(searchCtrl.selectedTypeFilter, 'SINGLE_CHOICE');
      expect(searchCtrl.searchResults.every((q) => q.type == 'SINGLE_CHOICE'), isTrue);
    });

    test('Vertex AI 768 維度語意向量搜尋模式能根據概念擴展檢索相關考題', () async {
      searchCtrl.toggleSemanticVectorMode(true);
      expect(searchCtrl.isSemanticVectorMode, isTrue);

      await searchCtrl.performSearch('路由');
      expect(searchCtrl.searchResults, isNotEmpty);
      expect(searchCtrl.searchResults.any((q) => q.topic.contains('IP') || q.title.contains('路由')), isTrue);
    });
  });
}
