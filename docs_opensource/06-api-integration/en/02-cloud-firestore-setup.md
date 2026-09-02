# Google Cloud Firestore Setup Guide

## 1. Account & Project Architecture
PassExam uses Google Cloud Firestore as its primary unified database, supporting multi-subject collection partitioning, native offline persistence, and Vertex AI vector search integration:
- **Core Subject Partitioning (`exam_subjects/`)**:
  - Stores question banks for CCNA 200-301 and 18+ Cisco professional certifications (300/350 series, 5,000+ questions).
  - Uses structured Collections and Sub-collections for clean subject isolation.
- **Community Reviews & Approvals (`question_reviews/`)**:
  - Tracks community contributions and admin batch approval pipelines.
- **User Profiles & Exam History (`users/{uid}/exam_sessions`)**:
  - Stores personalized study progress, wrong questions, and mock exam results.

## 2. Database Schema & Security Rules
- Enable Firestore Vector Search / Vertex AI Vector Search extension for 768-dimensional semantic embeddings.
- Configure document schemas supporting both `camelCase` and `snake_case` field compatibility.
- Enforce role-based security rules using Firebase Auth Custom Claims.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /exam_subjects/{subjectId}/questions/{questionId} {
      allow read: if request.auth != null && (resource.data.isApproved == true || request.auth.token.role == 'admin');
      allow write: if request.auth != null && request.auth.token.role == 'admin';
    }
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 3. SDK Installation & Initialization
### pubspec.yaml Dependencies
```yaml
dependencies:
  cloud_firestore: ^5.6.0
  firebase_auth: ^5.5.0
```

### Dart Repository Implementation
```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreQuestionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getQuestions(String subjectId) async {
    final snapshot = await _firestore
        .collection('exam_subjects')
        .doc(subjectId)
        .collection('questions')
        .where('isApproved', isEqualTo: true)
        .get(const GetOptions(source: Source.cacheServer)); // Cache first, seamless offline
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
```

## 4. Required Environment Variables
| Variable | Description |
|---|---|
| `GCP_PROJECT_ID` | Google Cloud Project ID |
| `FIRESTORE_DATABASE_ID` | Firestore Database ID (defaults to `(default)`) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Path to service account JSON for backend/scripts |

## 5. Google Cloud Functions (2nd Gen) Backend
Deploy serverless functions via Firebase CLI / gcloud:
1. `generateEmbeddings`: Generates 768-dim embeddings via Gemini and updates Firestore.
2. `searchQuestionsSemantic`: Executes vector similarity searches.
3. `syncUserRoles`: Updates user Custom Claims.
4. `processPlayBillingWebhook`: Handles Google Play Real-Time Developer Notifications (RTDN).
5. `exportUserData`: Packages study data to Google Cloud Storage.

## 6. Troubleshooting
- **Missing Compound Index**: Click the auto-index creation link generated in Firebase Console error logs.
- **Offline Query Timeout**: Verify `persistenceEnabled: true` is configured during initialization.
