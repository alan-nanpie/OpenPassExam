# Test Strategy Specification

## 1. Test Pyramid
- **Unit Tests (70%)**: Models, Services, Controllers, Repositories, Utils.
- **Widget Tests (20%)**: UI component rendering and interactions.
- **Integration/E2E Tests (10%)**: End-to-end flows with Firebase Emulator and Play Billing sandbox.

## 2. Toolchain
- `flutter_test`: Unit and widget testing.
- `mockito` / `mocktail`: Mocking dependencies.
- `fake_cloud_firestore`: In-memory Firestore simulation.
- `integration_test`: Native E2E test driver.
