# Product Requirements Document (PRD) - PassExam

## 1. Product Vision & Goals

### 1.1 Problem Statement
Preparing for professional certifications (e.g. Cisco CCNA/CCNP, cloud architecture, cybersecurity) is expensive and fragmented. Traditional exam prep apps lack adaptive AI tutoring and offline-first capabilities.

### 1.2 Solution
**PassExam** is an open-source, multi-subject certification exam platform combining Google Gemini 3.7 Flash Dynamic Thinking reasoning with on-device Gemma 4 (2B) LiteRT and Google Cloud Firestore native persistent caching. It features 18+ Cisco subjects (5,000+ questions), a NotebookLM Study Workspace connected to GCS textbook knowledge packs, Split-Screen Image Reference, Triple-Defense security, and Google Play Books / Audiobook publication pipelines.

### 1.3 Target Audience
Engineers, students, and self-learners preparing for Cisco (CCNA/CCNP/CCIE), Google Cloud, and cybersecurity certifications.

---

## 2. User Roles
1. **Learner (Primary User)**: Practice questions, full mock exams, wrong questions review, AI tutor chat.
2. **Admin**: Question CRUD, AI Model & Remote Config dashboard, batch approvals, security rules.
3. **Guest**: Preview sample questions.
4. **Internal Tester**: Test internal Play Store builds and experimental Gemini 3.7 features.
5. **Public Tester**: Beta testing offline persistence and Gemma 4 performance.
6. **Viewer / Pending**: Read-only or under-review accounts.

---

## 3. Functional Requirements (FR)

### 3.1 Authentication & RBAC
- **P0**: Google Sign-In & Email/Password via Firebase Authentication.
- **P0**: 6 user roles (Admin, Viewer, Pending, InternalTester, PublicTester, Guest).
- **P1**: Single active device tracking (`activeDeviceId`).

### 3.2 Question Practice & Split-Screen Reference
- **P0**: 18+ subjects (5,000+ questions) with 4 question types (Single, Multi, Drag & Drop, Sim).
- **P0**: `QuestionImageReferenceDialog` split-screen image view with high-contrast themes.
- **P0**: Multi-language explanations (EN, JA, zh-TW, zh-CN) with "Learn English from Questions".

### 3.3 Mock Examination
- **P0**: Timed exams (10/30/50/100 questions) with `ValueListenableBuilder` selective repainting.
- **P1**: Domain diagnostic reports and score history.

### 3.4 Dual AI Engine & Cascading Hierarchy
- **P0**: Cloud **Gemini 3.7 Flash** (Dynamic Thinking, filter `thought: true`, Temp 1.0).
- **P0**: 4-Tier dispatch: `Local Override → RTDB Broadcast → Remote Config → Static Defaults`.
- **P0**: On-device **Gemma 4 (2B)**: 4096-token budget via LiteRT for uncapped offline tutoring.

### 3.5 NotebookLM Study Workspace & GCS RAG
- **P0**: Direct GCS connection loading 6,688 verified textbook chunks.
- **P0**: 4-tier RAG defense pipeline.
- **P1**: 5+1 Studio Tools (Study Guide, FAQ, Briefing, Timeline, Cheat Sheet, Custom Artifact).

### 3.6 Search & Semantic Vector Retrieval
- **P1**: Multi-field filtering (number, type, domain, image).
- **P2**: 768-dim vector embeddings via Vertex AI Vector Search / Firestore Vector Search.

### 3.7 Monetization & Subscriptions
- **P0**: Google Play Billing native integration (Play Billing Library 6+).
- **P1**: Subscription lifecycle management and purchase restoration.

### 3.8 Publication Toolchain
- **P1**: Automatic extraction (`fetch_firestore_books.py`).
- **P1**: EPUB 3 builder (`build_ccna_epub.py`).
- **P1**: ONIX 3.0 Google Play Books publisher (`publish_to_play_books.py`).

---

## 4. Non-Functional Requirements (NFR)

- **Performance & Android 15/16 Quality**:
  - Cold start < 2.5s, 60fps list scrolling, Edge-to-Edge full support.
  - `SafeImageWidget` with `cacheWidth: 1024` downsampling.
  - Offload heavy tasks with `compute()` to prevent `StringBuffer._addPart` ANRs.
- **Triple-Defense Security**:
  - `EnhancedSecurityWatermark` (8x4 UID grid).
  - Native `SecureScreenService` (`FLAG_SECURE`).
  - `WebSecurityWrapper` anti-devtool and copy lock.
- **Data Persistence**:
  - Google Cloud Firestore + Firebase RTDB + Firestore Native Persistent Cache.
