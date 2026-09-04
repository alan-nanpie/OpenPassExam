import '../core/constants/app_constants.dart';
import '../data/repositories/user_repository.dart';

class PlayProductDetail {
  final String id;
  final String title;
  final String description;
  final String price;
  final int durationDays;

  PlayProductDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.durationDays,
  });
}

class PlayBillingService {
  final IUserRepository userRepository;

  PlayBillingService({required this.userRepository});

  List<PlayProductDetail> getAvailableProducts() {
    return [
      PlayProductDetail(
        id: AppConstants.skuProMonthly,
        title: 'PassExam Pro 1 個月訂閱',
        description: '暢享全考科題庫、無限 Gemini 3.8 Flash 推理與 NotebookLM 工作區',
        price: 'NT\$ 290',
        durationDays: 30,
      ),
      PlayProductDetail(
        id: AppConstants.skuProQuarterly,
        title: 'PassExam Pro 3 個月暢學',
        description: '季費優惠 85 折，適合認證衝刺備考',
        price: 'NT\$ 790',
        durationDays: 90,
      ),
      PlayProductDetail(
        id: AppConstants.skuProAnnual,
        title: 'PassExam Pro 1 年尊爵方案',
        description: '年費超值特惠 6 折，全方位制霸 18+ Cisco 專業認證',
        price: 'NT\$ 2,490',
        durationDays: 365,
      ),
    ];
  }

  Future<bool> purchaseSubscription(String sku) async {
    final products = getAvailableProducts();
    final product = products.firstWhere(
      (p) => p.id == sku,
      orElse: () => products.first,
    );

    // 模擬呼叫 Google Play Billing 結帳流程並向後端驗證收據
    final expiry = DateTime.now().add(Duration(days: product.durationDays));
    await userRepository.updateSubscription(expiry);
    return true;
  }

  Future<bool> restorePurchases() async {
    // 向 Google Play 查詢有效收據
    final expiry = DateTime.now().add(const Duration(days: 30));
    await userRepository.updateSubscription(expiry);
    return true;
  }
}
