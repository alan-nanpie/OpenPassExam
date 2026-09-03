import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_localizations.dart';
import '../../controllers/admin_controller.dart';

class AiConfigManagementScreen extends StatefulWidget {
  const AiConfigManagementScreen({super.key});

  @override
  State<AiConfigManagementScreen> createState() => _AiConfigManagementScreenState();
}

class _AiConfigManagementScreenState extends State<AiConfigManagementScreen> {
  late TextEditingController _primaryModelController;
  late TextEditingController _fallbackModelController;
  late TextEditingController _onDeviceModelController;
  late double _temperature;
  late int _maxTokens;
  late int _thinkingBudget;
  late bool _preferOffline;

  @override
  void initState() {
    super.initState();
    final adminCtrl = context.read<AdminController>();
    final cfg = adminCtrl.currentEditableAiConfig;

    _primaryModelController = TextEditingController(text: cfg.primaryModel);
    _fallbackModelController = TextEditingController(text: cfg.fallbackModel);
    _onDeviceModelController = TextEditingController(text: cfg.onDeviceModel);
    _temperature = cfg.temperature;
    _maxTokens = cfg.maxTokens;
    _thinkingBudget = cfg.thinkingBudget;
    _preferOffline = cfg.preferOffline;
  }

  @override
  void dispose() {
    _primaryModelController.dispose();
    _fallbackModelController.dispose();
    _onDeviceModelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminCtrl = context.watch<AdminController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 說明卡片
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.hub, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    '四層階層式 AI 調度架構',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '1. 本機覆寫 ➔ 2. Firebase RTDB 廣播 ➔ 3. Firebase Remote Config ➔ 4. 內建預設值\n'
                '管理員可在此直接動態下發新模型代號，無需重新發布 Google Play 應用程式！',
                style: TextStyle(fontSize: 12.5, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

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

        // 主力雲端模型 (第二優先)
        TextFormField(
          controller: _primaryModelController,
          decoration: const InputDecoration(
            labelText: '雲端主力 AI 模型 (第 2 優先多模態)',
            hintText: 'gemini-3.8-flash',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.cloud_done),
          ),
        ),
        const SizedBox(height: 14),

        // 降級模型 (第三優先備用)
        TextFormField(
          controller: _fallbackModelController,
          decoration: const InputDecoration(
            labelText: '雲端降級備用 AI 模型 (第 3 優先主流穩定)',
            hintText: 'gemini-2.5-flash',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.backup),
          ),
        ),
        const SizedBox(height: 14),

        // 端側離線模型 (第一優先)
        TextFormField(
          controller: _onDeviceModelController,
          decoration: const InputDecoration(
            labelText: '端側離線 AI 模型 (第 1 優先 On-Device / Web Nano)',
            hintText: 'gemma-4-2b',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_android),
          ),
        ),
        const SizedBox(height: 14),

        // 離線優先調度開關
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('啟用離線模型為第 1 優先 (Prefer Offline First)', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: const Text('考題分析優先於本機端側推論，無網路時亦 100% 可用', style: TextStyle(fontSize: 12)),
          value: _preferOffline,
          onChanged: (v) => setState(() => _preferOffline = v),
        ),
        const SizedBox(height: 20),

        // 推論溫度
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('推論溫度 (Temperature):', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('$_temperature', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        Slider(
          value: _temperature,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          label: '$_temperature',
          onChanged: (v) => setState(() => _temperature = double.parse(v.toStringAsFixed(1))),
        ),
        const SizedBox(height: 10),

        // Max Tokens
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('最大輸出長度 (Max Tokens):', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('$_maxTokens', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        Slider(
          value: _maxTokens.toDouble(),
          min: 1024,
          max: 8192,
          divisions: 14,
          label: '$_maxTokens',
          onChanged: (v) => setState(() => _maxTokens = v.toInt()),
        ),
        const SizedBox(height: 10),

        // Thinking 預算
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('思考預算 (Thinking Budget Tokens):', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('$_thinkingBudget', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        Slider(
          value: _thinkingBudget.toDouble(),
          min: 512,
          max: 8192,
          divisions: 15,
          label: '$_thinkingBudget',
          onChanged: (v) => setState(() => _thinkingBudget = v.toInt()),
        ),
        const SizedBox(height: 24),

        // 操作按鈕
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.cell_tower),
            label: Text(context.tr('publish_remote_config')),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              _syncStateToAdmin();
              adminCtrl.publishToRemoteConfigAndRtdb();
            },
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.save_alt),
                label: Text(context.tr('save_local_override')),
                onPressed: () {
                  _syncStateToAdmin();
                  adminCtrl.saveAsLocalOverride();
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.clear),
                label: Text(context.tr('clear_local_override')),
                onPressed: () => adminCtrl.clearLocalOverride(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _syncStateToAdmin() {
    final adminCtrl = context.read<AdminController>();
    adminCtrl.updateEditableAiConfig(
      adminCtrl.currentEditableAiConfig.copyWith(
        primaryModel: _primaryModelController.text.trim(),
        fallbackModel: _fallbackModelController.text.trim(),
        onDeviceModel: _onDeviceModelController.text.trim(),
        temperature: _temperature,
        maxTokens: _maxTokens,
        thinkingBudget: _thinkingBudget,
        preferOffline: _preferOffline,
      ),
    );
  }
}
