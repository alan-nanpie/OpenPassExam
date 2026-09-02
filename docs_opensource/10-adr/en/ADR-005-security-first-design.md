# ADR-005: Triple-Defense Security & Anti-Leak Architecture
## Status: Accepted
## Date: 2026-09-01
## Context
Exam questions and study materials represent core intellectual property requiring multi-layered anti-leak safeguards.

## Decision
Deploy a defense-in-depth triple-defense security matrix:
1. **Dynamic Watermarking (`EnhancedSecurityWatermark`)**: 8x4 dynamic grid with UID/timestamp overlay.
2. **Native Screen Protection (`SecureScreenService`)**: Android `FLAG_SECURE` preventing screenshots, screen recording, and casting.
3. **Web Security Wrapper (`WebSecurityWrapper`)**: Right-click disabling, copy prevention, DevTools detection.
4. **Google Play Integrity & Firebase App Check**: Safeguards backend APIs against unauthorized clients.
