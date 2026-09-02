Feature: 筆記與 NotebookLM 學習工作區
  身為考生，
  我想在研讀官方教材時產出研讀指南與速查表，
  以強化複習記憶。

  Scenario: 載入 GCS 官方教科書切片
    When 考生點擊「載入 Google 雲端官方 RAG 精華知識庫」
    Then 系統自 GCS 載入 6,688 個去雜訊教材切片
