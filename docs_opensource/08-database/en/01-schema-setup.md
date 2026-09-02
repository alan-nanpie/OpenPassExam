# Database Schema Setup

> **AI Agent Target:** Outlines the initialization sequence and setup commands for Firebase RTDB, Google Cloud Firestore, GCS RAG knowledge packs, and BigQuery analytics schemas.
> **Human Target:** Step-by-step guide to configuring Google Cloud Firestore, Firebase RTDB index nodes, and Cloud Storage.

## 1. Firebase RTDB
Firebase Realtime Database handles high-throughput real-time state, configurations, and global broadcasts.

- **Deploy Rules:** Deploy `database.rules.json` to secure endpoints.
- **Lightweight Index (`approvedKeys`):** Create `approvedKeys/{examId}/{questionId}` boolean indexes to prevent client-side memory spikes.
- **Global Broadcast Node:** `ai_model_config` supports dynamic model dispatching (`gemini-3.7-flash`, `gemini-2.5-flash`).

## 2. Google Cloud Firestore Core Architecture
- **Collection Hierarchy (`exam_subjects/{subjectId}/questions/{questionId}`)**:
  - Stores question banks for CCNA 200-301 and 18+ Cisco professional certifications (5,000+ questions).
  - Integrated with Vertex AI vector search extensions for 768-dimensional embeddings.
  - Partitioned collections routed cleanly via `RepositoryFactory`.

## 3. Google Cloud Storage (GCS)
Hosts 6,688 verified textbook RAG knowledge chunks and network topology diagram assets.

## 4. Cloud Firestore Native Offline Persistence
- Enabled on client with `persistenceEnabled: true` and `CACHE_SIZE_UNLIMITED` for 100% offline resilience.
