Feature: Question Search & Semantic Vector Retrieval
  As a learner,
  I want to search questions by keywords and semantic concepts,
  So that I can find related networking problems quickly.

  Scenario: Semantic search with Vertex AI 768-dim embeddings
    When the learner searches for "WAN link troubleshooting"
    Then Vertex AI Vector Search retrieves semantically matched certification questions
