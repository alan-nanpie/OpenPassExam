# Google AI API (Gemini 3.7 Flash & Gemma 4) Setup Guide

## 1. Google Gemini 3.7 Flash API Setup
- Retrieve your API key from [Google AI Studio](https://aistudio.google.com/).
- **Gemini 3.7 Flash** delivers Dynamic Thinking hybrid reasoning with adaptive budget and pedagogical explanations.
- Set `GEMINI_API_KEY` in `secrets.json` or Google Secret Manager.

## 2. On-Device Offline Google Gemma 4 (2B) LiteRT Setup
- Gemma 4 2B operates with a 4096-token budget via LiteRT on Android.
- Provides 100% offline tutor explanations and Cisco CLI step-by-step guidance.

## 3. 4-Tier Hierarchical AI Dispatch
```text
[Tier 1: Local Override] ➔ [Tier 2: Firebase RTDB Broadcast] ➔ [Tier 3: Remote Config] ➔ [Tier 4: Static Defaults]
```

## 4. Code Integration
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
    return response.text ?? 'No response';
  }
}
```
