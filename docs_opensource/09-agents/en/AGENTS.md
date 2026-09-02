# AI Agent Guidelines (AGENTS)

Authoritative guide for AI Agents operating in the PassExam repository. Outlines technical conventions, architecture standards, and development protocols.

## 1. Role & Objective

- **Role**: Expert Flutter & Google Cloud Backend Developer Assistant.
- **Objective**: Build, extend, and maintain the PassExam certification exam platform supporting CCNA 200-301 and 18+ Cisco certifications (5,000+ questions) with 100% Google Cloud ecosystem integration, offline-first resilience, and high performance.

## 2. Technology Stack

| Component | Selected Technology | Purpose |
|---|---|---|
| **Frontend** | Flutter 3.x (Dart 3.x) | Cross-platform Android and Web UI. |
| **Databases** | Google Cloud Firestore + Firebase RTDB + GCS | Partitioned question collections, lightweight `approvedKeys` index, RAG knowledge packs. |
| **AI Engine** | Gemini 3.7 Flash + Gemma 4 (2B) + Remote Config | Hybrid reasoning (Dynamic Thinking) and on-device 4096-token tutor. |
| **Security** | Triple-Defense Matrix | `EnhancedSecurityWatermark` + `FLAG_SECURE` + `WebSecurityWrapper`. |
| **Monetization** | Google Play Billing | In-app purchases and subscription management. |
| **Diagnostics** | Firebase Crashlytics + Google Cloud Logging | Unified telemetry and crash reporting. |
| **Build Standard** | JDK 21 LTS / NDK 28.2.13676358 | Strict toolchain locks preventing build failures. |

## 3. Core Development Protocols

- **Toolchain Locks**: JDK 21 LTS and Android NDK `28.2.13676358`.
- **Image Decoding Defense (Anti-OOM)**: All question images rendered via `SafeImageWidget` with `cacheWidth: 1024`.
- **Isolate Offloading (Anti-ANR)**: String concatenations, JSON parsing, or RAG formatting over 500 lines MUST be offloaded using `compute()` to prevent `StringBuffer._addPart` ANRs.
- **Selective Repainting**: Countdown timers MUST use `ValueListenableBuilder`.
- **Pure Google Ecosystem**: Use Google Cloud and Firebase native services across all modules.

## 4. Hard Rules

1. **No Secrets in Git**: Never commit `secrets.json`, `key.properties`, `service-account.json`.
2. **Edge-to-Edge Support**: Native `MainActivity.kt` must invoke `enableEdgeToEdge()`.
3. **Test Gates**: Pass `flutter analyze lib` and `flutter test` with 0 errors.
