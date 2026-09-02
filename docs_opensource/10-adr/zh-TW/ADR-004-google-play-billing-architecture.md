# ADR-004: Google Play Billing 原生帳單與訂閱架構 (Google Play Billing Architecture)
## 狀態: 已接受 (Accepted)
## 日期: 2026-09-01
## 背景 (Context)
PassExam 提供進階模擬考、無限 AI 解題與專屬題庫訂閱，需採用合規、穩定且低延遲的官方支付系統。

## 決策 (Decision)
全面採用 Google Play Billing 原生帳單架構（Play Billing Library 6+），搭配 Google Cloud Pub/Sub 與 Firebase Cloud Functions 進行伺服器端驗證：
1. **客戶端整合**: 使用 Flutter 官方 `in_app_purchase` 套件，直連 Google Play 官方結帳流程。
2. **即時狀態同步 (RTDN)**: 透過 Google Cloud Pub/Sub 接收 Google Play 即時開發者通知，即時開通或變更使用者訂閱權益。
3. **後端收據驗證**: 透過 Firebase Cloud Functions 調用 Google Play Developer API 進行安全防偽驗證。

## 考慮過的替代方案 (Alternatives Considered)
- **第三方聚合支付閘道**:
  - 缺點：增加額外廠商抽成與依賴、網頁端存在數位商品合規風險。
- **Google Play Billing 原生帳單系統 (最終方案)**:
  - 優點：100% 符合 Google Play 政策、無第三方服務費、與 Google Cloud 生態完美整合。

## 後果 (Consequences)
- **正面影響**: 零第三方支付相依、極致的交易安全性與官方技術支援。
