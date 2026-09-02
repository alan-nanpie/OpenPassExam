Feature: Notes & NotebookLM Study Workspace
  As a learner,
  I want to study official textbooks and generate cheat sheets,
  So that I can consolidate my knowledge.

  Scenario: Load GCS official textbook chunks
    When the learner clicks "Load Google Cloud RAG Knowledge Base"
    Then 6,688 verified textbook chunks are loaded from Google Cloud Storage
