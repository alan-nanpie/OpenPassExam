import 'package:flutter/material.dart';
import '../../data/models/question.dart';
import '../constants/app_colors.dart';
import 'safe_image_widget.dart';

class QuestionImageReferenceDialog extends StatelessWidget {
  final Question question;
  final String? activeExplanation;

  const QuestionImageReferenceDialog({
    super.key,
    required this.question,
    this.activeExplanation,
  });

  static void show(BuildContext context, Question question, {String? activeExplanation}) {
    showDialog(
      context: context,
      builder: (ctx) => QuestionImageReferenceDialog(
        question: question,
        activeExplanation: activeExplanation,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: size.width > 800 ? 760 : double.infinity,
        height: size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 標題列
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.splitscreen, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      '上下分屏圖文對照檢視',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 16),

            // 上下分屏內容
            Expanded(
              child: Column(
                children: [
                  // 上半部: 拓撲圖 (可手勢縮放)
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : const Color(0xFFF1F3F4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: InteractiveViewer(
                          minScale: 0.8,
                          maxScale: 3.5,
                          child: Center(
                            child: SafeImageWidget(
                              imageUrl: question.imageUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 下半部: 題目文字、選項與解析 (可捲動)
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                        ),
                      ),
                      child: ListView(
                        children: [
                          // 題目
                          Text(
                            question.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // 選項列表
                          ...List.generate(question.options.length, (idx) {
                            final isCorrect = question.correctAnswer.contains(idx);
                            final optPrefix = String.fromCharCode(65 + idx);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? AppColors.correctGreen.withValues(alpha: 0.12)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isCorrect
                                      ? AppColors.correctGreen
                                      : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$optPrefix. ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isCorrect
                                          ? AppColors.correctGreen
                                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      question.options[idx],
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  if (isCorrect)
                                    const Icon(
                                      Icons.check_circle,
                                      color: AppColors.correctGreen,
                                      size: 16,
                                    ),
                                ],
                              ),
                            );
                          }),

                          // 詳解
                          if (activeExplanation != null || question.explanation.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            const Text(
                              '💡 深入詳解：',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              activeExplanation ?? question.explanation,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.4,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
