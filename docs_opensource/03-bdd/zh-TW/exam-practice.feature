Feature: 多科目考試練習與上下分屏圖文對照
  身為考生，
  我想在練習考題時對照拓撲圖並在離線時正常刷題，
  以提升學習效率與理解深度。

  Scenario: 開啟上下分屏圖文對照檢視視窗
    Given 考題包含網路拓撲架構圖
    When 考生點擊「查看對照圖片」
    Then 彈出 `QuestionImageReferenceDialog` 上下分屏視窗
    And 圖片透過 `SafeImageWidget` 進行 1024 寬度降取樣渲染

  Scenario: 離線模式下無縫練習考題
    Given 裝置處於完全斷網狀態
    When 考生開啟考題練習畫面
    Then 考題自 Cloud Firestore 本地持久化快取 (Persistent Cache) 瞬間載入
    And 考生的作答紀錄暫存於本機寫入佇列中
