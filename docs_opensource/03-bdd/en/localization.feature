Feature: Multi-Language Localization
  As an international learner,
  I want to switch languages for UI and explanations,
  So that I can study in my preferred language.

  Scenario: Switch to Traditional Chinese (zh-TW)
    When the user selects Traditional Chinese
    Then UI and explanations align with Taiwan technical networking terminology
