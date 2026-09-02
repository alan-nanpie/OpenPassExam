Feature: 全真模擬考與防側錄安全防護
  身為考生，
  我想進行計時模擬考並在安全的環境下測驗，
  以評估自身實力並適應真實考場節奏。

  Scenario: 啟動 50 題計時模擬考
    When 考生選擇 50 題模擬考並點擊「開始測驗」
    Then 倒數計時器啟動並透過 `ValueListenableBuilder` 局部重繪
    And 畫面疊加 `EnhancedSecurityWatermark` 個人化防側錄浮水印
    And 原生層啟用 `FLAG_SECURE` 防截圖
