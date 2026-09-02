Feature: Admin Console & AI Model Configuration
  As an administrator,
  I want to manage question approvals and configure AI models,
  So that the platform maintains high question quality and optimal AI tutoring.

  Background:
    Given the user is logged in with "admin" role
    And the user navigates to the Admin Console

  Scenario: View pending questions
    When the admin opens "Question Approvals"
    Then a list of unapproved questions from Cloud Firestore is displayed

  Scenario: Batch approve all questions
    Given there are pending questions
    When the admin clicks "Approve All"
    Then all questions have `isApproved` updated to true
    And the Firebase RTDB `approvedKeys` index is synchronized

  Scenario: Switch primary AI model via Remote Config panel
    When the admin opens the "AI Model & Remote Config Management" screen
    And sets the primary model to `gemini-3.7-flash` with Temperature 1.0
    And clicks "Publish Configuration"
    Then Firebase Remote Config and RTDB broadcast nodes are updated globally
