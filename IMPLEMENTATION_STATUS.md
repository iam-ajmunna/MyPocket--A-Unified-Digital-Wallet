# MyPocket — Implementation Status

**Project:** MyPocket — Unified Digital Wallet (Bangladesh)
**Target:** Public release on Google Play & Apple App Store
**Last Updated:** 2026-08-05
**Maintainer:** AJ (Tanvir)

> This document is the single source of truth for engineering progress. It must be updated with every milestone change. No task is marked complete until implemented **and** verified.

---

## Status Legend
- `Not Started` — no work has begun
- `In Progress` — actively being built
- `Blocked` — waiting on a decision, dependency, or external resource
- `In Review` — implementation done, undergoing code/security review
- `Complete` — implemented, tested, and verified

---

## Milestone 0 — Planning & Architecture

**Objective:** Lock scope, stack, security model, and engineering conventions before any code is written.

**Planned Tasks**
- [x] Requirements Q&A with stakeholder
- [x] Stack decision (Flutter + NestJS + PostgreSQL, Dockerized)
- [x] Security architecture decision (envelope encryption, biometric gate)
- [x] `ARCHITECTURE.md` written (system design, data flow diagrams, threat model)
- [x] `AGENTS.md` written (AI agent operating rules)
- [x] Repo scaffolding created (GitFlow branches: `main`, `develop`)
- [x] Per-feature doc template established (`docs/templates/feature_template.md`)

**Current Status:** Complete
**Validation Status:** Complete
**Date Started:** 2026-08-05
**Date Completed:** 2026-08-05
**Notes:** Full rebuild from scratch approved. Architecture, agent rules, and decision log (Riverpod for Mobile State Management, Prisma for ORM, GitFlow branching) finalized.
**Known Issues:** None.
**Next Actions:** Begin Milestone 1 (Backend Foundation) & Milestone 2 (Mobile App Foundation) scaffolding.

---

## Milestone 1 — Backend Foundation

**Objective:** Stand up a secure, containerized NestJS + PostgreSQL backend with the core auth and encryption architecture in place before any feature logic is built.

**Planned Tasks**
- [ ] NestJS project scaffold (modular: `auth`, `users`, `cards`, `documents`, `mfs`, `transit`, `certificates`, `ai`)
- [ ] PostgreSQL schema design + migrations (Prisma ORM)
- [ ] Docker Compose setup (API + Postgres + local dev parity with future cloud deploy)
- [ ] JWT auth (access + refresh tokens), password hashing (Argon2id)
- [ ] Envelope encryption service (KEK/DEK key hierarchy, AES-256-GCM)
- [ ] Secrets management strategy (`.env` locally, vault-style for production)
- [ ] Rate limiting + input validation middleware (class-validator / Zod)
- [ ] Health check + structured logging (no PII in logs)

**Current Status:** In Progress
**Validation Status:** In Progress
**Date Started:** 2026-08-05
**Date Completed:** —
**Notes:** Feature spec created in `docs/features/backend-foundation.md`.
**Known Issues:** None yet.
**Next Actions:** Initialize NestJS scaffold & Prisma schema.

---

## Milestone 2 — Mobile App Foundation

**Objective:** Flutter project skeleton with design system, navigation shell, and localization in place.

**Planned Tasks**
- [ ] Flutter project scaffold (clean architecture: `data/`, `domain/`, `presentation/` layers per feature)
- [x] State management decision confirmed (Riverpod)
- [ ] Design system (typography, color tokens, spacing, dark/light theme)
- [ ] Bottom navigation shell
- [ ] `flutter_localizations` + Bangla/English toggle, all UI strings externalized from day one
- [ ] API client layer (Dio + interceptors for auth token refresh)

**Current Status:** In Progress
**Validation Status:** In Progress
**Date Started:** 2026-08-05
**Date Completed:** —
**Notes:** Feature spec created in `docs/features/mobile-foundation.md`.
**Known Issues:** None yet.
**Next Actions:** Scaffold Flutter clean architecture structure with Riverpod.

