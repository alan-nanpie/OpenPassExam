import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/app_user.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo 標誌
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: AppColors.primary,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 標題與副標題
                  Text(
                    context.tr('app_title'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.tr('app_subtitle'),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // 登入按鈕區
                  if (auth.isLoading)
                    const CircularProgressIndicator()
                  else ...[
                    // 官方風格 Google 登入按鈕 (Google Identity Services)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF131314) : Colors.white,
                          foregroundColor: isDark ? Colors.white : const Color(0xFF1F1F1F),
                          elevation: 1,
                          side: BorderSide(
                            color: isDark ? const Color(0xFF444746) : const Color(0xFF747775),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                        ),
                        onPressed: () => _showGoogleSignInModal(context, auth),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: const Center(
                                child: Text(
                                  'G',
                                  style: TextStyle(
                                    color: Color(0xFF4285F4),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.tr('login_google'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 訪客體驗按鈕
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton.icon(
                        icon: const Icon(Icons.person_outline, size: 20),
                        label: Text(
                          context.tr('login_guest'),
                          style: const TextStyle(fontSize: 14),
                        ),
                        onPressed: () async {
                          await auth.loginAsGuest();
                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // 底部宣告
                  Text(
                    '支援 Android 15/16 Edge-to-Edge 與純 Google 雲端生態系',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showGoogleSignInModal(BuildContext context, AuthController auth) {
    final emailController = TextEditingController(text: 'alan.nanpie@gmail.com');
    final nameController = TextEditingController(text: 'Alan (Google 認證出題者)');
    UserRole selectedRole = UserRole.creator;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF4285F4),
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '使用 Google 帳號登入',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '以 Google 帳號登入後，您將自動享有創作者權限，可自由建立各考試科目與各考題！',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey),
                  ),
                  const SizedBox(height: 18),

                  // 快速預設帳號選擇
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.account_circle, size: 16),
                        label: const Text('Alan Chen (alan.nanpie@gmail.com)', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          setModalState(() {
                            emailController.text = 'alan.nanpie@gmail.com';
                            nameController.text = 'Alan Chen (出題專家)';
                            selectedRole = UserRole.creator;
                          });
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.verified_user, size: 16),
                        label: const Text('管理員 (admin@gmail.com)', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          setModalState(() {
                            emailController.text = 'admin.pass@gmail.com';
                            nameController.text = '系統管理員 (Admin)';
                            selectedRole = UserRole.admin;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Google 電子郵件帳號 (Gmail / Workspace)',
                      hintText: 'example@gmail.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: '學員 / 創作者顯示暱稱 (Display Name)',
                      hintText: '您的真實姓名或暱稱',
                      prefixIcon: Icon(Icons.badge_outlined),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 初始角色權限
                  Row(
                    children: [
                      const Text('賦予帳號權限：', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      DropdownButton<UserRole>(
                        value: selectedRole,
                        isDense: true,
                        items: const [
                          DropdownMenuItem(
                            value: UserRole.creator,
                            child: Text('✍️ 出題創作者 (可自由新增科目與考題)'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.admin,
                            child: Text('👑 系統管理員 (具全站最高管控審核權)'),
                          ),
                          DropdownMenuItem(
                            value: UserRole.viewer,
                            child: Text('🎓 備考學員 (僅刷題與討論)'),
                          ),
                        ],
                        onChanged: (role) {
                          if (role != null) {
                            setModalState(() => selectedRole = role);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('確認登入並進入題庫', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final email = emailController.text.trim();
                        final name = nameController.text.trim();
                        if (email.isEmpty) return;

                        Navigator.pop(ctx);
                        await auth.loginWithGoogle(
                          email: email,
                          displayName: name.isNotEmpty ? name : email.split('@').first,
                          role: selectedRole,
                        );

                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
