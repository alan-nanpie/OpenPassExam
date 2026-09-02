Feature: Wrong Questions Review
  As a learner,
  I want to review questions I got wrong,
  So that I can eliminate weak areas.

  Scenario: Auto-collect wrong questions
    Given the learner answers a question incorrectly
    When the exam finishes
    Then the question is stored in the Cloud Firestore wrong questions collection
