import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/theme_locale_controller.dart';
import '../../controllers/ai_tutor_controller.dart';
import '../../services/offline_model_manager.dart';
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

          // 離線端側 AI 模型管理中心 (第一優先)
          Text(
            '端側離線 AI 模型管理中心 (第 1 優先推論)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),

          _buildOfflineModelHubCard(context, isDark),
          const SizedBox(height: 20),

          // AI 家教金鑰設定 (BYOK - 第二優先 Gemini 3.8 Flash)
          Text(
            '雲端 AI 旗艦模型配置 (第 2 優先 Gemini 3.8 Flash 多模態)',
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
                  title: Text(hasKey ? 'Gemini 3.8 Flash API Key：已設定 (${aiCtrl.userGeminiApiKeys.length} 組金鑰池)' : 'Gemini 3.8 Flash API Key：尚未設定'),
                  subtitle: Text(
                    hasKey
                        ? '已綁定 ${aiCtrl.userGeminiApiKeys.length} 組專屬金鑰池，自動輪替保證高可用性，支援 AQ... 與 AIzaSy... 格式。'
                        : '點此填入免費申請之 Gemini API Key (支援多組金鑰輪替，支援 AQ... 與 AIzaSy...)',
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

  Widget _buildOfflineModelHubCard(BuildContext context, bool isDark) {
    return Builder(
      builder: (ctx) {
        final offlineMgr = ctx.watch<OfflineModelManager>();
        final isReady = offlineMgr.isModelReady;
        final isDownloading = offlineMgr.status == OfflineModelStatus.downloading;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isReady
                            ? AppColors.correctGreen.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isReady ? Icons.offline_bolt : Icons.downloading_rounded,
                        color: isReady ? AppColors.correctGreen : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offlineMgr.modelName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            offlineMgr.platformSupportDescription,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 狀態與下載進度
                if (isDownloading) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('模型下載中，請勿關閉應用程式...', style: TextStyle(fontSize: 12)),
                      Text(
                        '${(offlineMgr.downloadProgress * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: offlineMgr.downloadProgress,
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isReady
                          ? AppColors.correctGreen.withValues(alpha: 0.08)
                          : Colors.amber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isReady
                            ? AppColors.correctGreen.withValues(alpha: 0.3)
                            : Colors.amber.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isReady ? Icons.check_circle : Icons.info_outline,
                          size: 16,
                          color: isReady ? AppColors.correctGreen : Colors.amber[800],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isReady
                                ? '離線推論就緒：第 1 優先在終端本機推論（零延遲、免網路）'
                                : '未下載離線模型（預估大小：${offlineMgr.modelEstimatedSize}）',
                            style: TextStyle(
                              fontSize: 12,
                              color: isReady ? AppColors.correctGreen : Colors.amber[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // 操作按鈕與開關
                Row(
                  children: [
                    if (!isReady && !isDownloading)
                      FilledButton.icon(
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('下載離線模型 (第1優先)'),
                        onPressed: () => offlineMgr.downloadModel(),
                      )
                    else if (isReady) ...[
                      OutlinedButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        label: const Text('釋放空間', style: TextStyle(color: Colors.red)),
                        onPressed: () => offlineMgr.deleteModel(),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '儲存狀態：已下載快取',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
                const Divider(height: 24),

                // 離線第一優先開關
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('啟用離線模型為第 1 優先', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  subtitle: const Text('開啟後所有考題解析優先於本機端側推論，無網路時亦 100% 可用', style: TextStyle(fontSize: 11.5)),
                  value: offlineMgr.preferOffline,
                  onChanged: (v) => offlineMgr.setPreferOffline(v),
                ),
              ],
            ),
          ),
        );
      },
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
    final existingKeys = aiCtrl.userGeminiApiKeys;
    final textController = TextEditingController(
      text: existingKeys.isNotEmpty ? existingKeys.join('\n') : '',
    );
    var isObscured = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.key, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Gemini API Key 金鑰池設定 (BYOK)'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '💡 **自備免費金鑰池機制 (BYOK & Failover)**：\n'
                  '為保障您的專屬獨立配額，您可以向 Google 官方免費申請一至多組個人專屬的 Gemini 3.8 Flash API Key。\n\n'
                  '• **支援最新金鑰格式**：完全支援新版 `AQ.Ab8RN6J...` 與經典 `AIzaSy...` 格式。\n'
                  '• **多組金鑰智慧輪替**：可輸入多組金鑰（一行一把），遇到每日免費額度耗盡 (429) 或異常時，系統會**自動切換至下一組金鑰**！\n'
                  '• **極致安全**：金鑰僅存於您的本機裝置（瀏覽器快取），絕不上傳任何伺服器。',
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
                  maxLines: isObscured ? 1 : 5,
                  decoration: InputDecoration(
                    labelText: '輸入 Gemini API Key（多組請以換行隔開）',
                    hintText: "AQ.Ab8RN6J...\n或 AIzaSy...",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility),
                      tooltip: isObscured ? '顯示全部金鑰' : '隱藏金鑰',
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
                      const SnackBar(content: Text('已清除所有個人 Gemini API Key，切換為離線端側模式')),
                    );
                  }
                },
                child: const Text('清除全部金鑰', style: TextStyle(color: Colors.red)),
              ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                final raw = textController.text.trim();
                final keys = raw
                    .split(RegExp(r'[\n,;]'))
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();
                if (keys.isNotEmpty) {
                  await aiCtrl.saveUserApiKeys(keys);
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ 已成功儲存 ${keys.length} 組個人 Gemini API Key 金鑰池！')),
                    );
                  }
                } else {
                  await aiCtrl.clearUserApiKey();
                  if (ctx.mounted) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已清除金鑰')),
                    );
                  }
                }
              },
              child: const Text('儲存金鑰池'),
            ),
          ],
        ),
      ),
    );
  }
}

