import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/exam_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/exam_subject.dart';
import '../practice/practice_screen.dart';
import '../mock_exam/mock_exam_screen.dart';
import '../notebooklm/notebooklm_screen.dart';
import '../admin/question_editor_screen.dart';

class SubjectDetailScreen extends StatelessWidget {
  final ExamSubject subject;

  const SubjectDetailScreen({super.key, required this.subject});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthController>();
    final examCtrl = context.watch<ExamController>();
    final user = auth.currentUser;
    final canManageThisSubject = subject.canEdit(currentUid: user?.uid, isAdmin: user?.isAdmin ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text(subject.code),
        actions: [
          if (canManageThisSubject && !subject.isOfficial)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: '刪除此自訂科目',
              onPressed: () => _confirmDeleteSubject(context, examCtrl, user?.uid ?? ''),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 建立者 / 管理員出題管理專區
          if (canManageThisSubject)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_note, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.isOwner(user?.uid) ? '⭐ 您是本科目的建立者' : '👑 系統管理員權限',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const Text(
                          '您可以在本科目下自由新增、編修考題，供全體學員練習',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('新增考題'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => QuestionEditorScreen(
                            defaultSubjectId: subject.id,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          // 頂部資訊卡片
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        subject.category,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${subject.totalQuestions}+ 考題庫',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  subject.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  subject.description,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                // 建立者標籤
                Row(
                  children: [
                    Icon(
                      subject.isOfficial ? Icons.verified : Icons.account_circle,
                      size: 15,
                      color: subject.isOfficial ? AppColors.primary : Colors.teal,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      subject.isOfficial
                          ? '原廠官方認證科目 (Cisco Official)'
                          : '建立者：${subject.creatorName ?? "社群學員"} ${subject.isOwner(user?.uid) ? "(您建立的)" : ""}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: subject.isOfficial ? AppColors.primary : Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 核心操作按鈕
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: Text(context.tr('start_practice')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    final examCtrl = context.read<ExamController>();
                    examCtrl.selectSubject(subject);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PracticeScreen(subjectId: subject.id),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.timer_outlined),
                  label: Text(context.tr('start_mock_exam')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MockExamScreen(subjectId: subject.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // NotebookLM 工作區入口
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(Icons.auto_stories, color: AppColors.secondary),
              label: Text(
                '進入 ${subject.code} NotebookLM 官方教材學習區',
                style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NotebookLMScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // 官方大綱與領域 Domains 清單
          const Text(
            '官方考科領域涵蓋大綱 (Official Exam Domains)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          ...subject.domains.map((domain) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      domain,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
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

  void _confirmDeleteSubject(BuildContext context, ExamController examCtrl, String currentUid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('刪除自訂考試科目'),
        content: Text('確定要永久刪除【${subject.code} ${subject.title}】及其相關考題嗎？此動作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await examCtrl.deleteCustomSubject(
                  subject.id,
                  currentUserId: currentUid,
                  isAdmin: false,
                );
                if (context.mounted) {
                  Navigator.pop(context); // 回到科目列表
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已刪除科目【${subject.code}】')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                  );
                }
              }
            },
            child: const Text('確定刪除'),
          ),
        ],
      ),
    );
  }
}
