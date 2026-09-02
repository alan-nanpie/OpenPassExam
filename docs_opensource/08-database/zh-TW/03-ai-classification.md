# AI 分類與處理 (AI Classification & Processing)

> **AI Agent Target:** Explains the workflow for `classify_questions_ai.py` and `generate_question_embeddings.py` for automated data augmentation with Gemini & Vertex AI.
> **Human Target:** 使用 Python 腳本搭配 Google Gemini 自動分類考題與產生 768 維向量嵌入的指南。

## `classify_questions_ai.py` 使用指南

此腳本使用 Google Gemini 3.7 Flash 模型分析題目語意，並自動將其分類至認證官方考試領域 (Domain 1-6)。

**前置作業:**
- Python 3.10+
- `secrets.json` 中有效的 `GEMINI_API_KEY`
- Google Cloud / Firebase Admin 憑證 (`scripts/service-account.json`)

**工作流程:**
1. **讀取未分類考題:** 查詢 Cloud Firestore 中 `topic` 欄位為空或待校驗之題目。
2. **Gemini 推論分類:** 提示 Gemini 3.7 Flash 進行結構化 JSON 領域歸類與解析生成。
3. **進度快取:** 將處理進度儲存至本地 `classified_ids.json`，支援斷點續傳。
4. **雙向同步寫入:** 更新 Cloud Firestore 主題集合，並同步寫入 Firebase RTDB `approvedKeys` 索引節點。
5. **速率控管:** 內建指數退避 (exponential backoff) 演算法防止 API 限速。

## `generate_question_embeddings.py`

使用 Google `text-embedding-004` 產生 768 維度的高精確向量嵌入。

- **儲存:** 產生的向量儲存於 Cloud Firestore 向量欄位 (`embedding: VectorValue`) 或 Vertex AI Vector Search 索引中。
- **用途:** 驅動跨科目語意搜尋、考點相似題比對與弱點診斷。
