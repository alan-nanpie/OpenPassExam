# Seed Data

> **AI Agent Target:** Schema validation rules for JSON question format and bulk import instructions for Cloud Firestore and GCS.
> **Human Target:** How to format and import initial question bank datasets into Google Cloud Firestore.

## Question JSON Format

Each question object conforms to the following schema:

```json
{
  "id": "q_1001",
  "examId": "exam_001",
  "type": "SINGLE_CHOICE",
  "title": "What is the primary function of a router?",
  "options": [
    "Connect multiple networks",
    "Provide device power",
    "Store persistent data"
  ],
  "correctAnswer": [0],
  "explanation": "Routers operate at Layer 3 to forward packets between networks.",
  "topic": "Domain 1",
  "isApproved": true
}
```

### Required Fields
- `id`, `examId`, `type`, `title`, `options`, `correctAnswer`, `topic`, `isApproved`

## Bulk Import Methods

### Google Cloud Firestore
Using Python with `firebase-admin` Batch Writes:

```python
import json
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate("scripts/service-account.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

with open("seed_questions.json", "r", encoding="utf-8") as f:
    questions = json.load(f)

batch = db.batch()
for q in questions:
    doc_ref = db.collection("exam_subjects").document(q["examId"]).collection("questions").document(q["id"])
    batch.set(doc_ref, q)

batch.commit()
print("Firestore seed data imported successfully!")
```

### Google BigQuery
```bash
bq load --source_format=NEWLINE_DELIMITED_JSON passexam_dataset.questions gs://passexam-seed-data/questions.json schema.json
```
