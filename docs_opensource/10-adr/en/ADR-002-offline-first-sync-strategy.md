# ADR-002: Cloud Firestore Native Offline Persistence Strategy
## Status: Accepted
## Date: 2026-09-01
## Context
Learners frequently practice in offline environments (transit, airplanes). The application must deliver seamless offline exam practice with zero data loss.

## Decision
Adopt Google Cloud Firestore native persistent cache paired with on-device Gemma 4 (2B) LiteRT:
1. **Firestore Native Persistence**: Enabled with `Settings(persistenceEnabled: true, cacheSizeBytes: CACHE_SIZE_UNLIMITED)`.
2. **Firestore Data Bundles**: Direct bundle loading into local persistent cache for instant offline access.
3. **Offline AI Tutor**: Google Gemma 4 2B (LiteRT) on-device inference with 4096 tokens budget.

## Alternatives Considered
- **Third-Party Sync Intermediate Proxy**:
  - Cons: Requires running and maintaining additional third-party sync servers and paid subscriptions.
- **Firestore Native Persistent Cache (Selected)**:
  - Pros: Zero additional server infrastructure, built-in offline mutation queue, automated background synchronization.
