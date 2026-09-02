# ADR-001: Google Cloud Multi-Tier Database Architecture
## Status: Accepted
## Date: 2026-09-01
## Context
PassExam supports CCNA 200-301 and 18+ Cisco professional certifications (5,000+ questions), requiring high-throughput real-time indexing, 768-dimensional AI semantic search, native offline persistence, and RAG knowledge retrieval.

## Decision
Adopt a unified Google Cloud multi-tier data architecture routed via `RepositoryFactory`:
1. **Google Cloud Firestore**: Primary database for questions (`exam_subjects`), user profiles, and exam sessions with native offline cache.
2. **Firebase RTDB**: High-speed live indexing (`approvedKeys`), presence, and global AI model broadcasting (`ai_model_config`).
3. **Google Cloud Storage (GCS)**: RAG knowledge packs (6,688 verified chunks) and network topology images.
4. **Vertex AI Vector Search / Firestore Vector Search**: 768-dimensional embeddings for semantic search.
5. **Google BigQuery**: Enterprise learning analytics and quality reporting.

## Alternatives Considered
- **Third-Party Heterogeneous Multi-Database Architecture**:
  - Cons: Multi-vendor credential overhead, cross-cloud latency, vendor reliability risk.
- **Unified Google Cloud Native Architecture (Selected)**:
  - Pros: Unified IAM, zero cross-cloud latency, seamless Firebase SDK integration.

## Consequences
- **Positive**: Clean architecture, zero external dependencies, enterprise-grade Google Cloud security.
