Feature: Multi-Subject Exam Practice & Split-Screen Reference
  As a learner,
  I want to practice questions with split-screen diagrams and full offline support,
  So that I can study effectively under any network condition.

  Scenario: Open split-screen image reference dialog
    Given a question contains a network topology diagram
    When the learner opens the reference view
    Then `QuestionImageReferenceDialog` displays in split-screen mode
    And the image is rendered with `SafeImageWidget` 1024px downsampling

  Scenario: Practice questions in offline mode
    Given the device has no internet connection
    When the learner opens the practice screen
    Then questions load instantly from Cloud Firestore native persistent cache
    And answers are queued locally for background synchronization
