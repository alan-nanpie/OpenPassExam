import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/app_themes.dart';
import 'core/localization/app_localizations.dart';
import 'core/security/secure_screen_service.dart';
import 'core/security/web_security_service.dart';
import 'core/widgets/enhanced_security_watermark.dart';

import 'data/datasources/local_persistent_cache.dart';
import 'data/datasources/rtdb_approved_keys_datasource.dart';
import 'data/repositories/repository_factory.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/rag_repository.dart';

import 'services/remote_config_service.dart';
import 'services/ai_service.dart';
import 'services/play_billing_service.dart';

import 'controllers/auth_controller.dart';
import 'controllers/theme_locale_controller.dart';
import 'controllers/exam_controller.dart';
import 'controllers/mock_exam_controller.dart';
import 'controllers/ai_tutor_controller.dart';
import 'controllers/notebooklm_controller.dart';
import 'controllers/wrong_questions_controller.dart';
import 'controllers/notes_controller.dart';
import 'controllers/billing_controller.dart';
import 'controllers/admin_controller.dart';
import 'controllers/search_controller.dart';

import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 初始化平台安全服務 (FLAG_SECURE & Web 防護)
  await SecureScreenService.enableSecureScreen();
  WebSecurityService.initializeWebSecurity();

  // 2. 初始化持久化儲存與基礎資料來源
  final prefs = await SharedPreferences.getInstance();
  final localCache = LocalPersistentCache(prefs);
  final rtdbDatasource = RtdbApprovedKeysDatasource();
  final connectivity = Connectivity();

  // 3. 初始化倉儲
  final repoFactory = RepositoryFactory(
    localCache: localCache,
    rtdbDatasource: rtdbDatasource,
  );
  final userRepo = UserRepository(prefs);
  final ragRepo = RagRepository();

  // 4. 初始化服務
  final remoteConfigService = RemoteConfigService();
  await remoteConfigService.fetchAndActivate();

  final aiService = AiService(
    localCache: localCache,
    rtdbDatasource: rtdbDatasource,
    remoteConfigService: remoteConfigService,
    connectivity: connectivity,
  );

  final playBillingService = PlayBillingService(userRepository: userRepo);

  runApp(
    PassExamAppRoot(
      prefs: prefs,
      localCache: localCache,
      rtdbDatasource: rtdbDatasource,
      repoFactory: repoFactory,
      userRepo: userRepo,
      ragRepo: ragRepo,
      remoteConfigService: remoteConfigService,
      aiService: aiService,
      playBillingService: playBillingService,
    ),
  );
}

class PassExamAppRoot extends StatelessWidget {
  final SharedPreferences prefs;
  final LocalPersistentCache localCache;
  final RtdbApprovedKeysDatasource rtdbDatasource;
  final RepositoryFactory repoFactory;
  final IUserRepository userRepo;
  final IRagRepository ragRepo;
  final RemoteConfigService remoteConfigService;
  final AiService aiService;
  final PlayBillingService playBillingService;

  const PassExamAppRoot({
    super.key,
    required this.prefs,
    required this.localCache,
    required this.rtdbDatasource,
    required this.repoFactory,
    required this.userRepo,
    required this.ragRepo,
    required this.remoteConfigService,
    required this.aiService,
    required this.playBillingService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeLocaleController(prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthController(userRepository: userRepo)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => ExamController(
            repositoryFactory: repoFactory,
            localCache: localCache,
          )..loadQuestionsForSubject(AppConstants.defaultSubjectId),
        ),
        ChangeNotifierProvider(
          create: (_) => MockExamController(
            repositoryFactory: repoFactory,
            localCache: localCache,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AiTutorController(
            aiService: aiService,
            ragRepository: ragRepo,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NotebookLMController(
            ragRepository: ragRepo,
            localCache: localCache,
            aiService: aiService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WrongQuestionsController(localCache: localCache),
        ),
        ChangeNotifierProvider(
          create: (_) => NotesController(localCache: localCache),
        ),
        ChangeNotifierProxyProvider<AuthController, BillingController>(
          create: (ctx) => BillingController(
            billingService: playBillingService,
            authController: ctx.read<AuthController>(),
          ),
          update: (ctx, auth, billing) =>
              billing ??
              BillingController(
                billingService: playBillingService,
                authController: auth,
              ),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminController(
            repositoryFactory: repoFactory,
            localCache: localCache,
            rtdbDatasource: rtdbDatasource,
            remoteConfigService: remoteConfigService,
            aiService: aiService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ExamSearchController(repositoryFactory: repoFactory),
        ),
      ],
      child: const PassExamMaterialApp(),
    );
  }
}

class PassExamMaterialApp extends StatelessWidget {
  const PassExamMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeLocale = context.watch<ThemeLocaleController>();
    final auth = context.watch<AuthController>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: themeLocale.themeMode,
      locale: themeLocale.locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: auth.isLoggedIn ? const HomeScreen() : const LoginScreen(),
      builder: (ctx, child) {
        return EnhancedSecurityWatermark(
          userId: auth.currentUser?.uid ?? 'guest',
          userName: auth.currentUser?.displayName ?? 'Guest User',
          isEnabled: true,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
