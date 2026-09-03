import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/ai_tutor_controller.dart';
import '../../services/offline_model_manager.dart';
import '../../core/utils/file_exporter.dart';
import 'persona_selector_widget.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final aiCtrl = context.watch<AiTutorController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('ai_tutor_title')),
        actions: [
          Builder(
            builder: (ctx) {
              final offlineMgr = ctx.watch<OfflineModelManager>();
              final isDownloading = offlineMgr.status == OfflineModelStatus.downloading;
              final isReady = offlineMgr.isModelReady;

              return IconButton(
                icon: isDownloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                      )
                    : Icon(
                        isReady ? Icons.offline_bolt : Icons.download_for_offline_outlined,
                        color: isReady ? AppColors.correctGreen : AppColors.warning,
                      ),
                tooltip: isDownloading
                    ? '離線 AI 模型下載中 (${(offlineMgr.downloadProgress * 100).toInt()}%)'
                    : (isReady ? '端側離線 AI 模型：已就緒 (點此管理或下載)' : '下載離線 AI 模型 (Gemma 4 2B)'),
                onPressed: () => _showOfflineModelModal(context, offlineMgr),
              );
            },
          ),
          IconButton(
            icon: Icon(
              aiCtrl.hasUserApiKey ? Icons.vpn_key : Icons.vpn_key_outlined,
              color: aiCtrl.hasUserApiKey ? Colors.green : AppColors.warning,
            ),
            tooltip: aiCtrl.hasUserApiKey ? '個人 Gemini Key：已設定' : '設定個人 Gemini API Key (BYOK)',
            onPressed: () => _showApiKeyDialog(context, aiCtrl),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: '匯出全部對話為 Markdown (西元年月日時分秒.md)',
            onPressed: () => _exportAllMessagesToMarkdown(context, aiCtrl),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: '雙 AI 引擎架構',
            onPressed: () => _showAiInfoDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 頂部 AI 模式指示與切換列 (離線優先 / 雲端旗艦)
          Builder(
            builder: (ctx) {
              final offlineMgr = ctx.watch<OfflineModelManager>();
              final isOfflinePreferred = offlineMgr.preferOffline;
              final isReady = offlineMgr.isModelReady;
              final isDownloading = offlineMgr.status == OfflineModelStatus.downloading;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : Colors.grey.shade100,
                  border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDownloading
                          ? Icons.downloading_rounded
                          : (isOfflinePreferred ? Icons.offline_bolt : Icons.cloud_done),
                      size: 18,
                      color: isDownloading
                          ? AppColors.primary
                          : (isOfflinePreferred ? AppColors.correctGreen : AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDownloading
                                ? '📥 正在下載端側模型 (${(offlineMgr.downloadProgress * 100).toInt()}%)'
                                : (isOfflinePreferred
                                    ? (isReady ? '⚡ 模式：端側離線推論 (Gemma 4 2B 已就緒)' : '⚡ 模式：端側離線 (尚未下載完整模型)')
                                    : (aiCtrl.hasUserApiKey ? '☁️ 模式：Google 雲端 Gemini 旗艦推論 (gemini-2.5-flash)' : '⚠️ 雲端模式：尚未設定 API Key → 點此設定')),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isOfflinePreferred ? '0 延遲 • 零網路流量消耗 • 100% 隱私' : '高深度 Dynamic Thinking 思考架構',
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      ),
                      icon: Icon(
                        isReady ? Icons.tune : Icons.download,
                        size: 14,
                      ),
                      label: Text(
                        isReady ? '模型管理' : '下載離線模型',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showOfflineModelModal(context, offlineMgr),
                    ),
                  ],
                ),
              );
            },
          ),

          // 未設定 API Key 提示列
          if (!aiCtrl.hasUserApiKey)
            InkWell(
              onTap: () => _showApiKeyDialog(context, aiCtrl),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: AppColors.primary.withValues(alpha: 0.1),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '💡 目前為離線端側模式。點此填入免費 Gemini Key 啟用雲端旗艦推理！',
                        style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 18, color: AppColors.primary),
                  ],
                ),
              ),
            ),

          // Persona 切換列
          PersonaSelectorWidget(
            currentPersona: aiCtrl.currentPersona,
            onPersonaSelected: (p) => aiCtrl.setPersona(p),
          ),
          const Divider(height: 1),

          // 對話歷史訊息列表
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: aiCtrl.messages.length,
              itemBuilder: (ctx, idx) {
                final msg = aiCtrl.messages[idx];
                ChatMessage? correspondingUserMsg;
                if (!msg.isUser) {
                  // 往前尋找距離此 AI 回答最近的使用者提問
                  for (int i = idx - 1; i >= 0; i--) {
                    if (aiCtrl.messages[i].isUser) {
                      correspondingUserMsg = aiCtrl.messages[i];
                      break;
                    }
                  }
                }
                return _buildMessageBubble(
                  context,
                  msg,
                  isDark,
                  correspondingUserMsg: correspondingUserMsg,
                  aiCtrl: aiCtrl,
                );
              },
            ),
          ),

          // 載入指示
          if (aiCtrl.isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Gemini 3.7 Dynamic Thinking 思考推理中...',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),

          // 底部輸入列
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: context.tr('ai_tutor_prompt_hint'),
                        hintStyle: const TextStyle(fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () {
                      final text = _promptController.text.trim();
                      if (text.isNotEmpty) {
                        aiCtrl.sendUserMessage(text);
                        _promptController.clear();
                        _scrollToBottom();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg, bool isDark, {ChatMessage? correspondingUserMsg, required AiTutorController aiCtrl}) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16).copyWith(bottomRight: Radius.zero),
          ),
          child: Text(
            msg.text,
            style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.35),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16).copyWith(bottomLeft: Radius.zero),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (msg.modelBadge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '⚡ ${msg.modelBadge}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                // 單一問題匯出 Markdown 按鈕
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _exportSingleMessageToMarkdown(context, aiCtrl, msg, userMsg: correspondingUserMsg),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.download_rounded,
                          size: 14,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '匯出此題 Markdown',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            MarkdownBody(
              data: msg.text,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
                code: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  backgroundColor: Color(0x15000000),
                ),
                codeblockDecoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF272822),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 匯出單一對話為 Markdown (西元年月日時分秒.md)
  Future<void> _exportSingleMessageToMarkdown(
    BuildContext context,
    AiTutorController aiCtrl,
    ChatMessage aiMsg, {
    ChatMessage? userMsg,
  }) async {
    final fileName = FileExporter.generateTimestampFileName(aiMsg.timestamp);
    final mdContent = aiCtrl.generateSingleExchangeMarkdown(aiMsg, userMsg: userMsg);

    final success = await FileExporter.exportMarkdown(
      markdownContent: mdContent,
      customFileName: fileName,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '✅ 已成功匯出問答紀錄：$fileName' : '❌ 匯出失敗，請確認瀏覽器下載權限',
          ),
          backgroundColor: success ? AppColors.correctGreen : Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '確定',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  /// 匯出全部歷史對話為 Markdown (西元年月日時分秒.md)
  Future<void> _exportAllMessagesToMarkdown(
    BuildContext context,
    AiTutorController aiCtrl,
  ) async {
    if (aiCtrl.messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('目前尚無對話紀錄可供匯出')),
      );
      return;
    }

    final fileName = FileExporter.generateTimestampFileName();
    final mdContent = aiCtrl.generateAllExchangesMarkdown();

    final success = await FileExporter.exportMarkdown(
      markdownContent: mdContent,
      customFileName: fileName,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? '🎉 已匯出全部 ${aiCtrl.messages.length} 則完整對話：$fileName' : '❌ 匯出失敗，請重試',
          ),
          backgroundColor: success ? AppColors.correctGreen : Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: '確定',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  void _showAiInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: AppColors.primary),
            SizedBox(width: 8),
            Text('PassExam 雙 AI 引擎規格'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. 雲端旗艦：Google Gemini 3.7 Flash',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                '具備 Dynamic Thinking 思考深度，能根據網路題目難度動態分配推理運算，輸出生活化比喻與手把手 Cisco CLI 實戰教學。',
                style: TextStyle(fontSize: 12.5),
              ),
              SizedBox(height: 12),
              Text(
                '2. 端側離線：Google Gemma 4 (2B) LiteRT',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                '預算鎖定 4096 Tokens，徹底解除 200 字長度截斷，在無網路狀態下仍可產出完整 5 階段深度解析與配置範例。',
                style: TextStyle(fontSize: 12.5),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, AiTutorController aiCtrl) {
    final textController = TextEditingController(text: aiCtrl.userGeminiApiKey ?? '');
    var isObscured = true;
    var isTestingKey = false;
    String? testResult;
    var isTestSuccess = false;

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
                const SizedBox(height: 12),
                // 測試連線按鈕與即時結果
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: isTestingKey
                          ? null
                          : () async {
                              final inputKey = textController.text.trim();
                              if (inputKey.isEmpty) {
                                setState(() {
                                  testResult = '請先輸入 API Key 後再點擊測試！';
                                  isTestSuccess = false;
                                });
                                return;
                              }
                              setState(() {
                                isTestingKey = true;
                                testResult = null;
                              });
                              final err = await aiCtrl.testUserApiKey(inputKey);
                              setState(() {
                                isTestingKey = false;
                                isTestSuccess = err == null;
                                testResult = err == null
                                    ? '✅ Google 雲端 API 連線成功！金鑰有效可用。'
                                    : '❌ 驗證失敗：$err';
                              });
                            },
                      icon: isTestingKey
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.bolt, size: 16),
                      label: Text(isTestingKey ? '正在連線測試...' : '⚡ 測試金鑰有效性'),
                    ),
                  ],
                ),
                if (testResult != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isTestSuccess
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isTestSuccess ? Colors.green : Colors.red,
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      testResult!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isTestSuccess ? Colors.green.shade700 : Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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

  void _showOfflineModelModal(BuildContext context, OfflineModelManager offlineMgr) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (bottomCtx, setModalState) {
          final isReady = offlineMgr.isModelReady;
          final isDownloading = offlineMgr.status == OfflineModelStatus.downloading;

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isReady ? AppColors.correctGreen : AppColors.primary).withValues(alpha: 0.12),
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
                          const Text(
                            '端側離線 AI 模型管理中心',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            offlineMgr.modelName,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 規格卡片
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('模型規格', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(offlineMgr.modelName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('磁碟空間', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(offlineMgr.modelEstimatedSize, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('硬體加速支援', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Expanded(
                            child: Text(
                              offlineMgr.platformSupportDescription,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.end,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 下載與狀態區塊
                if (isDownloading) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('正在下載模型並解密 LiteRT 權重...', style: TextStyle(fontSize: 12)),
                      Text(
                        '${(offlineMgr.downloadProgress * 100).toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: offlineMgr.downloadProgress,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else if (isReady) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.correctGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.correctGreen.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, size: 18, color: AppColors.correctGreen),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '端側離線 AI 模型已就緒！無網路時能進行 4096 Tokens 極速推論。',
                            style: TextStyle(fontSize: 12, color: AppColors.correctGreen, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('刪除模型 (釋放空間)'),
                          onPressed: () async {
                            await offlineMgr.deleteModel();
                            setModalState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '尚未下載完整離線模型檔案。點擊下方按鈕即可下載並快取至本機。',
                            style: TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.download),
                      label: Text('📥 立即下載離線 AI 模型 (${offlineMgr.modelEstimatedSize})'),
                      onPressed: () async {
                        offlineMgr.downloadModel();
                        setModalState(() {});
                      },
                    ),
                  ),
                ],

                const Divider(height: 24),

                // 離線模式開關
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('優先使用端側離線 AI 模型 (第 1 優先)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  subtitle: const Text(
                    '開啟：優先於本機設備以 Gemma 4 2B 極速作答 (0 延遲、無網可用)\n'
                    '關閉：優先調用雲端 Google 最新 Gemini 旗艦多模態模型',
                    style: TextStyle(fontSize: 11.5),
                  ),
                  value: offlineMgr.preferOffline,
                  onChanged: (val) async {
                    await offlineMgr.setPreferOffline(val);
                    setModalState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
