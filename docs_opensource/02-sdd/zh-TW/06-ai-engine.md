# 06. 雙 AI 引擎與 RAG 架構 (AI Engine & RAG)

## 1. 雲端旗艦: Google Gemini 3.7 Flash
- **Dynamic Thinking (混合推理)**: 自動根據題目難度調配思考預算。
- **思考過濾**: 自動過濾內部 `thought: true` 區塊，呈現純淨解析。
- **自適應溫度 (Temperature)**: 鎖定 1.0 以確保概念解析生動與多樣性。

## 2. 端側離線: Google Gemma 4 (2B) LiteRT
- **4096 Tokens 預算解鎖**: 完全解除字數截斷，支援長篇生活化比喻與完整 Cisco CLI 配置範例。
- **LiteRT 加速**: 使用 Android 原生 NDK 28.2.13676358 編譯，極致節能推論。

## 3. GCS RAG 官方教科書知識庫與四層防禦
直連 GCS 載入 6,688 個官方教材切片，通過「智慧頁面分類 ➔ 5 大維度評分 ➔ 範圍過濾 ➔ 檢索端加權」四層防禦管線。
