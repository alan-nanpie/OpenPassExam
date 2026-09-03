import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/exam_controller.dart';
import '../../data/models/exam_subject.dart';

class CreateSubjectDialog extends StatefulWidget {
  final ExamController examController;
  final AuthController authController;

  const CreateSubjectDialog({
    super.key,
    required this.examController,
    required this.authController,
  });

  static Future<bool?> show(
    BuildContext context, {
    required ExamController examController,
    required AuthController authController,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateSubjectDialog(
        examController: examController,
        authController: authController,
      ),
    );
  }

  @override
  State<CreateSubjectDialog> createState() => _CreateSubjectDialogState();
}

class _CreateSubjectDialogState extends State<CreateSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController(text: 'AWS-SAA-C03');
  final _titleController = TextEditingController(text: 'AWS Certified Solutions Architect - Associate');
  final _categoryController = TextEditingController(text: 'Cloud / AWS');
  final _descController = TextEditingController(text: '針對 AWS 雲端解決方案架構師認證，涵蓋運算、存儲、資料庫、安全與高可用架構設計。');
  final _domainsController = TextEditingController(text: '1.0 彈性架構設計, 2.0 高效能架構, 3.0 安全應用程式, 4.0 成本優化架構');
  
  String _selectedIcon = 'cloud';
  bool _isSubmitting = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'cloud', 'icon': Icons.cloud, 'label': '雲端'},
    {'name': 'router', 'icon': Icons.router, 'label': '網路'},
    {'name': 'security', 'icon': Icons.security, 'label': '資安'},
    {'name': 'code', 'icon': Icons.code, 'label': '程式'},
    {'name': 'school', 'icon': Icons.school, 'label': '學術'},
    {'name': 'language', 'icon': Icons.language, 'label': '語言'},
    {'name': 'business', 'icon': Icons.business_center, 'label': '商管'},
  ];

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _categoryController.dispose();
    _descController.dispose();
    _domainsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentUser = widget.authController.currentUser;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_box_outlined, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('建立全新考試科目', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('自由建立各專業證照、語言或課業考科', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ],
                ),
                const Divider(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 建立者標籤
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        '出題建立者：${currentUser?.displayName ?? "匿名學員"} (${currentUser?.email ?? ""})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 科目代碼與分類
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: TextFormField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: '考科代碼 *',
                          hintText: '例: AWS-SAA-C03',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? '請輸入考科代碼' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 5,
                      child: TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(
                          labelText: '領域分類 *',
                          hintText: '例: Cloud / 雲端架構',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        validator: (val) => val == null || val.trim().isEmpty ? '請輸入分類' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 科目完整名稱
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '考試科目全名 *',
                    hintText: '例: AWS Certified Solutions Architect - Associate',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? '請輸入科目名稱' : null,
                ),
                const SizedBox(height: 14),

                // 科目簡介
                TextFormField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: '科目大綱簡述',
                    hintText: '請簡述此考科適合的對象與考核重點...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 14),

                // 考核領域 / 章節
                TextFormField(
                  controller: _domainsController,
                  decoration: const InputDecoration(
                    labelText: '考核章節或領域 (以逗號分隔)',
                    hintText: '例: 1.0 基礎, 2.0 架構設計, 3.0 資安',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),

                // 圖示選擇
                const Text('選擇考科代表圖示：', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: _availableIcons.map((item) {
                    final isSelected = _selectedIcon == item['name'];
                    return ChoiceChip(
                      avatar: Icon(item['icon'] as IconData, size: 16),
                      label: Text(item['label'] as String),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedIcon = item['name'] as String);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // 操作按鈕
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: _isSubmitting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.cloud_upload_outlined, size: 18),
                      label: const Text('建立考試科目'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: _isSubmitting ? null : _handleCreateSubject,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleCreateSubject() async {
    if (!_formKey.currentState!.validate()) return;

    final user = widget.authController.currentUser;
    if (user == null || user.isGuest) {
      setState(() => _errorMessage = '請先以 Google 帳號登入後再建立自訂考試科目。');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final code = _codeController.text.trim();
      final title = _titleController.text.trim();
      final category = _categoryController.text.trim();
      final desc = _descController.text.trim();
      final domainsRaw = _domainsController.text.trim();

      final domains = domainsRaw.isNotEmpty
          ? domainsRaw.split(RegExp(r'[,，]')).map((d) => d.trim()).where((d) => d.isNotEmpty).toList()
          : <String>['1.0 綜合考核領域'];

      final customSubject = ExamSubject(
        id: 'subject_${code.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_${DateTime.now().millisecondsSinceEpoch}',
        code: code,
        title: title,
        category: category,
        description: desc,
        totalQuestions: 0,
        domains: domains,
        iconName: _selectedIcon,
        isPopular: false,
        creatorId: user.uid,
        creatorName: user.displayName,
      );

      await widget.examController.addCustomSubject(
        customSubject,
        currentUserId: user.uid,
        isAdmin: user.isAdmin,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 成功建立考試科目【$code $title】！您現在可以開始出題了。'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }
}
