import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/exam_subjects_data.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/admin_controller.dart';

class QuestionApprovalScreen extends StatefulWidget {
  const QuestionApprovalScreen({super.key});

  @override
  State<QuestionApprovalScreen> createState() => _QuestionApprovalScreenState();
}

class _QuestionApprovalScreenState extends State<QuestionApprovalScreen> {
  String _selectedSubject = 'cisco-200-301';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().loadPendingQuestions(_selectedSubject);
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminCtrl = context.watch<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 科目選擇與一鍵核准列
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                decoration: InputDecoration(
                  labelText: context.tr('select_subject'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: ExamSubjectsData.allSubjects.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text('${s.code} - ${s.title}', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedSubject = val);
                    adminCtrl.loadPendingQuestions(val);
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.done_all),
              label: Text(context.tr('approve_all')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.correctGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onPressed: () => adminCtrl.approveAll(_selectedSubject),
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (adminCtrl.statusMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.correctGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              adminCtrl.statusMessage!,
              style: const TextStyle(color: AppColors.correctGreen, fontWeight: FontWeight.bold),
            ),
          ),

        if (adminCtrl.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (adminCtrl.pendingQuestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline, size: 54, color: AppColors.correctGreen),
                const SizedBox(height: 12),
                Text(
                  '該考科無待審核題目（已全數核准）',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...adminCtrl.pendingQuestions.map((q) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(q.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('領域: ${q.topic} • 題型: ${q.type}'),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    adminCtrl.saveQuestion(
                      subjectId: _selectedSubject,
                      question: q.copyWith(isApproved: true),
                    );
                  },
                  child: const Text('核准'),
                ),
              ),
            );
          }),
      ],
    );
  }
}
