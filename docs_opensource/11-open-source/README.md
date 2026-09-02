# PassExam 📝

![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)
![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?logo=dart&logoColor=white)
![Google Cloud](https://img.shields.io/badge/Google%20Cloud-Firebase-orange.svg)
![Android 15 Ready](https://img.shields.io/badge/Android%2015%2F16-Edge--to--Edge-brightgreen.svg)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

> **The ultimate open-source multi-subject certification exam practice platform & AI study companion powered by the Google Cloud & AI Ecosystem.**
> 
> **終極開源跨領域認證考試題庫與 AI 智慧學習夥伴平台 — 全面基於 Google Cloud 與 Google AI 生態系。**

---

## ✨ Features Overview | 功能概覽

* 📝 **Multi-Subject Certification Question Bank (5,000+ Questions)** | **18+ 認證科目題庫 (5,000+ 題)** (CCNA 200-301, CCNP 300/350/400 series, Single/Multiple/DnD/Simulations)
* 🤖 **Hybrid Dual AI Tutor & Dynamic Persona** | **Google 雲端/端側雙 AI 家教** (Gemini 3.7 Flash Dynamic Thinking Reasoning + On-Device Gemma 4 2B with 4096 tokens)
* ☁️ **Firebase Remote Config 4-Tier Dispatch** | **四層階層式 AI 動態調度** (Local Override → RTDB Broadcast → Remote Config → Static Defaults)
* 📚 **NotebookLM Study Workspace & GCS RAG Pipeline** | **NotebookLM 學習工作區與 GCS 官方教科書精華知識庫** (6,688 Chunks, 4-tier RAG Defense)
* 🖼️ **Split-Screen Image Reference & Triple-Defense Security** | **上下分屏圖文對照檢視與三位一體安全防護** (Dynamic Watermark + FLAG_SECURE + Web Anti-devtool)
* 📱 **Offline-First Resilience with Cloud Firestore Cache** | **本地優先離線持久化快取** (Cloud Firestore + Firebase RTDB approvedKeys Index)
* 📖 **Google Play Books & Audiobook Toolchain** | **Google Play 圖書與語音有聲書發布工具鏈** (EPUB 3 / ONIX 3.0 / TTS Audio Accessibility)
* 🌐 **4 Languages Full Localization** | **4 國語系完整在地化** (English, 日本語, 繁體中文 zh-TW, 簡體中文 zh-CN)
* 💳 **Google Play Billing Native Subscriptions** | **Google Play Billing 官方訂閱系統**
* 🛡️ **Android 15/16 Edge-to-Edge & Performance Safeguards** | **沉浸式無邊框與效能安全防護** (SafeImageWidget 1024 downsampling, Main-thread `compute()` ANR defense)

---

## 🚀 Quick Start | 快速開始

1. **Clone repository** | **複製儲存庫**
2. **Install dependencies** | **安裝依賴套件** (`flutter pub get`)
3. **Configure Google Cloud & Firebase** | **設定 Google Cloud 與 Firebase 專案**
4. **Run the app** | **執行應用程式** (`flutter run`)

*For detailed instructions, see [QUICKSTART.md](./QUICKSTART.md).*

---

## 🛠 Technology Stack | 技術堆疊

| Category | Technology |
|---|---|
| **Framework** | Flutter 3.x, Dart 3.x (Android, Web) |
| **Databases** | Google Cloud Firestore (Partitioned Subject Collections), Firebase RTDB (approvedKeys index), Firestore Persistent Cache |
| **State Management** | Provider / ChangeNotifier, SafeImageWidget, Background `compute()` Isolates |
| **AI Engine** | Gemini 3.7 Flash (Dynamic Thinking), Gemma 4 LiteRT-LM (2B, 4096 tokens), Firebase Remote Config |
| **RAG & Knowledge** | Google Cloud Storage (GCS) Textbook Knowledge Pack (6,688 chunks), 4-tier filtering pipeline |
| **Vector Search** | Vertex AI Vector Search / Firestore Vector Search (768-dim embeddings) |
| **Publication** | EPUB 3 Builder, Google Play Books / Audiobooks ONIX 3.0 generator |
| **Security** | Triple-Defense (Dynamic Watermark, `FLAG_SECURE`, `WebSecurityWrapper`, Google Play Integrity) |
| **Payment** | Google Play Billing (Play Billing Library 6+) |
| **Build & Toolchain** | Gradle 8.11, NDK 28.2.13676358, JDK 21 LTS, Google Cloud Build |

---

## 📄 License | 授權

This project is licensed under the Apache License 2.0 - see the [LICENSE](./LICENSE) file for details.
