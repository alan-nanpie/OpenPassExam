Feature: Google Play Billing Payment & Subscription
  As a user,
  I want to subscribe to PassExam Pro via Google Play Billing,
  So that I unlock unlimited AI tutoring and all certification subjects.

  Scenario: Purchase 1-month Pro subscription via Google Play Billing
    Given the user is on the subscription screen
    When the user selects the 1-month Pro plan
    And completes the Google Play checkout flow
    Then Firebase Functions verifies the receipt via Google Play Developer API
    And the user role is updated to "viewer"

  Scenario: Restore purchases
    Given the user logs into a new device with their Google account
    When the user clicks "Restore Purchases"
    Then active entitlements are queried from Google Play Billing and restored
