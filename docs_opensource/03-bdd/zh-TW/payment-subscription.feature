Feature: Google Play Billing 付款與訂閱管理
  身為使用者，
  我想透過 Google Play 帳單購買 Pro 訂閱，
  以解鎖無限 AI 助教解析與全科目模擬考。

  Scenario: 透過 Google Play Billing 購買 1 個月 Pro 訂閱
    Given 使用者位於訂閱升級畫面
    When 使用者選擇「1 個月 PassExam Pro」方案
    And 完成 Google Play 官方結帳流程
    Then Firebase Functions 透過 Google Play Developer API 驗證收據
    And 使用者的角色升級為「viewer」並開通權限

  Scenario: 恢復先前購買 (Restore Purchases)
    Given 使用者已在新裝置登入 Google 帳號
    When 使用者點擊「恢復購買」
    Then 應用程式向 Google Play Billing 查詢有效收據並恢復權益
