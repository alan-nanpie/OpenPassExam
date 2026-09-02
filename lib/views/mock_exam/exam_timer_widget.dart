import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ExamTimerWidget extends StatelessWidget {
  final ValueNotifier<int> remainingSecondsNotifier;

  const ExamTimerWidget({
    super.key,
    required this.remainingSecondsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: remainingSecondsNotifier,
      builder: (context, seconds, _) {
        final minutes = seconds ~/ 60;
        final secs = seconds % 60;
        final formatted =
            '${minutes.toString().padLeft(2, "0")}:${secs.toString().padLeft(2, "0")}';

        final isUrgent = seconds < 300; // 5 分鐘內警告紅字

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isUrgent
                ? AppColors.incorrectRed.withValues(alpha: 0.15)
                : AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isUrgent ? AppColors.incorrectRed : AppColors.primary,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                size: 16,
                color: isUrgent ? AppColors.incorrectRed : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                formatted,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? AppColors.incorrectRed : AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
