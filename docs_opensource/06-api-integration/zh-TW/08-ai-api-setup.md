# Google AI API (Gemini 3.7 Flash & Gemma 4) 設定指南

## 1. Google Gemini 3.7 Flash API 設定
- 前往 [Google AI Studio](https://aistudio.google.com/) 取得 API 金鑰。
- **Gemini 3.7 Flash** 提供 Dynamic Thinking 混合推理能力，支援自適應思考預算與生活化比喻解析。
- 設定 `GEMINI_API_KEY` 於 `secrets.json` 或 Google Secret Manager。

## 2. 端側離線模型 Google Gemma 4 (2B) LiteRT 設定
- Gemma 4 2B 鎖定 4096 Tokens 輸出預算，解除 200 字截斷限制。
- 透過 LiteRT (TensorFlow Lite) 於行動裝置本地端運行，實現 100% 離線推論。

## 3. 四層階層式 AI 調度架構
```text
[第 1 層: 本機設定覆寫] ➔ [第 2 層: Firebase RTDB 廣播] ➔ [第 3 層: Remote Config 下發] ➔ [第 4 層: 內建預設值]
```

## 4. 程式碼整合 (google_genai SDK)
```dart
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiTutorService {
  late final GenerativeModel _model;

  void init(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-3.7-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1.0,
        maxOutputTokens: 4096,
      ),
    );
  }

  Future<String> askQuestion(String prompt) async {
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? '無回應';
  }
}
```
