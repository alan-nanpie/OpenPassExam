import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../data/models/exam_session.dart';
import '../wrong_questions/wrong_questions_screen.dart';

class ExamResultScreen extends StatelessWidget {
  final ExamSession session;

  const ExamResultScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPassed = session.isPassed;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('exam_result_title')),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 成績總覽大卡片
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isPassed
                  ? AppColors.correctGreen.withValues(alpha: 0.12)
                  : AppColors.incorrectRed.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPassed ? AppColors.correctGreen : AppColors.incorrectRed,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  isPassed ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  color: isPassed ? AppColors.correctGreen : AppColors.incorrectRed,
                  size: 64,
                ),
                const SizedBox(height: 12),
                Text(
                  '${session.scorePercentage}%',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? AppColors.correctGreen : AppColors.incorrectRed,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isPassed ? context.tr('status_passed') : context.tr('status_failed'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isPassed ? AppColors.correctGreen : AppColors.incorrectRed,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '答對 ${session.correctCount} 題 / 總題數 ${session.totalQuestions} 題',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 領域得分率分析
          Text(
            context.tr('domain_diagnosis'),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (session.domainBreakdown.isEmpty)
            const Text('暫無領域分析數據')
          else
            ...session.domainBreakdown.entries.map((entry) {
              final domain = entry.key;
              final score = entry.value;
              final isGood = score >= 80;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(10),
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
                        Expanded(
                          child: Text(
                            domain,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${score.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isGood ? AppColors.correctGreen : AppColors.incorrectRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: score / 100,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(
                          isGood ? AppColors.correctGreen : AppColors.incorrectRed,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 24),

          // 底部操作按鈕
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_presentation),
                  label: Text(context.tr('review_wrong_questions')),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WrongQuestionsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('返回首頁'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
