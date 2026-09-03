import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passexam/data/datasources/local_persistent_cache.dart';
import 'package:passexam/data/datasources/rtdb_approved_keys_datasource.dart';
import 'package:passexam/data/repositories/repository_factory.dart';
import 'package:passexam/data/repositories/user_repository.dart';
import 'package:passexam/data/repositories/rag_repository.dart';
import 'package:passexam/services/remote_config_service.dart';
import 'package:passexam/services/ai_service.dart';
import 'package:passexam/services/play_billing_service.dart';
import 'package:passexam/main.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('PassExam App Root smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final localCache = LocalPersistentCache(prefs);
    final rtdb = RtdbApprovedKeysDatasource();
    final repoFactory = RepositoryFactory(localCache: localCache, rtdbDatasource: rtdb);
    final userRepo = UserRepository(prefs);
    final ragRepo = RagRepository();
    final remoteConfig = RemoteConfigService();
    final aiService = AiService(
      localCache: localCache,
      rtdbDatasource: rtdb,
      remoteConfigService: remoteConfig,
      connectivity: Connectivity(),
    );
    final playBilling = PlayBillingService(userRepository: userRepo);

    await tester.pumpWidget(
      PassExamAppRoot(
        prefs: prefs,
        localCache: localCache,
        rtdbDatasource: rtdb,
        repoFactory: repoFactory,
        userRepo: userRepo,
        ragRepo: ragRepo,
        remoteConfigService: remoteConfig,
        aiService: aiService,
        playBillingService: playBilling,
      ),
    );

    expect(find.byType(PassExamMaterialApp), findsOneWidget);
  });
}
