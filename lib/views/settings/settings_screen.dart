import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/theme_locale_controller.dart';
import '../../controllers/ai_tutor_controller.dart';
import '../notes/notes_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeLocale = context.watch<ThemeLocaleController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('nav_settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 外觀主題
          Text(
            '外觀主題與顯示',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(context.tr('system_mode')),
                  trailing: themeLocale.themeMode == ThemeMode.system
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => themeLocale.setThemeMode(ThemeMode.system),
                ),
                ListTile(
                  title: Text(context.tr('light_mode')),
                  trailing: themeLocale.themeMode == ThemeMode.light
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => themeLocale.setThemeMode(ThemeMode.light),
                ),
                ListTile(
                  title: Text(context.tr('dark_mode')),
                  trailing: themeLocale.themeMode == ThemeMode.dark
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () => themeLocale.setThemeMode(ThemeMode.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 介面語言
          Text(
            context.tr('language_select'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                _buildLocaleTile(context, themeLocale, const Locale('zh', 'TW'), '繁體中文 (台灣標準術語)'),
                _buildLocaleTile(context, themeLocale, const Locale('en', 'US'), 'English (US)'),
                _buildLocaleTile(context, themeLocale, const Locale('ja', 'JP'), '日本語 (Japanese)'),
                _buildLocaleTile(context, themeLocale, const Locale('zh', 'CN'), '简体中文'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // AI 家教金鑰設定 (BYOK)
          Text(
            'AI 家教配置 (BYOK 自備免費金鑰)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),

          Builder(
            builder: (ctx) {
              final aiCtrl = ctx.watch<AiTutorController>();
              final hasKey = aiCtrl.hasUserApiKey;

              return Card(
                child: ListTile(
                  leading: Icon(
                    hasKey ? Icons.key : Icons.key_off_outlined,
                    color: hasKey ? Colors.green : AppColors.warning,
                  ),
                  title: Text(hasKey ? 'Gemini API Key：已設定' : 'Gemini API Key：尚未設定'),
                  subtitle: Text(
                    hasKey
                        ? '已綁定個人專屬金鑰，享有完整 Gemini 3.7 推理'
                        : '點此填入免費申請之 Gemini API Key (1分鐘免費取得)',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showApiKeySettingsDialog(ctx, aiCtrl),
                ),
              );
            },
          ),
          const SizedBox(height: 20),

          // 學習筆記快速入口
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
            ),
            leading: const Icon(Icons.menu_book, color: AppColors.primary),
            title: Text(context.tr('nav_notes')),
            subtitle: const Text('檢視與複習已儲存之考題筆記'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotesScreen()),
              );
            },
          ),
          const SizedBox(height: 20),


          // 版本資訊
          Center(
            child: Column(
              children: [
                Text(
                  '${AppConstants.appName} v${AppConstants.appVersion} (${AppConstants.buildNumber})',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '遵循 Google Play 2026 安全架構與純 Google 雲端生態系',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocaleTile(
    BuildContext context,
    ThemeLocaleController ctrl,
    Locale locale,
    String title,
  ) {
    final isSelected = ctrl.locale.languageCode == locale.languageCode &&
        (locale.countryCode == null || ctrl.locale.countryCode == locale.countryCode);

    return ListTile(
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () => ctrl.setLocale(locale),
    );
  }

  void _showApiKeySettingsDialog(BuildContext context, AiTutorController aiCtrl) {
    final textController = TextEditingController(text: aiCtrl.userGeminiApiKey ?? '');
    var isObscured = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.key, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Gemini API Key 設定 (BYOK)'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 **自備免費金鑰機制 (BYOK)**：\n'
                  '為保障您的隱私與專屬獨立配額，您可以免費向 Google 官方申請個人專屬的 Gemini 3.7 Flash API Key。\n\n'
                  '• **100% 免費**：Google AI Studio 提供充裕免費額度，免綁信用卡。\n'
                  '• **極致安全**：金鑰僅保存在本機裝置（瀏覽器/手機快取），絕不上傳任何伺服器。',
                  style: TextStyle(fontSize: 12.5, height: 1.45),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: const SelectableText(
                    '👉 免費申請網址：\nhttps://aistudio.google.com/app/apikey',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  obscureText: isObscured,
                  decoration: InputDecoration(
                    labelText: '輸入您的 Gemini API Key (AIzaSy...)',
                    hintText: 'AIzaSy...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => isObscured = !isObscured),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            if (aiCtrl.hasUserApiKey)
              TextButton(
                onPressed: () async {
                  await aiCtrl.clearUserApiKey();
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已清除個人 Gemini API Key，切換為離線端側模式')),
                    );
                  }
                },
                child: const Text('清除金鑰', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final key = textController.text.trim();
                if (key.isNotEmpty) {
                  await aiCtrl.saveUserApiKey(key);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ 已成功儲存個人 Gemini API Key！')),
                    );
                  }
                } else {
                  await aiCtrl.clearUserApiKey();
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                  }
                }
              },
              child: const Text('儲存設定'),
            ),
          ],
        ),
      ),
    );
  }
}

