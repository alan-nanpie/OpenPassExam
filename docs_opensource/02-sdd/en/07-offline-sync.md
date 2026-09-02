# 07. Offline Sync Architecture

## 1. Cloud Firestore Native Persistent Cache
PassExam eliminates third-party sync proxies in favor of Google Cloud Firestore native offline persistence:
- **Local Cache Indexing**: Embedded persistent cache supporting complex offline queries and filtering.
- **Mutation Queue**: Offline answers update the UI optimistically and sync automatically upon reconnect.
- **Zero Third-Party Server Overhead**: Clean, serverless Google Cloud architecture.
