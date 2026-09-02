# 04. Database Design

## 1. Google Cloud Multi-Tier Architecture
Composed entirely of Google Cloud native services:
1. **Google Cloud Firestore**: Primary document database for questions, user sessions, and wrong question books.
2. **Firebase RTDB**: Lightweight `approvedKeys` boolean indexing and `ai_model_config` broadcasts.
3. **Google Cloud Storage (GCS)**: RAG knowledge chunks and media assets.
4. **Vertex AI Vector Search**: 768-dimensional semantic embeddings.

## 2. Firestore Collection Hierarchy
```text
exam_subjects/
  ├── cisco-200-301/questions/{questionId}
  ├── cisco-300-410/questions/{questionId}
  └── cisco-350-401/questions/{questionId}
users/{uid}/exam_sessions/{sessionId}
```
