Feature: 考題多欄位與語意向量搜尋
  身為考生，
  我想透過關鍵字或語意概念搜尋考題，
  以快速找出相關知識點。

  Scenario: 執行 Vertex AI 768 維度語意向量搜尋
    When 考生輸入「廣域網線路故障排除」
    Then 系統透過 Vertex AI Vector Search 檢索出高相似度之 Cisco 考題
