# PassExam — Open-Source Certification Exam Practice Platform Documentation

> **Language / 語言**: [English](#english) | [繁體中文](#繁體中文)

---

<a id="english"></a>

## 📚 English Documentation Index

Welcome to the **PassExam** documentation suite — a comprehensive, professional-grade specification package designed to enable **any developer or AI agent** to build a complete, production-ready, multi-subject certification practice application from scratch.

### 🎯 What is PassExam?

PassExam is an open-source, AI-powered, offline-capable certification practice platform built with Flutter and the **Google Cloud & Firebase Ecosystem**. It supports 18+ exam subjects (5,000+ questions), hybrid dual AI tutoring (Gemini 3.7 Flash Reasoning + on-device Gemma 4 LiteRT), multi-tier Google Cloud architecture (Cloud Firestore + Firebase RTDB + GCS + Vertex AI Vector Search), NotebookLM Study Workspace, Split-screen Image Reference with Triple-Defense security, and Google Play Books / Audiobook publication pipelines.

### 🗺️ Documentation Map

#### Quick Navigation by Role

| Your Role | Start Here | Then Read |
|---|---|---|
| 🤖 **AI Agent** | [AI Agent Guide](09-agents/en/AGENTS.md) | [PRD](01-prd/en/PRD.md) → [Architecture](02-sdd/en/02-architecture.md) → [BDD](03-bdd/en/) |
| 👔 **Product Manager** | [PRD](01-prd/en/PRD.md) | [UI/UX Spec](05-ui-ux/en/) → [BDD](03-bdd/en/) |
| 👩‍💻 **Developer** | [Architecture](02-sdd/en/02-architecture.md) | [Data Models](02-sdd/en/03-data-models.md) → [Database Design](02-sdd/en/04-database-design.md) |
| 🧪 **QA Engineer** | [Test Strategy](04-test-spec/en/01-test-strategy.md) | [BDD](03-bdd/en/) → [Test Matrix](04-test-spec/en/06-test-matrix.md) |
| 🔧 **DevOps** | [Deployment Guide](07-deployment/en/) | [API Integration](06-api-integration/en/) → [Secrets](07-deployment/en/05-secrets-management.md) |

---

### 📁 Complete Document Inventory

#### 1. Product Requirements (PRD)
| Document | Description |
|---|---|
| [PRD.md](01-prd/en/PRD.md) | Vision, multi-subject scope, user stories, functional & non-functional requirements |

#### 2. System Design (SDD)
| Document | Description |
|---|---|
| [01-system-overview.md](02-sdd/en/01-system-overview.md) | Google Cloud & Firebase tech stack, system context diagram, directory structure |
| [02-architecture.md](02-sdd/en/02-architecture.md) | Layered architecture, RepositoryFactory routing, cascading AI hierarchy |
| [03-data-models.md](02-sdd/en/03-data-models.md) | Question, User, Exam data models |
| [04-database-design.md](02-sdd/en/04-database-design.md) | Google Cloud Firestore, Firebase RTDB approvedKeys index, Vertex AI Vector Search |
| [05-security-architecture.md](02-sdd/en/05-security-architecture.md) | Triple-defense matrix (Dynamic Watermark, FLAG_SECURE, Web Security) |
| [06-ai-engine.md](02-sdd/en/06-ai-engine.md) | Gemini 3.7 Flash Dynamic Thinking, Gemma 4 LiteRT (4096 tokens), GCS RAG |
| [07-offline-sync.md](02-sdd/en/07-offline-sync.md) | Firestore native persistent cache and background synchronization |
| [08-payment-system.md](02-sdd/en/08-payment-system.md) | Native Google Play Billing architecture and subscriptions |
| [09-state-management.md](02-sdd/en/09-state-management.md) | Provider, controllers, SafeImageWidget downsampling & compute() ANR safeguards |
| [10-ui-components.md](02-sdd/en/10-ui-components.md) | Split-Screen Image Reference, NotebookLM Studio, Markdown tables |
| [11-automation-scripts.md](02-sdd/en/11-automation-scripts.md) | Play Books / Audiobook pipeline, GCS RAG extractor, Play Store deployer |

#### 3. API & Service Integration
| Document | Description |
|---|---|
| [01-firebase-setup.md](06-api-integration/en/01-firebase-setup.md) | Firebase project, Auth, RTDB, Remote Config, Crashlytics |
| [02-cloud-firestore-setup.md](06-api-integration/en/02-cloud-firestore-setup.md) | Google Cloud Firestore collections, rules, and vector indexing |
| [03-cloud-storage-setup.md](06-api-integration/en/03-cloud-storage-setup.md) | Google Cloud Storage RAG knowledge packs and asset hosting |
| [04-firestore-offline-sync-setup.md](06-api-integration/en/04-firestore-offline-sync-setup.md) | Firestore native persistent cache and offline bundle setup |
| [05-google-play-billing-setup.md](06-api-integration/en/05-google-play-billing-setup.md) | Google Play Billing subscriptions and RTDN notifications |
| [06-admob-setup.md](06-api-integration/en/06-admob-setup.md) | Google AdMob integration |
| [07-crashlytics-cloud-logging-setup.md](06-api-integration/en/07-crashlytics-cloud-logging-setup.md) | Firebase Crashlytics and Google Cloud Logging |
| [08-ai-api-setup.md](06-api-integration/en/08-ai-api-setup.md) | Gemini 3.7 Flash API and Gemma 4 LiteRT-LM |

---

<a id="繁體中文"></a>

## 📚 繁體中文文檔索引

歡迎查閱 **PassExam** 開源題庫與 AI 學習平台完整技術規範文檔。

### 🎯 什麼是 PassExam？
PassExam 是一個結合 **Google 雲端生態系 (Google Cloud & Firebase)**、Gemini 3.7 旗艦推理、端側 Gemma 4 與 Firestore 離線持久化快取的開源認證備考平台。

### 📁 繁體中文文檔目錄清單
- **產品需求 (PRD)**: [PRD.md](01-prd/zh-TW/PRD.md)
- **系統設計 (SDD)**:
  - [01-system-overview.md](02-sdd/zh-TW/01-system-overview.md) (系統總覽)
  - [02-architecture.md](02-sdd/zh-TW/02-architecture.md) (架構設計)
  - [03-data-models.md](02-sdd/zh-TW/03-data-models.md) (資料模型)
  - [04-database-design.md](02-sdd/zh-TW/04-database-design.md) (資料庫設計)
  - [05-security-architecture.md](02-sdd/zh-TW/05-security-architecture.md) (安全架構)
  - [06-ai-engine.md](02-sdd/zh-TW/06-ai-engine.md) (雙 AI 引擎與 RAG)
  - [07-offline-sync.md](02-sdd/zh-TW/07-offline-sync.md) (Firestore 離線持久化)
  - [08-payment-system.md](02-sdd/zh-TW/08-payment-system.md) (Google Play 帳單系統)
  - [09-state-management.md](02-sdd/zh-TW/09-state-management.md) (狀態管理與 ANR 防禦)
  - [10-ui-components.md](02-sdd/zh-TW/10-ui-components.md) (UI 元件庫)
  - [11-automation-scripts.md](02-sdd/zh-TW/11-automation-scripts.md) (自動化工具鏈)
- **API 整合指南**:
  - [01-firebase-setup.md](06-api-integration/zh-TW/01-firebase-setup.md)
  - [02-cloud-firestore-setup.md](06-api-integration/zh-TW/02-cloud-firestore-setup.md)
  - [03-cloud-storage-setup.md](06-api-integration/zh-TW/03-cloud-storage-setup.md)
  - [04-firestore-offline-sync-setup.md](06-api-integration/zh-TW/04-firestore-offline-sync-setup.md)
  - [05-google-play-billing-setup.md](06-api-integration/zh-TW/05-google-play-billing-setup.md)
  - [06-admob-setup.md](06-api-integration/zh-TW/06-admob-setup.md)
  - [07-crashlytics-cloud-logging-setup.md](06-api-integration/zh-TW/07-crashlytics-cloud-logging-setup.md)
  - [08-ai-api-setup.md](06-api-integration/zh-TW/08-ai-api-setup.md)
- **應用程式安裝、建置與小白手冊**:
  - 請參閱專屬目錄 **[`../app_docs/`](../app_docs/)** (包含小白零基礎圖文指南、開發者建置手冊與 Cloud Run 部署指南)。
