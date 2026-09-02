# ADR-003: Pure Google Dual AI Engine & Hierarchical Dispatch
## Status: Accepted
## Date: 2026-09-01
## Context
Learners require deep pedagogical reasoning with step-by-step CLI guidance online, as well as reliable offline AI tutoring.

## Decision
Standardize on Google AI technologies:
1. **Cloud Flagship: Google Gemini 3.7 Flash**:
   - Dynamic Thinking hybrid reasoning, adaptive thinking budget, filter `thought: true`.
2. **On-Device Offline: Google Gemma 4 (2B) LiteRT**:
   - 4096-token budget via LiteRT, uncapped explanations, hands-on CLI command guidance.
3. **4-Tier AI Dispatch**:
   - `Local Override ➔ Firebase RTDB Broadcast ➔ Remote Config ➔ Built-in Defaults`.

## Consequences
- **Positive**: State-of-the-art reasoning quality, dynamic cloud dispatching, complete offline tutor availability.
