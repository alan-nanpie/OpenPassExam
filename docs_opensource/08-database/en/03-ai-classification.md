# AI Classification & Processing

> **AI Agent Target:** Explains workflow for `classify_questions_ai.py` and `generate_question_embeddings.py` using Google Gemini & Vertex AI.
> **Human Target:** Guide to automated question classification and 768-dim vector embedding generation with Google AI.

## `classify_questions_ai.py` Guide

Uses Google Gemini 3.7 Flash to analyze question semantics and classify items into official certification exam domains (Domains 1-6).

**Prerequisites:**
- Python 3.10+
- Valid `GEMINI_API_KEY` in `secrets.json`
- Google Cloud / Firebase service account credentials (`scripts/service-account.json`)

**Workflow:**
1. **Fetch Unclassified Questions:** Query Cloud Firestore for items with null `topic`.
2. **Gemini Classification:** Prompt Gemini 3.7 Flash for structured topic classification.
3. **Resume Caching:** Save progress locally in `classified_ids.json` for fault tolerance.
4. **Synchronous Write:** Update Cloud Firestore question documents and Firebase RTDB `approvedKeys` index.
5. **Rate Limiting:** Exponential backoff to respect Gemini API quotas.

## `generate_question_embeddings.py`

Generates 768-dimensional vector embeddings using Google's `text-embedding-004`.

- **Storage:** Saved in Cloud Firestore vector fields (`embedding: VectorValue`) and Vertex AI Vector Search index.
- **Purpose:** Powers semantic search, related question recommendations, and knowledge gap diagnostics.
