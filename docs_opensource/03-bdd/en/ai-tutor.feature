Feature: Dual AI Tutor Reasoning & On-Device Offline Guidance
  As a learner,
  I want to ask questions to the AI tutor and receive analogies and CLI steps,
  So that I can master complex networking topics.

  Scenario: Ask question online with Gemini 3.7 Flash Dynamic Thinking
    Given the device is connected to the internet
    When the learner asks about OSPF virtual links
    Then Gemini 3.7 Flash reasons with Dynamic Thinking, filtering `thought: true`
    And returns pedagogical analogies and Cisco CLI walkthroughs

  Scenario: Offline tutoring with on-device Gemma 4 (2B) LiteRT
    Given the device is offline
    When the learner requests an explanation
    Then the app dispatches to on-device Gemma 4 (2B) LiteRT
    And generates complete guidance within the 4096-token budget without truncation