---

## Milestone 3 — Authentication & Biometric Security

**Objective:** Full auth flow with biometric gate required for app unlock and payment confirmation.

**Planned Tasks**
- [ ] Email/phone registration + login against NestJS backend
- [ ] Biometric enrollment check (`local_auth`) with secure fallback (device PIN, not app PIN `1234`)
- [ ] Biometric required to unlock app on launch/resume
- [ ] Biometric required to confirm any payment/transaction action
- [ ] Secure local token storage (`flutter_secure_storage`, hardware-backed)
- [ ] Session timeout + auto-lock policy

**Current Status:** Not Started
**Validation Status:** Not Started
**Date Started:** —
**Date Completed:** —
**Notes:** Hardcoded `1234` PIN from the old prototype is explicitly forbidden in the rebuild.
**Known Issues:** None yet.
**Next Actions:** Depends on Milestone 1 auth + Milestone 2 shell.

---

## Milestone 4 — Cards & Mobile Financial Services (MFS)

**Objective:** Digital storage of bank cards and MFS accounts (bKash/Nagad/Upay), architected for future official API integration but functioning as manual/display-only for v1.

**Planned Tasks**
- [ ] Camera scan + OCR auto-fill for physical bank cards (ML Kit, like Google Pay's card scanner)
- [ ] Card data model (tokenized card number, **no CVV persistence**, encrypted expiry/holder data)
- [ ] Card review-and-confirm flow: OCR result editable pre-confirm, **immutable after confirm** (same pattern as ID vault — delete + re-add to change)
- [ ] MFS account model: **static reference only** — account number/name/provider, used to generate a "receive payment" QR code. No balance tracking, no live sync.
- [ ] MFS model built on **adapter pattern** (`MfsProvider` interface) so a real bKash/Nagad/Upay API can be plugged in later without refactoring, even though v1 is reference-only
- [ ] MFS entries also immutable after confirm (delete + re-add to change)
- [ ] Card/MFS carousel UI
- [ ] Explicit in-app disclosure: MFS entries are personal reference info for receiving payments, not a live bank connection
- [ ] **Smart Sync (Android-only):** per-card/per-MFS-account opt-in prompt after adding an account — "Enable automatic transaction & notice detection for this account?"
- [ ] `NotificationListenerService` integration, **allowlisted to the specific linked provider's package name only** — never a blanket listener
- [ ] On-device parsing engine (per-provider template rules) extracting amount, date, reference number, and type (transaction vs. bank notice) from matched notifications
- [ ] Raw notification text is **discarded immediately after parsing** — never transmitted off-device or persisted, only the structured extracted fields are saved (encrypted)
- [ ] Parsed transactions auto-appended to the relevant card/MFS transaction history
- [ ] Parsed notices (loan due, installment due, etc.) auto-created in a **Notices** section, feeding recurring reminders (Milestone 8) until due date passes or user marks resolved
- [ ] iOS fallback: manual transaction/notice entry UI (feature parity via manual input, since Smart Sync is not possible on iOS)
- [ ] Play Store Data Safety section disclosure prepared specifically for Notification Access usage, justified by scoped/on-device-only design

**Current Status:** Not Started
**Validation Status:** Not Started
**Date Started:** —
**Date Completed:** —
**Notes:** Real MFS API access requires official partnership — out of scope until such access exists.
**Known Issues:** None yet.
**Next Actions:** Depends on Milestone 1–3.

---

## Milestone 5 — NID / Passport Secure Document Vault

**Objective:** The highest-security feature of the app. On-device OCR scanning, envelope-encrypted storage, and QR-based controlled sharing of national ID and passport data.

**Planned Tasks**
- [ ] Google ML Kit document scanner integration
- [ ] On-device OCR field extraction (name, DOB, ID number, address, expiry date, etc.)
- [ ] Review-and-edit screen showing OCR results before confirmation
- [ ] **Immutable after confirm** — enforced at API level, not just UI. Only path to change data is delete + re-scan.
- [ ] AI-assisted field validation/correction during the review step (ties into Milestone 7 AI assistant)
- [ ] Envelope-encrypted storage of extracted data (server-side, per-user DEK)
- [ ] Raw scanned image stored encrypted, separately from structured fields
- [ ] "View Scanned Document" — CamScanner-style enhanced view (deskew, contrast, crop) of the raw scan
- [ ] "Print/Share" — one-page PDF laying out the **raw, unmodified scanned image(s)** with a footer label only (e.g. "Personal copy — generated via MyPocket on [date]"); no edits to the document image itself
- [ ] Print/Share requires PIN or biometric re-authentication + explicit confirmation dialog before sharing via WhatsApp/Email
- [ ] Expiry date field tracked in data model; feeds Milestone 8 notification reminders before passport/NID expiry
- [ ] Biometric-gated viewing (separate re-auth even within an unlocked session)
- [ ] In-app legal disclosure: personal encrypted storage, not a government-affiliated NID system
- [ ] Security audit specifically for this module before release

**Current Status:** Not Started
**Validation Status:** Not Started
**Date Started:** —
**Date Completed:** —
**Notes:** This module carries the highest legal and security risk in the app. No shortcuts.
**Known Issues:** None yet.
**Next Actions:** Depends on Milestone 1 encryption service + Milestone 3 biometric gate.

---

## Milestone 6 — Certificates & Transit Passes

**Objective:** Rebuild the certificate manager and transit pass features from the old prototype with the new secure architecture.

**Planned Tasks**
- [ ] Certificate category/upload system — same category structure as original (Academic w/ SSC-PhD subcategories, Olympiad, Quiz, Business, Sports, General Skills), rebuilt with encrypted storage
- [ ] Transit card management (rebuilt, balances tied to backend, not raw SharedPreferences)
- [ ] Full QR/NFC-simulated boarding flow retained — confirmed as a kept daily-utility feature, not deprioritized

**Current Status:** Not Started
**Validation Status:** Not Started
**Date Started:** —
**Date Completed:** —
**Notes:** Lower priority than Milestones 3–5, but full scope retained per stakeholder confirmation.
**Known Issues:** None yet.
**Next Actions:** Scheduled after core security features ship.

---

## Milestone 7 — AI Assistant Integration

**Objective:** Ship the AI assistant, "Moon," in two phases — document-scan-assist first, then a full conversational + voice assistant capable of answering questions about the user's own stored data.

**Planned Tasks**
- [ ] Backend AI proxy service (API key never shipped client-side)
- [ ] Phase 1: OCR field validation/correction assistant during NID/Passport/card scanning
- [ ] Phase 2: Conversational assistant — **tool-calling architecture**: LLM has access to scoped tools (`get_upcoming_dues()`, `get_recent_transactions()`, etc.) that query the backend using the authenticated user's session only
- [ ] Data exposed to the LLM is always **masked/summarized** (e.g., "Card ending 1234, Tk 5,000 due Aug 20") — full card numbers, NID/Passport numbers are never sent to the LLM provider
- [ ] **Floating chat bubble**, accessible from anywhere in the app
- [ ] **Hybrid behavior**: reactive (answers on demand) + proactive (unprompted nudges — due payments, Smart Sync-detected transactions, expiry reminders)
- [ ] **Animated mascot/buddy "Moon"** (Lottie-based) — idle/thinking/celebrating/alerting states, used in onboarding and as the chat bubble icon
- [ ] **Voice input:** on-device speech-to-text (Bangla + English), quality/coverage may vary by device for Bangla — flagged as a known platform limitation, not a MyPocket bug
- [ ] **Voice output:** on-device text-to-speech, full spoken conversation (Bangla + English)
- [ ] **Wake word ("Hey Moon"):**
  - Android: true background/lock-screen wake-word detection via foreground service + on-device wake-word engine (e.g. Picovoice Porcupine), **opt-in and OFF by default**
  - iOS: foreground-only wake-word (app must be open) — hard OS restriction, no background alternative exists
  - Wake-word matching itself is fully on-device; no audio is transmitted anywhere until a query begins after the wake word fires
  - Auto-suspends on low battery / Battery Saver mode; resumes on charging or normal battery
  - Implemented as a **remote feature flag** so background listening can be disabled server-side without an app resubmission if Play Store review requires it
- [ ] Play Store Data Safety + permissions declaration prep for background microphone/foreground service usage
- [ ] Rate limiting / abuse prevention on AI endpoints (cost control)

**Current Status:** Not Started
**Validation Status:** Not Started
**Date Started:** —
**Date Completed:** —
**Notes:** Background wake-word on Android carries real Play Store review risk and battery cost even with mitigations — the feature flag kill switch exists specifically to de-risk this. iOS cannot support background wake-word under any implementation; this is an OS-level restriction, not an engineering gap.
**Known Issues:** None yet.
**Next Actions:** Phase 1 depends on Milestone 5 scanner being functional. Voice/wake-word work depends on core chat (tool-calling) being functional first.

---

## Milestone 8 — Notifications & Sync

**Objective:** Push notifications and cross-device sync via the new backend (replacing Firebase Cloud Messaging dependency).

**Planned Tasks**
- [ ] Notification service (FCM can be retained for push delivery even with custom backend, or self-hosted alternative evaluated)
- [ ] Sync strategy for multi-device use
- [ ] Recurring reminder engine for Smart Sync-detected notices (loan/installment due) and NID/Passport expiry dates — reminds until dismissed or resolved
- [ ] Manual notice entry also feeds this same reminder engine (iOS parity path)

**Current Status:** Not Started
**Validation Status:** Not Started
**Date Started:** —
**Date Completed:** —
**Notes:** —
**Known Issues:** None yet.
**Next Actions:** Scheduled after core features.

---

## Milestone 9 — QA, Security Audit & Performance

**Objective:** Full regression pass, security review, and performance validation before any release candidate.

**Planned Tasks**
- [ ] Functional test pass across all modules
- [ ] Security audit (encryption implementation, key handling, biometric bypass attempts, injection testing)
- [ ] Performance profiling (startup time, scan latency, memory leaks)
- [ ] Accessibility pass (Bangla font rendering, screen reader support)

**Current Status:** Not Started
**Validation Status:** Not Started
**Date Started:** —
**Date Completed:** —
**Notes:** —
**Known Issues:** None yet.
**Next Actions:** Scheduled before release milestone.

---

## Milestone 10 — Release Preparation & Store Publishing

**Objective:** Prepare and submit to Google Play and Apple App Store.

**Planned Tasks**
- [ ] Production hosting migration (Oracle Cloud Always-Free deployment)
- [ ] App signing, store listings, privacy policy, terms of service
- [ ] Play Store data safety disclosures (critical given NID/financial data handling)
- [ ] Apple App Store review prep (financial + ID data apps face extra scrutiny)
- [ ] CHANGELOG.md finalized for v1.0.0
- [ ] Release branch cut per GitFlow (`release/1.0.0`)

**Current Status:** Not Started
**Validation Status:** Not Started
**Date Started:** —
**Date Completed:** —
**Notes:** Store review for apps handling government ID + financial data typically takes longer — budget extra time.
**Known Issues:** None yet.
**Next Actions:** Final milestone — depends on all prior milestones.

---

## Open Decisions Requiring Your Sign-Off

| # | Decision | Recommendation | Status |
|---|----------|----------------|--------|
| 1 | State management: GetX vs Riverpod/Bloc | Riverpod or Bloc — better testability, compile-time safety, wider industrial adoption | **Resolved: Riverpod** |
| 2 | ORM: TypeORM vs Prisma | Prisma — better DX, type-safety, migration tooling | **Resolved: Prisma** |
| 3 | Notification delivery: keep FCM vs self-hosted | Keep FCM for push delivery only (not data storage) — reliable, free, doesn't touch sensitive data | Pending |
| 4 | GitFlow branch setup approval | Create `develop` + `feature/milestone-0-scaffolding` | **Resolved: Approved** |
