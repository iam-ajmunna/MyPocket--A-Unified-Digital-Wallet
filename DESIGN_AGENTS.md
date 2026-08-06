# DESIGN_AGENTS.md — MyPocket UI/UX, Motion & Frontend Architecture Instructions

Companion to `AGENTS.md` (engineering rules) and `ARCHITECTURE.md` (system design). This document is binding for any agent working on MyPocket's **Flutter UI, design system, animation, or frontend component architecture**. Read this file in full before designing or implementing any screen.

---

## 1. Mission

MyPocket must feel like a premium, trustworthy commercial product from the first screen — comparable to **Google Wallet, Samsung Wallet, Wise, and Revolut** — not a student project. It holds people's money references and government ID data; the UI's job is to make users feel that is being handled with precision and care.

Every design decision must improve one or more of: usability, readability, learnability, accessibility, efficiency, consistency, performance, or visual quality. Nothing is added purely for decoration.

---

## 2. Visual Identity System

### Color
- **Primary — Trust Blue/Teal:** the dominant brand color across primary actions, active states, and the assistant. Signals reliability and calm, consistent with global fintech convention (Wise, Stripe, Revolut all use blue/teal-family primaries for this reason).
- **Secondary accent — Deep Bangladesh Green:** used sparingly (highlights, success states, select branding moments) to give MyPocket local identity without tipping into novelty-app territory.
- **Semantic colors:** distinct, accessible tokens for success, warning, error, and info — never reuse brand color for status meaning.
- **Neutral scale:** a full gray ramp for both light and dark themes — text, surfaces, borders, dividers.
- **Both light and dark themes are first-class**, not an afterthought. Dark mode isn't just "premium aesthetic" here — Bangladesh's strong outdoor sunlight makes a well-tuned **light** theme equally essential for real daily readability. Default to system theme, user-overridable.

