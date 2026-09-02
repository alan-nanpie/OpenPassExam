import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/exam_controller.dart';
import '../../controllers/notebooklm_controller.dart';
import 'notebooklm_studio_widget.dart';

class NotebookLMScreen extends StatefulWidget {
  const NotebookLMScreen({super.key});

  @override
  State<NotebookLMScreen> createState() => _NotebookLMScreenState();
}

class _NotebookLMScreenState extends State<NotebookLMScreen> {
  final TextEditingController _focusPromptController = TextEditingController();

  @override
  void dispose() {
    _focusPromptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nlmCtrl = context.watch<NotebookLMController>();
    final examCtrl = context.watch<ExamController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('notebooklm_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // GCS 雲端教科書知識庫載入區塊
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1F2937), const Color(0xFF111827)]
                    : [const Color(0xFFE8F0FE), const Color(0xFFF1F3F4)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cloud_sync, color: AppColors.primary, size: 24),
                    const SizedBox(width: 10),
                    const Text(
                      'Google 雲端 GCS 官方教科書知識庫',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '內建 6,688 個經過四層防禦過濾（頁面分類、5大維度評分、範圍過濾、檢索加權）之官方認證教科書精華切片。',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                if (nlmCtrl.isLoadingGcsRag)
                  const Center(child: CircularProgressIndicator())
                else if (nlmCtrl.loadedChunks.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.correctGreen, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        context.tr('rag_loaded_status', args: {
                          'count': '${nlmCtrl.loadedChunks.length}',
                        }),
                        style: const TextStyle(
                          color: AppColors.correctGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(context.tr('load_gcs_rag')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => nlmCtrl.loadGcsRagKnowledgePacks(),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5+1 Studio 工具選擇器
          NotebookLMStudioWidget(
            selectedTool: nlmCtrl.selectedToolType,
            onToolSelected: (t) => nlmCtrl.selectToolType(t),
          ),
          const SizedBox(height: 16),

          // 自訂聚焦指示詞輸入框
          TextField(
            controller: _focusPromptController,
            onChanged: (v) => nlmCtrl.setCustomFocusPrompt(v),
            decoration: InputDecoration(
              hintText: context.tr('custom_focus_hint'),
              hintStyle: const TextStyle(fontSize: 12.5),
              prefixIcon: const Icon(Icons.filter_center_focus, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          // 產出按鈕
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              icon: nlmCtrl.isGeneratingArtifact
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                context.tr('generate_artifact'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: nlmCtrl.isGeneratingArtifact
                  ? null
                  : () {
                      nlmCtrl.generateArtifactForExam(
                        examId: examCtrl.currentSubjectId,
                        examTitle: 'Cisco 認證考科',
                      );
                    },
            ),
          ),
          const SizedBox(height: 24),

          // 產出成果 Artifacts 歷史展示
          const Text(
            '產出的專屬研讀教材 (Generated Artifacts)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (nlmCtrl.artifacts.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              child: Center(
                child: Text(
                  context.tr('artifact_empty'),
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...nlmCtrl.artifacts.map((art) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
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
                        Row(
                          children: [
                            const Icon(Icons.auto_stories, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              art.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        Text(
                          art.createdAt.toIso8601String().substring(0, 10),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (art.customFocusPrompt.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '聚焦要求: ${art.customFocusPrompt}',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary),
                      ),
                    ],
                    const Divider(height: 16),
                    MarkdownBody(
                      data: art.contentMarkdown,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                        tableBorder: TableBorder.all(
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                        ),
                        tableHead: const TextStyle(fontWeight: FontWeight.bold),
                        p: TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
