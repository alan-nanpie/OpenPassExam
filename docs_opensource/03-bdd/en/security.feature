Feature: Triple-Defense Security & Anti-Tamper Protection
  As a system owner,
  I want to prevent question leaks and tampering,
  So that intellectual property is preserved.

  Scenario: Native FLAG_SECURE protection
    When the learner enters an exam screen
    Then native `FLAG_SECURE` is active, preventing screenshots and recording

  Scenario: NTP time tamper validation
    When exam results are submitted
    Then timestamps are verified against network time to prevent clock manipulation
