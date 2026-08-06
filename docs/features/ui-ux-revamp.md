# Feature: Ultra-Premium Mobile App UI/UX Revamp

## Purpose
Elevate the MyPocket Flutter mobile application to an ultra-premium, state-of-the-art visual experience with rich color palettes, glassmorphism cards, micro-animations, 3D flip card interactions, dynamic dark mode accents, and smooth view transitions across all screens.

## Design System & Tokens
- **Theme Palette**:
  - Backgrounds: Dark Slate (`#0B0F19`), Midnight (`#0F172A`), Surface Glass (`#1E293B` with opacity & border glow).
  - Primary Accents: Electric Indigo (`#6366F1`), Glowing Purple (`#A855F7`), Neon Cyan (`#06B6D4`), Emerald Green (`#10B981`).
- **Typography**: Google Fonts (Poppins / Inter) with distinct font hierarchy.
- **Glassmorphism**: Soft background blur effects, semi-transparent container fills, and subtle border gradient highlights.
- **Micro-Animations**:
  - Interactive 3D flip card effect (`flip_card`) for Bank Cards (front: chip/last-4, back: encrypted details view).
  - Animated pulsing floating assistant bubble.
  - Shimmer/skeleton loading indicators.
  - Smooth page transitions (`page_transition`).

## Screen Revamp Scope

1. **Clean Dashboard (`CleanDashboardScreen`)**:
   - Animated greeting header card with gradient mesh & live clock badge.
   - Quick action bar: "Scan ID/Card", "Quick Pay QR", "Transit Boarding", "Moon AI".
   - Vault Grid: Modern glass cards with elevated shadows, glowing icon badges, and micro-hover scaling.
   - Floating Moon Assistant bubble with subtle pulse ring.

2. **Cards & MFS Vault (`CardsMfsScreen`)**:
   - Realistic 3D bank card widgets with brand gradients (Visa, Mastercard, Amex, City Bank, EBL).
   - Interactive flip card to view back side securely.
   - Brand-tailored MFS wallet cards (bKash pink, Nagad orange, Upay blue).
   - Interactive payment QR bottom sheet with countdown timer and copy-to-clipboard.

3. **Identity & Documents Vault (`DocumentsVaultScreen`)**:
   - Realistic Bangladesh NID & Passport visual card previews.
   - Lock overlay with biometric authentication trigger.
   - Smooth reveal animation upon successful biometric unlock.

4. **Transit Passes Vault (`TransitVaultScreen`)**:
   - Metro/Bus pass gradient cards with live balance progress ring.
   - Boarding QR sheet with high-contrast QR display & refresh animation.

5. **Certificates Vault (`CertificatesVaultScreen`)**:
   - Academic badge cards with category ribbon indicators.
   - Filter chips with glowing selection states.

6. **Moon AI Chat (`MoonChatScreen`)**:
   - Glass chat bubbles, animated typing dots, and voice mic wave indicator.

## Security Considerations
- Ensure no sensitive raw data is displayed on front cards without explicit user tap / biometric check.
- Biometric gate preserved for NID / Passport detail reveals.

## Status
Complete — 2026-08-06
