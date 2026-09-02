import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/wrong_questions_controller.dart';
import '../../controllers/ai_tutor_controller.dart';
import '../ai_tutor/ai_tutor_screen.dart';

class WrongQuestionsScreen extends StatelessWidget {
  const WrongQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wrongCtrl = context.watch<WrongQuestionsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final questions = wrongCtrl.filteredQuestions;
    final domains = wrongCtrl.availableDomains;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('wrong_questions_title')),
      ),
      body: Column(
        children: [
          // 領域篩選器
          if (domains.isNotEmpty)
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(context.tr('all_domains')),
                      selected: wrongCtrl.selectedDomainFilter == null ||
                          wrongCtrl.selectedDomainFilter == 'ALL',
                      onSelected: (_) => wrongCtrl.setDomainFilter('ALL'),
                    ),
                  ),
                  ...domains.map((domain) {
                    final isSelected = wrongCtrl.selectedDomainFilter == domain;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(domain),
                        selected: isSelected,
                        onSelected: (_) => wrongCtrl.setDomainFilter(domain),
                      ),
                    );
                  }),
                ],
              ),
            ),

          const Divider(height: 1),

          // 錯題列表
          Expanded(
            child: questions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 64, color: AppColors.correctGreen),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('no_wrong_questions'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: questions.length,
                    itemBuilder: (ctx, idx) {
                      final item = questions[idx];
                      final q = item.cachedQuestion;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: item.isMastered
                                ? AppColors.correctGreen.withValues(alpha: 0.5)
                                : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.incorrectRed.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      context.tr('wrong_count_label', args: {'count': '${item.wrongCount}'}),
                                      style: const TextStyle(
                                        color: AppColors.incorrectRed,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.topic,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      item.isMastered ? Icons.check_circle : Icons.radio_button_unchecked,
                                      color: item.isMastered ? AppColors.correctGreen : Colors.grey,
                                      size: 22,
                                    ),
                                    tooltip: context.tr('mark_as_mastered'),
                                    onPressed: () => wrongCtrl.toggleMastered(item.questionId),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                q?.title ?? '考題 ID: ${item.questionId}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                              ),
                              if (q != null) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '💡 正確答案: ${q.correctAnswer.map((i) => String.fromCharCode(65 + i)).join(", ")}',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.correctGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  q.explanationZhTw ?? q.explanation,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (q != null)
                                    TextButton.icon(
                                      icon: const Icon(Icons.psychology, size: 16),
                                      label: const Text('請 AI 助教解析', style: TextStyle(fontSize: 12)),
                                      onPressed: () {
                                        final aiCtrl = context.read<AiTutorController>();
                                        aiCtrl.explainQuestion(q);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(builder: (_) => const AiTutorScreen()),
                                        );
                                      },
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
                                    onPressed: () => wrongCtrl.removeWrongQuestion(item.questionId),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
