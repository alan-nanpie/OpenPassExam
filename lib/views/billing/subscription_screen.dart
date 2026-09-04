import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/billing_controller.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final billingCtrl = context.watch<BillingController>();
    final authCtrl = context.watch<AuthController>();
    final user = authCtrl.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('subscription_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 頂部尊爵大標題
          Center(
            child: Column(
              children: [
                const Icon(Icons.workspace_premium, color: AppColors.warning, size: 56),
                const SizedBox(height: 10),
                Text(
                  context.tr('subscription_title'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('subscription_subtitle'),
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 會員權益勾選清單
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: const Column(
              children: [
                _BenefitRow(text: '✨ 完整解鎖 18+ Cisco 專業科目（5,000+ 原廠高精度題庫）'),
                _BenefitRow(text: '🤖 無限調度 Google Gemini 3.8 Flash 思考推理'),
                _BenefitRow(text: '☁️ NotebookLM 學習工作區直連 GCS 6,688 官方教科書精華切片'),
                _BenefitRow(text: '📱 端側 Gemma 4 (2B) 4096 Tokens 離線無限制長篇深度教學'),
                _BenefitRow(text: '🎧 支援語音有聲書自動導讀與通勤聽題模式'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 狀態提示
          if (billingCtrl.statusMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                billingCtrl.statusMessage!,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),

          if (user?.isPro ?? false)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.correctGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.correctGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.correctGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      context.tr('active_subscription', args: {
                        'date': user?.subscriptionExpiry?.toIso8601String().substring(0, 10) ?? '永久',
                      }),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.correctGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 方案清單
          ...billingCtrl.products.map((p) {
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            p.price,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: billingCtrl.isProcessing ? null : () => billingCtrl.subscribe(p.id),
                      child: const Text('訂閱'),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),

          // 恢復購買按鈕
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.restore),
              label: Text(context.tr('restore_purchases')),
              onPressed: billingCtrl.isProcessing ? null : () => billingCtrl.restorePurchases(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;

  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
