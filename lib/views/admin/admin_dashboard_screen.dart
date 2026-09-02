import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import 'question_approval_screen.dart';
import 'question_editor_screen.dart';
import 'ai_config_management_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr('admin_title')),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            tabs: [
              Tab(
                icon: const Icon(Icons.verified_user_outlined),
                text: context.tr('tab_questions_approval'),
              ),
              Tab(
                icon: const Icon(Icons.edit_document),
                text: context.tr('tab_question_editor'),
              ),
              Tab(
                icon: const Icon(Icons.settings_suggest_outlined),
                text: context.tr('tab_ai_config'),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            QuestionApprovalScreen(),
            QuestionEditorScreen(),
            AiConfigManagementScreen(),
          ],
        ),
      ),
    );
  }
}
