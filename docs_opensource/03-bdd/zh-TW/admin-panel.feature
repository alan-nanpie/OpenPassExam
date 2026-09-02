Feature: 管理員控制台與 AI 模型配置管理
  身為系統管理員，
  我想管理考題審核、調度 AI 模型與配置全域規則，
  以確保題庫品質與 AI 助教的最佳表現。

  Background:
    Given 使用者已登入且具有「admin」角色
    And 使用者導覽至管理員控制台

  Scenario: 檢視待審核考題清單
    When 管理員點擊「考題審核」
    Then 顯示 Cloud Firestore 中所有 `isApproved` 為 false 的考題清單

  Scenario: 一鍵批次審核所有考題 (Approve All)
    Given 存在待審核考題
    When 管理員點擊「全部核准 (Approve All)」
    Then 所有考題的 `isApproved` 狀態更新為 true
    And 同步更新 Firebase RTDB `approvedKeys` 索引節點

  Scenario: 在 AI 模型與 Remote Config 管理介面切換主力模型
    When 管理員開啟「AI 模型與 Remote Config 管理」
    And 將主力模型切換為 `gemini-3.7-flash`
    And 設定 Temperature 為 1.0
    And 點擊「發布配置」
    Then 全域 Firebase Remote Config 與 RTDB 廣播節點同步更新