### Typography
- **English/Latin + numerals:** Manrope (carried forward from the original prototype's identity — consistent, geometric, highly legible for financial figures).
- **Bangla:** Noto Sans Bengali — full glyph coverage and a weight range that pairs cleanly with Manrope's weights, avoiding the mismatched-font-pairing problem common in Bangla/English bilingual apps.
- Numerals (balances, amounts, card numbers) always render in a tabular/monospaced-figure style so digits don't shift width as they animate or update.

### Spacing, Radius, Elevation
- 4pt/8pt spacing scale — no arbitrary spacing values in any component.
- Consistent corner-radius scale (e.g. sm/md/lg/full) applied predictably by component type (cards use one radius tier, buttons another, sheets another).
- Elevation via layered soft shadows and subtle surface tinting — reserve any glassmorphism/blur for a small number of intentional moments (e.g. the Moon assistant panel), never on screens displaying financial figures or ID data, where blur can reduce legibility and undermine the "precision" feeling this app needs to project.

All of the above are implemented as **design tokens** (Section 8), never hardcoded values scattered through widget code.

---

## 3. Component & Card Design Specs

MyPocket's cards are the core visual language of the app. Each card type has a distinct but *family-consistent* treatment:

| Card Type | Key Requirements |
|---|---|
| **Bank Card (carousel)** | Realistic card proportions, masked number, bank-brand color cues, subtle parallax/tilt on scroll, balance visible only after biometric confirmation on sensitive screens |
| **MFS Reference Card** | Provider branding (bKash/Nagad/Upay visual language, respectfully distinct from MyPocket's own palette so users instantly recognize provider vs. app chrome), prominent "Show QR to receive" action |
| **NID/Passport Card** | Flip interaction preserved from the original concept (front/back), **locked visual state after confirmation** — no edit affordance anywhere in this card's UI once confirmed, only "View Scanned Document" and "Delete" actions are present |
| **Certificate Card** | Category-color-coded, compact grid-friendly, supports image thumbnail |
| **Transit Card** | Gradient-customizable per transit type, QR boarding action prominent |
| **Moon Assistant Bubble/Panel** | The one place glassmorphism/frosted treatment is appropriate — floating, layered, clearly "above" the app's normal content plane |

All cards share: layered elevation on interaction, consistent internal padding from the spacing scale, and a status-indicator pattern (dot/badge) reused identically across card types so users learn the pattern once.

---

## 4. Motion Design Rules (Flutter-specific)

Motion must explain a state change, guide attention, or provide feedback — never decoration for its own sake.

- Prefer `Transform`/`Opacity`-driven animations (GPU-accelerated) over layout-triggering rebuilds.
- Standard durations: micro-interactions 100–150ms, component transitions 200–300ms, full-screen transitions 300–400ms. Nothing in the app should feel sluggish or bouncy-to-excess.
- Use `Hero` animations for card → detail-screen transitions (e.g. tapping a bank card expands into its detail view) — this is the single highest-impact "premium feel" animation in a wallet app.
- Loading states use skeleton placeholders matching the eventual content's shape, not generic spinners, wherever content layout is predictable.
- Success confirmations (payment logged, document confirmed) get a distinct, satisfying but brief animation — this is a moment users will see often; it should feel rewarding without becoming annoying on repeat.
- **Reduced motion is mandatory**: respect `MediaQuery.of(context).disableAnimations`; when set, all non-essential motion is removed or replaced with instant/cross-fade transitions, never fully removing state-communicating feedback.

---

## 5. Moon — Mascot Design Guidelines

Moon is **friendly-professional**: warm and characterful, not cartoonish or childish. Reference point: Duolingo's owl or Slack's mascot — personality without undermining the "this app holds my ID and money" trust requirement.

Required animation states (each a distinct Rive/Lottie asset):
- **Idle** — subtle, ambient, non-distracting (used when the chat bubble is present but inactive)
- **Listening** — active state while wake-word/voice input is being captured
- **Thinking** — while a query is being processed (ties to perceived-performance motion principle — this state matters a lot given Moon's tool-calling round-trip)
- **Speaking** — while TTS output is playing
- **Celebrating** — positive confirmations (payment logged, document confirmed)
- **Alerting** — proactive nudges (payment due, expiry approaching) — noticeable without being alarming; this is a financial reminder, not an error

**Engine recommendation:** use **Rive** rather than Lottie specifically for Moon. Moon's states are reactive and interruptible (e.g., "listening" can be cut short by "thinking" mid-animation) — Rive's state-machine model handles these transitions natively, where Lottie (built for linear one-shot playback) would require more workaround code. Lottie remains fine, and preferable for simpler one-shot animations elsewhere in the app (e.g. onboarding illustrations).

---

## 6. Accessibility Standards

- All interactive elements meet a minimum 44×44dp touch target.
- Full screen reader support (TalkBack/VoiceOver) — every icon-only button has a semantic label; financial figures are read in full, not abbreviated, when accessed via screen reader.
- Color is never the only status indicator — pair with icon or text.
- Contrast ratios meet WCAG AA minimum across both themes, checked specifically for text over card imagery/gradients (bank card numbers, transit gradients).
- Bangla text must be tested at larger system font-scale settings — Bangla glyphs can behave differently than Latin text under dynamic type scaling; this must be verified, not assumed to "just work" because English does.
- Reduced motion (Section 4) and high-contrast mode are both real settings this app must visibly respect, not silently ignore.

---

## 7. Frontend Architecture Standards

- Widget structure follows the clean-architecture presentation layer defined in `ARCHITECTURE.md`: `features/<feature>/presentation/{screens, widgets, providers}`.
- No widget file exceeds ~300 lines or mixes more than one clear responsibility — split into smaller composable widgets.
- Shared, cross-feature components (buttons, cards, inputs, the design token system itself) live in `lib/core/widgets/` and `lib/core/theme/`, never duplicated per-feature.
- Performance discipline: `const` constructors wherever possible, `RepaintBoundary` around animated/expensive widgets (especially Moon and card carousels), `ListView.builder`/lazy construction for any scrollable list, avoid unnecessary `setState`/rebuild scope — this matters more than usual given this app runs a background wake-word listener that must not compete with UI thread performance.

---

## 8. Design Tokens — Implementation Pattern

Design tokens are implemented as Flutter `ThemeExtension` classes, not scattered constants:

```
lib/core/theme/
├── app_colors.dart        # Color tokens, light + dark ThemeExtension
├── app_typography.dart    # Text style scale (Manrope + Noto Sans Bengali)
├── app_spacing.dart       # Spacing scale constants
├── app_radius.dart        # Corner radius scale
├── app_elevation.dart     # Shadow/elevation tokens
├── app_motion.dart        # Standard durations/curves
└── app_theme.dart         # Assembles the above into ThemeData (light + dark)
```

Any new screen or component pulls values from `Theme.of(context).extension<...>()` — a raw hex color, raw duration number, or raw spacing value appearing directly in feature code during review is a defect, not a style nitpick.

---

## 9. UX Review Process — Mandatory Before Implementing Any Screen

Before building a screen, the agent must explicitly reason through and briefly note:
1. What is the user's goal on this screen, and is the primary action unambiguous?
2. Can the workflow be simplified — is every field/step here necessary?
3. Does the information hierarchy make the most important thing (balance, due date, confirmation state) the most visually prominent thing?
4. Where does motion help here, if anywhere — and where would it just be decoration?
5. Does this screen work for both a first-time and a daily-repeat user without feeling repetitive or slow on the hundredth use?
6. Accessibility: does this screen work with a screen reader, at large text scale, and in Bangla layout, without redesign?

If a simpler or clearer approach exists than what was asked for, propose it before building — don't silently build the literal request if a better pattern is evident, same as the engineering agent's standing instruction.

---

## 10. Document-First Workflow (extends AGENTS.md Section 2)

Every screen/feature's `docs/features/<feature>.md` (defined in `AGENTS.md`) must include a **UI/UX Design** subsection before implementation begins:

```markdown
## UI/UX Design
- User goal & primary action
- Key states (empty, loading, error, success, populated)
- Motion notes (what animates, why)
- Accessibility notes specific to this screen
- Design tokens used (confirm no raw values introduced)
```

This keeps design reasoning in the repo, next to the code — not only explained in a chat conversation that a future session won't have access to.

---

## 11. Definition of Done — Design/UI Tasks

A UI task is only complete when:
- [ ] Built using design tokens exclusively (no raw colors/spacing/durations)
- [ ] Both light and dark theme verified
- [ ] Reduced-motion behavior verified
- [ ] Screen reader labels present and verified
- [ ] Bangla layout verified (not just English)
- [ ] Feature doc's UI/UX Design subsection completed
- [ ] Animations run smoothly (no jank) on a mid-range device profile, not just a high-end simulator

---

## 12. Benchmark Reframing

Note for this project specifically: MyPocket should be benchmarked against **fintech/wallet products** (Google Wallet, Samsung Wallet, Wise, Revolut, N26, Stripe's consumer-facing surfaces) rather than monitoring/dashboard tools like Grafana or Datadog — those are excellent references for information-dense control-room software, but MyPocket is a daily-use consumer wallet, and the design bar is warmth-plus-precision, not density-plus-control.
