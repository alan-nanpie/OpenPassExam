import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/enhanced_security_watermark.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/exam_controller.dart';
import '../../data/models/exam_subject.dart';
import '../practice/practice_screen.dart';
import '../mock_exam/mock_exam_screen.dart';
import '../ai_tutor/ai_tutor_screen.dart';
import '../notebooklm/notebooklm_screen.dart';
import '../wrong_questions/wrong_questions_screen.dart';
import '../search/search_screen.dart';
import '../billing/subscription_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../audiobook/audiobook_player_screen.dart';
import '../auth/login_screen.dart';
import 'subject_detail_screen.dart';
import 'create_subject_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedNavIndex = 0;
  int _subjectFilterIndex = 0; // 0: 全部, 1: 官方精選, 2: 學員社群自建

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;

    final navPages = [
      _buildHomeDashboard(context),
      const WrongQuestionsScreen(),
      const AiTutorScreen(),
      const NotebookLMScreen(),
      const SettingsScreen(),
    ];

    return EnhancedSecurityWatermark(
      userId: user?.uid ?? 'guest',
      userName: user?.displayName ?? 'Guest User',
      isEnabled: true,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                context.tr('app_title'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: context.tr('nav_search'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.workspace_premium, color: AppColors.warning),
              tooltip: context.tr('nav_subscription'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                );
              },
            ),
            if (user?.isAdmin ?? false)
              IconButton(
                icon: const Icon(Icons.admin_panel_settings, color: AppColors.primary),
                tooltip: context.tr('nav_admin'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                  );
                },
              ),
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
          ],
        ),
        body: navPages[_selectedNavIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedNavIndex,
          onDestinationSelected: (idx) {
            setState(() {
              _selectedNavIndex = idx;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: context.tr('nav_home'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.cancel_presentation_outlined),
              selectedIcon: const Icon(Icons.cancel_presentation),
              label: context.tr('nav_wrong_questions'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.psychology_outlined),
              selectedIcon: const Icon(Icons.psychology),
              label: context.tr('nav_ai_tutor'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book),
              label: context.tr('nav_notebooklm'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: context.tr('nav_settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeDashboard(BuildContext context) {
    final examCtrl = context.watch<ExamController>();
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        // 裝置綁定安全提醒 Banner
        if (auth.hasDeviceConflict)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                const Icon(Icons.phonelink_lock, color: Colors.orange, size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ 偵測到帳號在其他裝置登入',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '為維護安全防護，單一帳號僅允許綁定一台設備。點擊右側以將當前設備設為唯一授權裝置。',
                        style: TextStyle(fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => auth.rebindDevice(),
                  child: const Text('重新綁定', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

        // 歡迎與橫幅 Banner
        _buildHeroBanner(context),
        const SizedBox(height: 16),

        // 快速功能卡片入口
        _buildQuickActionGrid(context),
        const SizedBox(height: 24),

        // 考試科目與社群自建專區
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('popular_subjects'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '共 ${examCtrl.allSubjects.length} 科目 (${examCtrl.officialSubjects.length} 官方 / ${examCtrl.customSubjects.length} 社群自建)',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16),
              label: const Text('自建考科', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (user == null || user.isGuest) {
                  _showLoginRequiredDialog(context);
                } else {
                  CreateSubjectDialog.show(
                    context,
                    examController: examCtrl,
                    authController: auth,
                  );
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 分類過濾 Segmented Filter
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: Text('全部科目 (${examCtrl.allSubjects.length})'),
                selected: _subjectFilterIndex == 0,
                onSelected: (val) {
                  if (val) setState(() => _subjectFilterIndex = 0);
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                avatar: const Icon(Icons.verified, size: 14, color: AppColors.primary),
                label: Text('官方認證 (${examCtrl.officialSubjects.length})'),
                selected: _subjectFilterIndex == 1,
                onSelected: (val) {
                  if (val) setState(() => _subjectFilterIndex = 1);
                },
              ),
              const SizedBox(width: 8),
              FilterChip(
                avatar: const Icon(Icons.groups, size: 14, color: Colors.teal),
                label: Text('學員自建 (${examCtrl.customSubjects.length})'),
                selected: _subjectFilterIndex == 2,
                onSelected: (val) {
                  if (val) setState(() => _subjectFilterIndex = 2);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 科目卡片列表
        if (_getFilteredSubjects(examCtrl).isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.school_outlined, size: 48, color: Colors.grey),
                  const SizedBox(height: 10),
                  const Text('目前尚無社群學員自建科目', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('成為第一個建立考科的創作者！'),
                    onPressed: () {
                      if (user == null || user.isGuest) {
                        _showLoginRequiredDialog(context);
                      } else {
                        CreateSubjectDialog.show(context, examController: examCtrl, authController: auth);
                      }
                    },
                  ),
                ],
              ),
            ),
          )
        else
          ..._getFilteredSubjects(examCtrl).map((subject) {
            final isSelected = examCtrl.currentSubjectId == subject.id;
            return _buildSubjectCard(context, subject, isSelected);
          }),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1557B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.warning, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Gemini 3.7 Dynamic Thinking 思考推理',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '全方位制霸 Cisco 專業認證',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '支援 CCNA 與 18+ CCNP 考科、上下分屏拓撲圖文對照與 GCS 官方教科書 RAG 知識庫。',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            context,
            title: context.tr('nav_practice'),
            subtitle: '多題型刷題',
            icon: Icons.edit_document,
            color: AppColors.primary,
            onTap: () {
              final examCtrl = context.read<ExamController>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PracticeScreen(
                    subjectId: examCtrl.currentSubjectId,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            context,
            title: context.tr('nav_mock_exam'),
            subtitle: '全真計時測驗',
            icon: Icons.timer,
            color: AppColors.secondary,
            onTap: () {
              final examCtrl = context.read<ExamController>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MockExamScreen(
                    subjectId: examCtrl.currentSubjectId,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildActionTile(
            context,
            title: '有聲書',
            subtitle: '語音聽讀導讀',
            icon: Icons.headphones,
            color: const Color(0xFF8E24AA),
            onTap: () {
              final examCtrl = context.read<ExamController>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AudiobookPlayerScreen(
                    subjectId: examCtrl.currentSubjectId,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              radius: 20,
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, ExamSubject subject, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SubjectDetailScreen(subject: subject),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkSurface : const Color(0xFFE8F0FE)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getSubjectIcon(subject.iconName),
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            subject.code,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (subject.isPopular)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '🔥 熱門',
                              style: TextStyle(
                                color: Color(0xFFB06000),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        if (!subject.isOfficial) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '🌐 ${subject.creatorName ?? "學員自建"}',
                              style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  List<ExamSubject> _getFilteredSubjects(ExamController examCtrl) {
    if (_subjectFilterIndex == 1) {
      return examCtrl.officialSubjects;
    } else if (_subjectFilterIndex == 2) {
      return examCtrl.customSubjects;
    }
    return examCtrl.allSubjects;
  }

  IconData _getSubjectIcon(String iconName) {
    switch (iconName) {
      case 'cloud':
        return Icons.cloud;
      case 'security':
        return Icons.security;
      case 'code':
        return Icons.code;
      case 'school':
        return Icons.school;
      case 'language':
        return Icons.language;
      case 'business':
        return Icons.business_center;
      case 'router':
      default:
        return Icons.router;
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('需以 Google 帳號登入'),
          ],
        ),
        content: const Text('自訂建立考試科目與出題為 Google 帳號創作者專屬功能。請登入您的 Google 帳號以解鎖出題、社群討論與完整題庫權限！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('稍後再說'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('前往 Google 登入'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
