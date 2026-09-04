class AppConstants {
  AppConstants._();

  static const String appName = 'PassExam';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';

  // AI 預設配置
  static const String defaultCloudAiModel = 'gemini-3.8-flash';
  static const String defaultFallbackAiModel = 'gemini-2.5-flash';
  static const String defaultOnDeviceAiModel = 'gemma-4-2b';
  static const double defaultAiTemperature = 1.0;
  static const int defaultAiMaxTokens = 4096;

  // 效能與快取規範
  static const int safeImageCacheWidth = 1024;
  static const int computeThresholdLines = 500;

  // 模擬考題數選項
  static const List<int> mockExamQuestionCounts = [10, 30, 50, 100];
  static const int defaultExamMinutes = 60;

  // Google Play 訂閱 SKU
  static const String skuProMonthly = 'passexam_pro_monthly';
  static const String skuProQuarterly = 'passexam_pro_quarterly';
  static const String skuProAnnual = 'passexam_pro_annual';

  // 本地儲存鍵名
  static const String prefKeyLocale = 'passexam_locale';
  static const String prefKeyThemeMode = 'passexam_theme_mode';
  static const String prefKeyActiveSubject = 'passexam_active_subject';
  static const String prefKeyActiveDeviceId = 'passexam_active_device_id';
  static const String prefKeyAuthToken = 'passexam_auth_token';
  static const String prefKeyUserData = 'passexam_user_data';
  static const String prefKeyOfflineQueue = 'passexam_offline_queue';
  static const String prefKeyAiConfigOverride = 'passexam_ai_config_override';
  static const String prefKeyUserGeminiApiKey = 'passexam_user_gemini_api_key';
  static const String prefKeyUserGeminiApiKeys = 'passexam_user_gemini_api_keys';

  // 預設預載科目
  static const String defaultSubjectId = 'cisco-200-301';
}
