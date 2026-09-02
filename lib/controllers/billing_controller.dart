import 'package:flutter/foundation.dart';
import '../services/play_billing_service.dart';
import 'auth_controller.dart';

class BillingController extends ChangeNotifier {
  final PlayBillingService billingService;
  final AuthController authController;

  bool _isProcessing = false;
  String? _statusMessage;

  BillingController({
    required this.billingService,
    required this.authController,
  });

  bool get isProcessing => _isProcessing;
  String? get statusMessage => _statusMessage;

  List<PlayProductDetail> get products => billingService.getAvailableProducts();

  Future<bool> subscribe(String sku) async {
    _isProcessing = true;
    _statusMessage = null;
    notifyListeners();

    try {
      final success = await billingService.purchaseSubscription(sku);
      if (success) {
        await authController.initialize();
        _statusMessage = '🎉 感謝訂閱！Pro 尊爵權限已即時開通。';
      }
      return success;
    } catch (e) {
      _statusMessage = '❌ 購買失敗：$e';
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> restorePurchases() async {
    _isProcessing = true;
    _statusMessage = null;
    notifyListeners();

    try {
      final success = await billingService.restorePurchases();
      if (success) {
        await authController.initialize();
        _statusMessage = '✅ 已成功向 Google Play 恢復您的有效訂閱權益！';
      }
      return success;
    } catch (e) {
      _statusMessage = '❌ 恢復購買失敗：$e';
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
