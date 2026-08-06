# Feature: Design System & Token Architecture (DESIGN_AGENTS.md Standard)

## Purpose
Build a commercial-grade fintech design system and token architecture for MyPocket adhering to `DESIGN_AGENTS.md`. Provides first-class Light and Dark themes, bilingual typography (Manrope + Noto Sans Bengali), 4pt/8pt spacing, corner radius scales, elevation tokens, and motion curves via Flutter `ThemeExtension` classes.

## Scope
1. **Token Extensions (`lib/core/theme/`)**:
   - `app_colors.dart`: Primary Trust Blue/Teal (`#0EA5E9` / `#0284C7`), Bangladesh Green accent (`#059669`), semantic status colors, light & dark ramps.
   - `app_typography.dart`: Manrope (English/numbers) + Noto Sans Bengali (Bangla), tabular monospaced figure formatting for balances.
   - `app_spacing.dart`: 4pt/8pt spacing scale (xxs: 4, xs: 8, sm: 12, md: 16, lg: 24, xl: 32, xxl: 48).
   - `app_radius.dart`: Corner radius scale (sm: 8, md: 12, lg: 20, xl: 28, full: 999).
   - `app_elevation.dart`: Soft layered shadow tokens for fintech card depth.
   - `app_motion.dart`: Standard durations (micro: 120ms, transition: 250ms, screen: 350ms) and motion curves.
2. **Theme Assembly (`app_theme.dart`)**:
   - `AppTheme.lightTheme` & `AppTheme.darkTheme` with full extension wiring.
3. **Screen Refactoring**:
   - Refactor `CleanDashboardScreen`, `CardsMfsScreen`, `DocumentsVaultScreen`, `CertificatesVaultScreen`, `TransitVaultScreen`, `MoonChatScreen`, `NotificationsCenterScreen`, `CleanLoginScreen`, and `CleanRegisterScreen` to use design tokens exclusively via `Theme.of(context)`.

## UI/UX Design
- **Primary User Goal**: Provide a trusted, commercial-grade digital wallet experience benchmarked against Wise, Revolut, and Google Wallet.
- **Accessibility**: 44×44dp touch targets, dynamic dynamic font dynamic dynamic dynamic dynamic scaling support, tabular numbers.
- **Themes**: System theme default with light & dark mode toggle.

## Security Considerations
- Pure UI tokens layer — zero data storage or network calls.

## Status
Complete — 2026-08-06

