# Google Play Billing 官方帳單與訂閱設定指南

## 1. 帳號與 Google Play Console 設定
PassExam 採用 Google Play Billing 原生官方帳單系統（Play Billing Library 6+），提供標準化的應用程式內購與訂閱管理：
- 前往 [Google Play Console](https://play.google.com/console) 建立應用程式。
- 在「營利 ➔ 產品 ➔ 訂閱」建立訂閱方案：
  - `passexam_pro_monthly`：PassExam Pro 1 個月訂閱方案
  - `passexam_pro_quarterly`：PassExam Pro 3 個月專業方案
  - `passexam_pro_annual`：PassExam Pro 1 年尊榮方案
- 在「即時開發者通知 (RTDN)」設定 Google Cloud Pub/Sub 主題，供後端即時接收續訂、取消與退款事件。

## 2. SDK 安裝
### pubspec.yaml 依賴項目
```yaml
dependencies:
  in_app_purchase: ^3.2.0
  in_app_purchase_android: ^0.3.6
```

## 3. 程式碼整合
### 初始化購買串流與產品載入
```dart
import 'package:in_app_purchase/in_app_purchase.dart';

class PlayBillingService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  void initialize() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('購買串流錯誤: $error'),
    );
  }

  Future<List<ProductDetails>> fetchProducts() async {
    const Set<String> kIds = {'passexam_pro_monthly', 'passexam_pro_quarterly', 'passexam_pro_annual'};
    final ProductDetailsResponse response = await _iap.queryProductDetails(kIds);
    return response.productDetails;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        _verifyAndDeliverProduct(purchase);
      }
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _verifyAndDeliverProduct(PurchaseDetails purchase) async {
    // 透過 Firebase Cloud Functions 呼叫 Google Play Developer API 驗證收據並開通權限
  }
}
```

## 4. 恢復購買 (Restore Purchases)
```dart
Future<void> restorePurchases() async {
  await InAppPurchase.instance.restorePurchases();
}
```

## 5. 後端驗證與 Pub/Sub 整合
- 建立 Google Cloud Pub/Sub 主題：`projects/<PROJECT_ID>/topics/play-billing-rtdn`。
- 部署 Firebase Cloud Function 監聽訂閱狀態變更並更新 Firestore `users/{uid}` 的 `role: "viewer"` 權限。

## 6. 常見問題排除
- **產品查詢為空**：確認 Google Play Console 上的應用程式已上傳含有 `BILLING` 權限的 Signed Bundle 至內部測試軌道 (Internal Testing)，且測試帳號已加入測試名單。
