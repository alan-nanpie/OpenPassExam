import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/safe_image_widget.dart';
import '../../core/widgets/question_image_reference_dialog.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/mock_exam_controller.dart';
import 'exam_timer_widget.dart';
import 'exam_result_screen.dart';

class MockExamScreen extends StatefulWidget {
  final String subjectId;

  const MockExamScreen({super.key, required this.subjectId});

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  int _selectedQuestionCount = 10;
  bool _isExamStarted = false;

  @override
  Widget build(BuildContext context) {
    if (!_isExamStarted) {
      return _buildSetupScreen(context);
    }
    return _buildActiveExamScreen(context);
  }

  Widget _buildSetupScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('mock_exam_title')),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.timer_outlined, size: 64, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  '全真計時模擬考 - ${widget.subjectId}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '系統將隨機抽取考題，模擬真實考試環境。交卷後立即產生領域診斷雷達分析報告！',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),

                Text(
                  context.tr('select_question_count'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),

                // 題數選擇 Chips
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: AppConstants.mockExamQuestionCounts.map((count) {
                    final isSelected = _selectedQuestionCount == count;
                    return ChoiceChip(
                      label: Text('$count 題'),
                      selected: isSelected,
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : null,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedQuestionCount = count;
                          });
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 36),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final mockCtrl = context.read<MockExamController>();
                      mockCtrl.startMockExam(
                        subjectId: widget.subjectId,
                        questionCount: _selectedQuestionCount,
                      );
                      setState(() {
                        _isExamStarted = true;
                      });
                    },
                    child: const Text(
                      '開始全真計時測驗',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveExamScreen(BuildContext context) {
    final mockCtrl = context.watch<MockExamController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final question = mockCtrl.currentQuestion;
    if (question == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final selectedOptions = mockCtrl.currentSelectedOptions;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '題號 ${mockCtrl.currentIndex + 1} / ${mockCtrl.examQuestions.length}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          // 局部重繪計時器，杜絕全頁刷新！
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ExamTimerWidget(
              remainingSecondsNotifier: mockCtrl.remainingSecondsNotifier,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view),
            tooltip: '答題卡導覽',
            onPressed: () => _showQuestionGridSheet(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 考點標籤
          Text(
            '【${question.topic}】',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),

          // 考題本文
          Text(
            question.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
          ),
          const SizedBox(height: 14),

          // 圖片拓撲
          if (question.imageUrl != null && question.imageUrl!.isNotEmpty) ...[
            SafeImageWidget(imageUrl: question.imageUrl, height: 160, enableZoomOnClick: true),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.splitscreen, size: 16),
                label: const Text('圖文分屏對照', style: TextStyle(fontSize: 12)),
                onPressed: () => QuestionImageReferenceDialog.show(context, question),
              ),
            ),
            const SizedBox(height: 10),
          ],

          // 選項列表
          ...List.generate(question.options.length, (idx) {
            final isSelected = selectedOptions.contains(idx);
            final optChar = String.fromCharCode(65 + idx);

            return InkWell(
              onTap: () => mockCtrl.toggleOption(idx),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.optionSelectedDark : AppColors.optionSelected)
                      : (isDark ? AppColors.darkCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    width: isSelected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.2),
                      ),
                      child: Text(
                        optChar,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        question.options[idx],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
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
            OutlinedButton(
              onPressed: mockCtrl.currentIndex > 0 ? () => mockCtrl.prevQuestion() : null,
              child: Text(context.tr('prev_question')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _confirmSubmitExam(context),
              child: Text(context.tr('submit_exam')),
            ),
            OutlinedButton(
              onPressed: mockCtrl.currentIndex < mockCtrl.examQuestions.length - 1
                  ? () => mockCtrl.nextQuestion()
                  : null,
              child: Text(context.tr('next_question')),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuestionGridSheet(BuildContext context) {
    final mockCtrl = context.read<MockExamController>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '答題卡導覽 (點擊跳題)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: mockCtrl.examQuestions.length,
                itemBuilder: (c, idx) {
                  final hasAnswered = mockCtrl.userAnswers[idx]?.isNotEmpty ?? false;
                  final isCurrent = mockCtrl.currentIndex == idx;

                  return InkWell(
                    onTap: () {
                      mockCtrl.jumpToQuestion(idx);
                      Navigator.of(ctx).pop();
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: hasAnswered
                            ? AppColors.primary
                            : (isCurrent ? AppColors.warning : Colors.grey.withValues(alpha: 0.2)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          color: hasAnswered || isCurrent ? Colors.white : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSubmitExam(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('確認交卷'),
        content: Text(context.tr('submit_exam_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final authCtrl = context.read<AuthController>();
              final mockCtrl = context.read<MockExamController>();
              final session = await mockCtrl.submitExam(
                subjectId: widget.subjectId,
                userId: authCtrl.currentUser?.uid ?? 'guest',
              );
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ExamResultScreen(session: session),
                  ),
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
