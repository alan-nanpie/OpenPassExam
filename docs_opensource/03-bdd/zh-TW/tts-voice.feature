Feature: 語音朗讀與無障礙導讀
  身為考生，
  我想使用語音朗讀考題與詳解，
  以進行聽覺輔助複習。

  Scenario: 朗讀考題文字
    When 考生點擊「語音朗讀」
    Then 系統調用 Text-to-Speech 朗讀題目與選項
