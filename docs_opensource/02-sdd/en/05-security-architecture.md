# 05. Security Architecture

## 1. Triple-Defense Security Matrix
1. **Dynamic Watermarking (`EnhancedSecurityWatermark`)**: 8x4 diagonal grid overlaying UID and timestamp.
2. **Native Screen Lock (`SecureScreenService`)**: Android `FLAG_SECURE` preventing screenshots and screen recording.
3. **Web Protection (`WebSecurityWrapper`)**: Disables right-click, selection, copy, and monitors DevTools.

## 2. Cloud Security
- **Firebase App Check & Google Play Integrity**: Restricts API calls to authentic clients.
- **Firestore Security Rules**: Role-based access control via Custom Claims.
