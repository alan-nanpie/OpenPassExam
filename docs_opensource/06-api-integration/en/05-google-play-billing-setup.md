# Google Play Billing Setup Guide

## 1. Account & Google Play Console Setup
PassExam uses native Google Play Billing (Play Billing Library 6+) for standardized in-app purchases and subscriptions:
- Navigate to the [Google Play Console](https://play.google.com/console).
- Under "Monetization ➔ Products ➔ Subscriptions", configure your subscription tiers:
  - `passexam_pro_monthly`: 1-month PassExam Pro subscription
  - `passexam_pro_quarterly`: 3-month PassExam Pro quarterly pass
  - `passexam_pro_annual`: 1-year PassExam Pro annual pass
- Set up Real-Time Developer Notifications (RTDN) linked to a Google Cloud Pub/Sub topic for automated backend status sync.

## 2. SDK Installation
### pubspec.yaml Dependencies
```yaml
dependencies:
  in_app_purchase: ^3.2.0
  in_app_purchase_android: ^0.3.6
```

## 3. Code Integration
```dart
import 'package:in_app_purchase/in_app_purchase.dart';

class PlayBillingService {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  void initialize() {
    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdates,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Purchase Stream Error: $error'),
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
    // Verify purchase token with Google Play Developer API via Firebase Functions
  }
}
```

## 4. Restoring Purchases
```dart
Future<void> restorePurchases() async {
  await InAppPurchase.instance.restorePurchases();
}
```

## 5. Required Environment Variables
| Variable | Description |
|---|---|
| `PLAY_BILLING_PUBSUB_TOPIC` | Google Cloud Pub/Sub topic for RTDN notifications |
| `GOOGLE_APPLICATION_CREDENTIALS` | Service account JSON with Play Developer API access |

## 6. Troubleshooting
- **Empty Product Query**: Ensure a signed AAB bundle with `com.android.vending.BILLING` permission is uploaded to Internal Testing and tester accounts are registered.
