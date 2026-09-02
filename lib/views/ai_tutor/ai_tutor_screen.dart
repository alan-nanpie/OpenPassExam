import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/ai_tutor_controller.dart';
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
          IconButton(
            icon: Icon(
              aiCtrl.hasUserApiKey ? Icons.vpn_key : Icons.vpn_key_outlined,
              color: aiCtrl.hasUserApiKey ? Colors.green : AppColors.warning,
            ),
            tooltip: aiCtrl.hasUserApiKey ? '個人 Gemini Key：已設定' : '設定個人 Gemini API Key (BYOK)',
            onPressed: () => _showApiKeyDialog(context, aiCtrl),
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
                        '💡 目前為離線端側模式。點此填入免費 Gemini Key 啟用旗艦推理！',
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
                return _buildMessageBubble(context, msg, isDark);
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

  Widget _buildMessageBubble(BuildContext context, ChatMessage msg, bool isDark) {
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
            if (msg.modelBadge != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
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
              ),
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

