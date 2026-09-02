# ADR-006: Role-Based Access Control (RBAC) Architecture
## Status: Accepted
## Date: 2026-09-01
## Context
The platform requires strict access control across 6 user roles (Guest, Pending, Viewer, InternalTester, PublicTester, Admin).

## Decision
Implement RBAC using Firebase Auth Custom Claims paired with Google Cloud Firestore Security Rules:
- Role claims embedded directly in Firebase Auth JWT tokens for verified rule evaluation.
- Admin role grants access to AI Model Management and batch question approval panels.
