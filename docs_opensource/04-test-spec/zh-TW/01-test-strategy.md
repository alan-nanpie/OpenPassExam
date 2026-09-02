# 測試策略規範 (Test Strategy)

## 1. 測試金字塔
- **單元測試 (70%)**: Models、Services、Controllers、Repositories 及 Utils。
- **元件測試 (Widget Tests, 20%)**: UI 元件與畫面渲染。
- **整合/端到端測試 (10%)**: 驗證跨服務流程 (Firebase 模擬器、Google Play Billing 測試環境)。

## 2. 工具鏈
- `flutter_test`: 單元與元件測試。
- `mockito` / `mocktail`: 依賴模擬。
- `integration_test`: E2E 整合測試。
- `firebase_emulator_suite`: 本機 Firebase Auth、Firestore 與 RTDB 測試。

## 3. 測試環境
- **Mock Firestore 注入**: 使用 `fake_cloud_firestore` 進行資料庫操作驗證。
- **Google Play Billing Sandbox**: 使用 Google Play 授權測試者帳號驗證訂閱流程。
