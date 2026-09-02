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
        title: const Text('個人帳號與裝置管理'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 使用者基本資訊卡片
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.displayName ?? 'Guest User',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

          // 角色與裝置綁定
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
                _buildInfoRow('目前角色 (Role)', user?.role.nameString ?? 'guest'),
                const Divider(height: 20),
                _buildInfoRow('綁定裝置 ID (Active Device)', user?.activeDeviceId ?? 'dev_unknown'),
                const Divider(height: 20),
                _buildInfoRow(
                  'Pro 會員到期日',
                  user?.subscriptionExpiry?.toIso8601String().substring(0, 10) ?? '無有效訂閱',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 角色切換 (測試用 RBAC)
          Text(
            context.tr('switch_role'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 8,
            children: UserRole.values.map((r) {
              final isCurrent = user?.role == r;
              return ChoiceChip(
                label: Text(r.nameString),
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

          // 登出按鈕
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
      ],
    );
  }
}
