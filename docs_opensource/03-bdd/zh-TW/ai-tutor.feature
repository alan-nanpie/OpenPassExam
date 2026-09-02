Feature: 雙 AI 助教推理與端側離線輔導
  身為考生，
  我想向 AI 助教提問並獲得生活化比喻解析與 Cisco CLI 手把手教學，
  以徹底理解網路複雜架構。

  Scenario: 連線狀態下使用 Gemini 3.7 Flash Dynamic Thinking
    Given 裝置連線正常
    When 考生向 AI 家教詢問 OSPF 虛擬鏈路概念
    Then Gemini 3.7 Flash 進行深度推理並過濾 `thought: true` 思考標記
    And 回傳深入淺出的生活化比喻解析與 Cisco CLI 指令範例

  Scenario: 離線狀態下自動調度端側 Gemma 4 (2B)
    Given 裝置處於完全斷網狀態
    When 考生請求解析目前考題
    Then 系統自動切換至端側 Gemma 4 (2B) LiteRT 模型
    And 提供 4096 tokens 完整解說且無字數截斷
