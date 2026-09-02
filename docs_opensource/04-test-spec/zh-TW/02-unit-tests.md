# 單元測試規範 (Unit Tests)

## 1. 測試範疇
- **`Question` 模型**: 測試 `fromMap`、`toMap` 雙格式 (camelCase / snake_case) 解析。
- **`FirestoreQuestionRepository`**: 測試快取優先載入與離線異常回退。
- **`GeminiTutorService`**: 測試 Dynamic Thinking 提示詞封裝與思考標籤過濾。
