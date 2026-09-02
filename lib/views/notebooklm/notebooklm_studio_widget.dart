import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/study_artifact.dart';

class NotebookLMStudioWidget extends StatelessWidget {
  final StudioToolType selectedTool;
  final Function(StudioToolType) onToolSelected;

  const NotebookLMStudioWidget({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'NotebookLM 5+1 大 Studio 產出工具',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.3,
          children: StudioToolType.values.map((tool) {
            final isSelected = selectedTool == tool;
            return InkWell(
              onTap: () => onToolSelected(tool),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : (isDark ? AppColors.darkCard : AppColors.lightCard),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    width: isSelected ? 1.8 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getIcon(tool),
                      color: isSelected ? AppColors.primary : Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getShortLabel(tool),
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : null,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getIcon(StudioToolType type) {
    switch (type) {
      case StudioToolType.studyGuide:
        return Icons.menu_book;
      case StudioToolType.faq:
        return Icons.help_outline;
      case StudioToolType.briefing:
        return Icons.summarize;
      case StudioToolType.timeline:
        return Icons.timeline;
      case StudioToolType.cheatSheet:
        return Icons.code;
      case StudioToolType.custom:
        return Icons.auto_awesome;
    }
  }

  String _getShortLabel(StudioToolType type) {
    switch (type) {
      case StudioToolType.studyGuide:
        return '研讀指南';
      case StudioToolType.faq:
        return '考點 FAQ';
      case StudioToolType.briefing:
        return '架構簡介';
      case StudioToolType.timeline:
        return '演進時間軸';
      case StudioToolType.cheatSheet:
        return 'CLI 速查表';
      case StudioToolType.custom:
        return '自訂產出';
    }
  }
}
