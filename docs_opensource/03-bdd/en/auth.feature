Feature: User Authentication & Device Binding
  As a user,
  I want to sign in with my Google account and maintain secure device binding,
  So that my study progress and subscription entitlements are protected.

  Scenario: Sign in with Google
    Given the user is on the sign-in screen
    When the user clicks "Sign in with Google"
    And completes Google authorization
    Then Firebase Authentication verifies the user identity
    And the user profile is loaded from Cloud Firestore

  Scenario: Single active device tracking
    Given the user is logged in on Device A
    When the user signs in on Device B
    Then the system detects `activeDeviceId` change and prompts for verification
