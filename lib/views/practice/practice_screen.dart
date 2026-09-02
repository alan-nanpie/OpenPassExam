import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/exam_controller.dart';
import '../../controllers/ai_tutor_controller.dart';
import '../../controllers/notes_controller.dart';
import '../ai_tutor/ai_tutor_screen.dart';
import 'question_card_widget.dart';
import 'english_learning_card_widget.dart';

class PracticeScreen extends StatefulWidget {
  final String subjectId;

  const PracticeScreen({super.key, required this.subjectId});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final examCtrl = context.read<ExamController>();
      if (examCtrl.currentSubjectId != widget.subjectId || examCtrl.questions.isEmpty) {
        examCtrl.loadQuestionsForSubject(widget.subjectId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final examCtrl = context.watch<ExamController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (examCtrl.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = examCtrl.currentQuestion;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('question_number', args: {
            'current': '${examCtrl.currentIndex + 1}',
            'total': '${examCtrl.questions.length}',
          }),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          // 多語系解析切換下拉選單
          PopupMenuButton<String>(
            icon: const Icon(Icons.translate),
            tooltip: '切換詳解語言',
            initialValue: examCtrl.activeExplanationLanguage,
            onSelected: (lang) => examCtrl.setExplanationLanguage(lang),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'zh_TW', child: Text('繁體中文 (台灣)')),
              const PopupMenuItem(value: 'en', child: Text('English (官方原題)')),
              const PopupMenuItem(value: 'ja', child: Text('日本語 (Japanese)')),
              const PopupMenuItem(value: 'zh_CN', child: Text('简体中文')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: context.tr('add_to_notes'),
            onPressed: () {
              if (question != null) {
                _showAddNoteDialog(context, question.id);
              }
            },
          ),
        ],
      ),
      body: question == null
          ? const Center(child: Text('此科目暫無考題'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                QuestionCardWidget(
                  question: question,
                  selectedOptions: examCtrl.selectedOptionIndices,
                  isSubmitted: examCtrl.isAnswerSubmitted,
                  isCorrect: examCtrl.isCurrentCorrect,
                  onOptionTapped: (idx) => examCtrl.toggleOption(idx),
                ),
                const SizedBox(height: 16),

                // 確認送出答案按鈕
                if (!examCtrl.isAnswerSubmitted)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: examCtrl.selectedOptionIndices.isNotEmpty
                          ? () => examCtrl.submitAnswer()
                          : null,
                      child: Text(
                        context.tr('submit_answer'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                // 答題後展開之詳解與學習卡
                if (examCtrl.isAnswerSubmitted) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: examCtrl.isCurrentCorrect
                          ? AppColors.correctGreen.withValues(alpha: 0.12)
                          : AppColors.incorrectRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: examCtrl.isCurrentCorrect ? AppColors.correctGreen : AppColors.incorrectRed,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              examCtrl.isCurrentCorrect ? Icons.check_circle : Icons.error,
                              color: examCtrl.isCurrentCorrect ? AppColors.correctGreen : AppColors.incorrectRed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              examCtrl.isCurrentCorrect
                                  ? context.tr('correct_message')
                                  : context.tr('incorrect_message'),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: examCtrl.isCurrentCorrect ? AppColors.correctGreen : AppColors.incorrectRed,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '📖 ${context.tr("official_explanation")}:',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          examCtrl.getLocalizedExplanation(question),
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.45,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 從考題學英文卡片
                  EnglishLearningCardWidget(englishNotes: question.englishGrammarNotes),
                  const SizedBox(height: 14),

                  // AI 助教一鍵深度解析按鈕
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.psychology, color: AppColors.primary),
                      label: Text(
                        context.tr('ask_ai_tutor'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final aiCtrl = context.read<AiTutorController>();
                        aiCtrl.explainQuestion(question);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AiTutorScreen()),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back),
              label: Text(context.tr('prev_question')),
              onPressed: examCtrl.currentIndex > 0 ? () => examCtrl.previousQuestion() : null,
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              label: Text(context.tr('next_question')),
              onPressed: examCtrl.currentIndex < examCtrl.questions.length - 1
                  ? () => examCtrl.nextQuestion()
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context, String questionId) {
    final noteCtrl = context.read<NotesController>();
    final authCtrl = context.read<AuthController>();
    final existing = noteCtrl.getNoteForQuestion(questionId);

    final titleController = TextEditingController(text: existing?.title ?? '考題 $questionId 重點筆記');
    final contentController = TextEditingController(text: existing?.content ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit_note, color: AppColors.primary),
            SizedBox(width: 8),
            Text('新增 / 編輯考題筆記'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '筆記標題'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: '筆記內容 (可使用 Markdown)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await noteCtrl.addOrUpdateNote(
                id: existing?.id,
                userId: authCtrl.currentUser?.uid ?? 'guest',
                examId: widget.subjectId,
                questionId: questionId,
                title: titleController.text,
                content: contentController.text,
              );
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ 筆記已成功儲存！')),
                );
              }
            },
            child: Text(context.tr('confirm')),
          ),
        ],
      ),
    );
  }
}
