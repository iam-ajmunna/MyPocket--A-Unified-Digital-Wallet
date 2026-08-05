# AGENTS.md — MyPocket AI Agent Operating Instructions

This document defines how any AI coding agent (Claude, or any other agent) must operate while working on the MyPocket codebase. It is binding for all sessions, including sessions that have no memory of prior ones. **Read this file in full before touching any code.**

---

## 1. Prime Directive

You are acting as a Senior Software Engineer / Principal Architect on a **production financial + government-ID application** headed for public release. Every decision must be made as if a security auditor, a real user's identity data, and a real user's money depend on it — because they will.

Never take shortcuts on:
- Encryption of sensitive data (NID, Passport, card numbers)
- Authentication and session handling
- Input validation
- Irreversible git actions (see Section 6)

---

## 2. Mandatory Workflow: Document Before You Build

**This is the most important rule in this file.** Context is not guaranteed to persist between sessions. Documentation is the memory system.

For **every feature or module**, before writing implementation code:

1. Check if `docs/features/<feature-name>.md` already exists.
   - If it exists, **read it fully first** — it is the source of truth for that feature's design, decisions, and current state.
   - If it does not exist, **create it** before writing any code.

2. The feature doc must contain:
   ```markdown
   # Feature: <Name>

   ## Purpose
   What this feature does and why it exists.

   ## Scope (v1)
   What is explicitly included and excluded in this iteration.

   ## Data Model
   Schemas, encryption requirements, field sensitivity classification.

   ## API Contract
   Endpoints, request/response shapes, auth requirements.

   ## Security Considerations
   What could go wrong; how it's mitigated.

   ## Dependencies
   Other modules/features this relies on.

   ## Implementation Notes
   Decisions made during build, trade-offs, anything a future session needs to know.

   ## Status
   Not Started / In Progress / In Review / Complete
   ```

3. As you implement, **update the feature doc in real time** — not after the fact. If you make a design decision mid-implementation (e.g., "switched from X to Y because Z"), write it down immediately.

4. When a feature is complete, update:
   - The feature doc's `Status` field
   - `docs/IMPLEMENTATION_STATUS.md` (the corresponding milestone/checklist item)
   - `CHANGELOG.md` if user-facing behavior changed

**Never implement a non-trivial feature "in your head" and explain it only in chat.** The explanation belongs in the repo, in markdown, next to the code it describes. A future agent session — or a human engineer — must be able to reconstruct full context from the repo alone.

---

## 3. Planning Before Coding

Do not begin implementing a milestone or feature until:
1. The relevant `docs/features/<feature>.md` exists and is reviewed
2. Risks are identified and noted in that doc
3. If the feature touches encryption, auth, or NID/Passport/card data — the Security Considerations section is filled in **before** implementation, not after

For large or ambiguous asks, break the work into milestones and confirm the plan before writing code, per `IMPLEMENTATION_STATUS.md`.

---

## 4. Architecture Rules

- **Mobile (Flutter):** Clean architecture per feature — `data/`, `domain/`, `presentation/` layers. No business logic in widgets.
- **Backend (NestJS):** One module per domain (`auth`, `users`, `cards`, `documents`, `mfs`, `transit`, `certificates`, `ai`). No cross-module direct DB access — go through services.
- **MFS providers** (bKash/Nagad/Upay) must go through the `MfsProvider` adapter interface. Never hardcode a specific provider's logic into a generic service.
- **No God files.** If a file exceeds ~300 lines or handles more than one clear responsibility, split it.
- **No secrets in code, ever.** All secrets via environment variables, never committed. Add anything sensitive to `.gitignore` before it's ever created.

---

## 5. Security Non-Negotiables

- Never store CVV, ever, in any form, anywhere.
- Never log NID numbers, passport numbers, card numbers, or biometric data — not even at debug level.
- All sensitive fields (NID, Passport, full card number) must go through the envelope encryption service before persistence. No exceptions, no "just for now."
- Biometric gate is required for: app unlock, viewing NID/Passport details, confirming any payment action.
- Any QR code containing personal data must be a time-limited, revocable reference token — never a QR encoding raw NID/Passport/card data directly.
- If you are unsure whether something counts as sensitive data, treat it as sensitive.
- **Smart Sync / Notification Listener code must never expand scope beyond the per-account allowlist.** Any implementation that reads notifications from apps outside the user's explicitly linked accounts is a critical bug, not a feature. Raw notification text must never be persisted to disk or transmitted to the backend — only the structured, parsed fields.
- **The "Moon" assistant's LLM must never receive raw sensitive fields.** Full card numbers, NID numbers, and passport numbers are never included in a prompt or tool result — only masked/summarized values assembled by the backend (e.g. last-4-digits, rounded amounts, dates). If a new tool is added for the assistant, this masking rule applies to it by default; do not add an unmasked field "temporarily" or "for debugging."
- **Assistant tool calls are always scoped server-side to the authenticated session's user ID.** Never implement a tool where the LLM supplies or influences which user's data is fetched.
- **Wake-word audio must never leave the device for the wake-word match itself.** Only after "Hey Moon" is detected on-device may a query begin being processed. Background wake-word listening (Android) must remain behind its remote feature flag and default to OFF until the user explicitly opts in.

---

## 6. Git & GitFlow — Irreversible Actions Require Explicit Approval

Branch structure:
- `main` — stable, production-released code only
- `develop` — integration branch for completed, tested features
- `feature/<name>` — one feature per branch, branched from `develop`
- `release/<version>` — release stabilization, branched from `develop`
- `hotfix/<name>` — urgent production fixes, branched from `main`

Rules:
- Never push to `main` or `develop` directly.
- Never merge a `feature/*` branch without explicit user approval.
- Never create a `release/*` branch, tag, or push to any remote without explicit user approval.
- Before requesting approval to push/merge, always provide: summary of work done, files changed, tests performed, docs updated, known issues, and recommended next step.
- Commit messages follow Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`, `test:`, `perf:`, `chore:`, etc.), one logical unit of work per commit.

---

## 7. Definition of Done

A task is only "done" when:
- [ ] Code implemented and self-reviewed for bugs, security issues, and architectural consistency
- [ ] Relevant `docs/features/<feature>.md` created/updated
- [ ] `docs/IMPLEMENTATION_STATUS.md` updated
- [ ] Manually or automatically tested (build passes, feature functions, edge cases considered)
- [ ] No secrets, no hardcoded test credentials (e.g. no repeat of the old `1234` PIN pattern), no dead code left behind

If any of these are missing, the task is **not** complete — do not report it as such.

---

## 8. When in Doubt

- If a request would touch sensitive data, auth, or irreversible git operations in a way not explicitly covered above — stop and ask the user rather than assuming.
- If two reasonable implementation paths exist, briefly state the trade-off and recommend one rather than silently picking.
- Never mark a checklist item complete in any doc unless it was actually implemented and verified.
