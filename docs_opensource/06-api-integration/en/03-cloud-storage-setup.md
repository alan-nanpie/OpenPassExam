# Google Cloud Storage (GCS) Setup Guide

## 1. Account & Bucket Architecture
Google Cloud Storage (GCS) hosts the RAG knowledge base chunks, question network topology images, and automated publication bundles:
- **RAG Knowledge Base Bucket (`passexam-rag-knowledge`)**:
  - Contains 6,688 official textbook chunks for the NotebookLM Study Workspace.
- **Question Media Bucket (`passexam-media-assets`)**:
  - Stores high-resolution network diagrams rendered via `SafeImageWidget`.
- **Publication Artifacts Bucket (`passexam-publication-artifacts`)**:
  - Stores generated EPUB 3 and Google Play Books ONIX 3.0 bundles.

## 2. Bucket Configuration & Access Rules
- Navigate to the [Google Cloud Storage Console](https://console.cloud.google.com/storage).
- Create a Standard Storage bucket located in your target region (e.g., `asia-east1` or `us-central1`).
- Configure CORS to allow secure web and app retrieval:
```json
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD"],
    "responseHeader": ["Content-Type", "Access-Control-Allow-Origin"],
    "maxAgeSeconds": 3600
  }
]
```

## 3. SDK Installation
### Flutter Client
```yaml
dependencies:
  firebase_storage: ^12.4.0
```

### Python Toolchain
```bash
pip install google-cloud-storage google-genai
```

## 4. Code Integration
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<Map<String, dynamic>>> loadGcsRagChunks(String gcsPublicUrl) async {
  final response = await http.get(Uri.parse(gcsPublicUrl));
  if (response.statusCode == 200) {
    final List<dynamic> rawList = json.decode(utf8.decode(response.bodyBytes));
    return rawList.cast<Map<String, dynamic>>();
  }
  throw Exception('Failed to load GCS RAG chunks: ${response.statusCode}');
}
```

## 5. Required Environment Variables
| Variable | Description |
|---|---|
| `GCS_RAG_BUCKET_NAME` | Bucket name for RAG knowledge packs |
| `GCS_PUBLIC_URL` | Base public URL for assets |
| `GOOGLE_APPLICATION_CREDENTIALS` | Service account JSON path |

## 6. Troubleshooting
- **CORS Errors on Web**: Run `gcloud storage buckets update gs://<BUCKET_NAME> --cors-file=cors.json`.
