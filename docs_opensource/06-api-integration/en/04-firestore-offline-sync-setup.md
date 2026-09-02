# Cloud Firestore Native Offline Persistence & Sync Guide

## 1. Architecture Overview
PassExam leverages Google Cloud Firestore native persistent caching to deliver 100% offline resilience with zero third-party sync server dependencies:
- **Native Cache Engine**: Firestore manages IndexedDB on Web and embedded SQLite on Android.
- **Offline Querying**: Full support for topic filtering, wrong-question reviews, and offline score calculations.
- **Automatic Background Synchronization**: Queued mutations automatically sync to Google Cloud once internet connectivity resumes.

## 2. Configuration & Initialization
Enable unlimited offline persistence during app initialization:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

void setupFirestoreOfflineCache() {
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
}
```

## 3. Preloaded Data Bundles
Pre-compiled question bundles can be generated via Cloud Functions and loaded directly into client persistent cache:

```dart
Future<void> preloadOfflineExamBundle(String bundleUrl) async {
  final response = await http.get(Uri.parse(bundleUrl));
  if (response.statusCode == 200) {
    final LoadBundleTask task = FirebaseFirestore.instance.loadBundle(response.bodyBytes);
    await task.stream.last;
  }
}
```

## 4. Cache-First Query Strategy
```dart
Future<List<Question>> fetchQuestionsOfflineFirst(String subjectId) async {
  final query = FirebaseFirestore.instance
      .collection('exam_subjects')
      .doc(subjectId)
      .collection('questions')
      .where('isApproved', isEqualTo: true);

  try {
    final cacheSnapshot = await query.get(const GetOptions(source: Source.cache));
    if (cacheSnapshot.docs.isNotEmpty) {
      return cacheSnapshot.docs.map((d) => Question.fromFirestore(d)).toList();
    }
  } catch (_) {}

  final serverSnapshot = await query.get(const GetOptions(source: Source.serverAndCache));
  return serverSnapshot.docs.map((d) => Question.fromFirestore(d)).toList();
}
```

## 5. Troubleshooting
- **Cache Size Management**: Configured with `CACHE_SIZE_UNLIMITED` by default.
- **Offline Mutation Queue**: Offline answers are queued locally and resolved automatically upon reconnect.
