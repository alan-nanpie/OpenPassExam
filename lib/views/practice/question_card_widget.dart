import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/safe_image_widget.dart';
import '../../core/widgets/question_image_reference_dialog.dart';
import '../../data/models/question.dart';

class QuestionCardWidget extends StatelessWidget {
  final Question question;
  final Set<int> selectedOptions;
  final bool isSubmitted;
  final bool isCorrect;
  final Function(int) onOptionTapped;

  const QuestionCardWidget({
    super.key,
    required this.question,
    required this.selectedOptions,
    required this.isSubmitted,
    required this.isCorrect,
    required this.onOptionTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 領域考點與題型標籤
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getTypeDisplayName(question.type),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question.topic,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 題目文字
        Text(
          question.title,
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.bold,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),

        // 若有拓撲圖片，顯示 SafeImageWidget 預覽與上下分屏對照按鈕
        if (question.imageUrl != null && question.imageUrl!.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : const Color(0xFFF1F3F4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: Column(
              children: [
                SafeImageWidget(
                  imageUrl: question.imageUrl,
                  height: 180,
                  enableZoomOnClick: true,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '🔍 點擊圖片可直接手勢放大',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.splitscreen, size: 16),
                        label: const Text('上下分屏圖文對照', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          QuestionImageReferenceDialog.show(context, question);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        // 選項列表
        ...List.generate(question.options.length, (idx) {
          final isSelected = selectedOptions.contains(idx);
          final isActualCorrect = question.correctAnswer.contains(idx);
          final optChar = String.fromCharCode(65 + idx);

          Color borderColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
          Color bgColor = isDark ? AppColors.darkCard : AppColors.lightCard;

          if (isSubmitted) {
            if (isActualCorrect) {
              borderColor = AppColors.correctGreen;
              bgColor = AppColors.correctGreen.withValues(alpha: 0.12);
            } else if (isSelected && !isActualCorrect) {
              borderColor = AppColors.incorrectRed;
              bgColor = AppColors.incorrectRed.withValues(alpha: 0.12);
            }
          } else if (isSelected) {
            borderColor = AppColors.primary;
            bgColor = isDark ? AppColors.optionSelectedDark : AppColors.optionSelected;
          }

          return InkWell(
            onTap: isSubmitted ? null : () => onOptionTapped(idx),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: borderColor, width: isSelected || (isSubmitted && isActualCorrect) ? 1.8 : 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkSurface : const Color(0xFFF1F3F4)),
                    ),
                    child: Text(
                      optChar,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        question.options[idx],
                        style: const TextStyle(fontSize: 14.5, height: 1.35),
                      ),
                    ),
                  ),
                  if (isSubmitted) ...[
                    const SizedBox(width: 8),
                    if (isActualCorrect)
                      const Icon(Icons.check_circle, color: AppColors.correctGreen, size: 20)
                    else if (isSelected && !isActualCorrect)
                      const Icon(Icons.cancel, color: AppColors.incorrectRed, size: 20),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'SINGLE_CHOICE':
        return '單選題';
      case 'MULTIPLE_CHOICE':
        return '複選題';
      case 'DRAG_DROP':
        return '拖曳配對題';
      case 'SIMULATION':
        return '實作模擬題';
      default:
        return '單選題';
    }
  }
}
