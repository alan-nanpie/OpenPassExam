# ADR-004: Native Google Play Billing Architecture
## Status: Accepted
## Date: 2026-09-01
## Context
PassExam offers subscription tiers for advanced mock exams and AI features, requiring a fully compliant and reliable billing infrastructure.

## Decision
Standardize on native Google Play Billing (Play Billing Library 6+) with Google Cloud Pub/Sub and Firebase Functions:
1. **Client Integration**: Official `in_app_purchase` Flutter plugin connecting directly to Google Play.
2. **Real-Time Developer Notifications (RTDN)**: Google Cloud Pub/Sub pipeline to process subscription renewals, cancellations, and refunds.
3. **Backend Receipt Validation**: Firebase Functions verifying purchase tokens via Google Play Developer API.

## Alternatives Considered
- **Third-Party Payment Aggregators**:
  - Cons: Additional platform commissions, extra vendor dependency, compliance overhead.
- **Native Google Play Billing (Selected)**:
  - Pros: 100% compliant with Google Play policies, lowest transaction friction, tight Google Cloud integration.

## Consequences
- **Positive**: Zero third-party vendor lock-in, enterprise transaction security.
