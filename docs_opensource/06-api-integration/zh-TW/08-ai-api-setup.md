# Google AI API (Gemini 3.7 Flash & Gemma 4) 設定指南

## 1. Google Gemini 3.7 Flash API 與 BYOK (自備免費金鑰) 設定
- 考生可前往 [Google AI Studio (aistudio.google.com)](https://aistudio.google.com/app/apikey) 免費申請專屬 API 金鑰。
- **Gemini 3.7 Flash** 提供 Dynamic Thinking 混合推理能力，支援自適應思考預算與生活化比喻解析。
- **BYOK (Bring Your Own Key) 機制**：金鑰直接儲存於使用者個人本機裝置（SharedPreferences / LocalStorage），絕不上傳至任何伺服器或存入程式碼中，保障隱私且享有免費專屬配額。
- 若未輸入金鑰，系統將自動無縫回退至端側 Gemma 4 與官方預設精華解析。

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
