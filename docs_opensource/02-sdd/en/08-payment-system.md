# 08. Payment & Subscription System

## 1. Native Google Play Billing Architecture
Uses Google Play Billing (Play Billing Library 6+) for standardized in-app purchases:
- **Subscription Tiers**: Monthly, Quarterly, and Annual PassExam Pro passes.
- **Real-Time Developer Notifications (RTDN)**: Google Cloud Pub/Sub pipeline for automated subscription status updates.
- **Receipt Verification**: Firebase Functions verifying tokens with Google Play Developer API.
