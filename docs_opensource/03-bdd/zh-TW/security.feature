Feature: 三位一體安全矩陣與防竄改防護
  身為系統擁有者，
  我想防止考題資料遭外流或竄改，
  以維護題庫的智慧財產權與公信力。

  Scenario: 原生層 FLAG_SECURE 防截圖
    When 考生開啟測驗畫面
    Then Android 原生層啟用 `FLAG_SECURE`
    And 系統阻止截圖與螢幕錄影

  Scenario: NTP 網路時間防作弊驗證
    When 考生提交模擬考成績
    Then 系統比對 NTP 伺服器時間以防竄改本機時鐘
