import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/app_user.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('個人帳號與角色權限'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 使用者基本資訊卡片
          Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        (user?.displayName.isNotEmpty ?? false)
                            ? user!.displayName.characters.first
                            : 'G',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ),
                    if (user?.isGoogleUser ?? false)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4285F4),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('G', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user?.displayName ?? 'Guest User',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (user?.role == UserRole.admin)
                            ? Colors.red.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user?.role.labelZhTw ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: (user?.role == UserRole.admin) ? Colors.red : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'guest@passexam.app',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 帳號認證與裝置資訊卡片
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('身分驗證提供者', user?.isGoogleUser ?? false ? 'Google 帳號 (Google Identity)' : '訪客未綁定'),
                const Divider(height: 20),
                _buildInfoRow('使用者專屬 UID', user?.uid ?? 'guest'),
                const Divider(height: 20),
                _buildInfoRow('綁定授權裝置 ID', user?.activeDeviceId ?? 'dev_unknown'),
                const Divider(height: 20),
                _buildInfoRow(
                  'Pro 會員有效期間',
                  user?.subscriptionExpiry != null
                      ? user!.subscriptionExpiry!.toIso8601String().substring(0, 10)
                      : '無有效付費訂閱 (基礎版)',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 角色權限控管矩陣 (RBAC Matrix)
          const Text('目前角色權限清單 (RBAC Permissions)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: Column(
              children: [
                _buildPermissionItem('建立自訂考試科目 (UGC)', user?.canCreateSubject ?? false),
                _buildPermissionItem('各考科自由出題與考題 CRUD', user?.canCreateQuestion ?? false),
                _buildPermissionItem('Gemini 3.8 / 離線 AI 完整導師', user?.canAccessAiTutor ?? false),
                _buildPermissionItem('全真計時模擬考試模式', user?.canAccessMockExam ?? false),
                _buildPermissionItem('考題討論區交流與發言', user?.canComment ?? false),
                _buildPermissionItem('系統管理員全站管理權限', user?.canManageSystem ?? false),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 角色切換 (測試與權限調整)
          Text(
            context.tr('switch_role'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: UserRole.values.map((r) {
              final isCurrent = user?.role == r;
              return ChoiceChip(
                label: Text(r.labelZhTw, style: const TextStyle(fontSize: 12)),
                selected: isCurrent,
                onSelected: (selected) {
                  if (selected) {
                    auth.switchRole(r);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // 登入 / 登出按鈕
          if (user?.isGuest ?? true)
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('立即以 Google 帳號登入'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            )
          else
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: Text(
                  context.tr('logout'),
                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionItem(String label, bool isGranted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.cancel_outlined,
            size: 18,
            color: isGranted ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isGranted ? null : Colors.grey,
                fontWeight: isGranted ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            isGranted ? '已啟用' : '未解鎖',
            style: TextStyle(
              fontSize: 11,
              color: isGranted ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
