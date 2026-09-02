Feature: 使用者身分驗證與裝置綁定
  身為使用者，
  我想透過 Google 帳號登入並維持安全的裝置連線，
  以保護個人學習進度與訂閱權益。

  Scenario: 透過 Google 帳號登入
    Given 使用者開啟登入畫面
    When 使用者點擊「使用 Google 帳號登入」
    And 完成 Google 授權驗證
    Then Firebase Authentication 成功驗證使用者身分
    And 載入使用者設定檔

  Scenario: 單一裝置綁定安全檢查
    Given 使用者已在裝置 A 登入
    When 使用者嘗試在裝置 B 登入相同帳號
    Then 系統偵測到 `activeDeviceId` 變更並提示重新綁定
