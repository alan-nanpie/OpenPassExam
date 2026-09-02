Feature: TTS Voice & Audio Accessibility
  As a learner,
  I want to listen to question audio,
  So that I can review hands-free.

  Scenario: Read question aloud
    When the learner taps the speaker icon
    Then Text-to-Speech narrates the question text and options
