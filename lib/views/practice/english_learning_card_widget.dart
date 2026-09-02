import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EnglishLearningCardWidget extends StatelessWidget {
  final String? englishNotes;

  const EnglishLearningCardWidget({super.key, required this.englishNotes});

  @override
  Widget build(BuildContext context) {
    if (englishNotes == null || englishNotes!.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B2A38) : const Color(0xFFEBF3FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.language, color: AppColors.primary, size: 18),
              SizedBox(width: 8),
              Text(
                '從考題學專業英文與關鍵術語 (English Learning Focus)',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            englishNotes!,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
