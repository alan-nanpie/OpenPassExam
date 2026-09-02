Feature: Full Mock Exam & Anti-Leak Security
  As a learner,
  I want to take timed mock exams in a protected environment,
  So that I can evaluate my readiness for real certification tests.

  Scenario: Start a 50-question timed mock exam
    When the learner starts a 50-question mock exam
    Then the countdown timer updates via `ValueListenableBuilder`
    And `EnhancedSecurityWatermark` renders personalized dynamic overlays
    And native `FLAG_SECURE` prevents screenshots and screen recording
