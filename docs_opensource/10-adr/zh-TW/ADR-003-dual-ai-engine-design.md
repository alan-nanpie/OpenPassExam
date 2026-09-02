# ADR-003: 純血 Google 雙 AI 推理引擎與階層式調度架構 (Dual AI Engine Design)
## 狀態: 已接受 (Accepted)
## 日期: 2026-09-01
## 背景 (Context)
考生需要深度思考的邏輯推理與手把手生活化比喻教學，同時在斷網環境下亦需即時 AI 助教支援。

## 決策 (Decision)
全面採用 Google 官方 AI 解決方案，建立雲端旗艦與端側離線雙 AI 引擎：
1. **雲端旗艦: Google Gemini 3.7 Flash**:
   - 啟用 Dynamic Thinking 混合推理、自適應思考預算、過濾內部 `thought: true`。
2. **端側離線: Google Gemma 4 (2B) LiteRT**:
   - 輸出預算鎖定 4096 tokens，解除字數截斷，支援生活化比喻與手把手 Cisco CLI 指令指引。
3. **四層階層式 AI 調度**:
   - `本機覆寫 ➔ Firebase RTDB 廣播 ➔ Remote Config ➔ 內建預設值`。

## 考慮過的替代方案 (Alternatives Considered)
- **非 Google 第三方模型**:
  - 缺點：API 協定分散、成本較高、缺乏統一的端側 LiteRT 離線協同能力。
- **純 Google AI 旗艦生態系 (最終方案)**:
  - 優點：Gemini 3.7 Flash 與 Gemma 4 架構同源、完美適配 Firebase Remote Config 與 Android LiteRT 加速。

## 後果 (Consequences)
- **正面影響**: 極致的推理品質、高彈性雲端動態調度、100% 離線 AI 輔導支援。
