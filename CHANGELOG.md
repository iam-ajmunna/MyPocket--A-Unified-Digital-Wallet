# Changelog

All notable changes to the **MyPocket — A Unified Digital Wallet** project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] - 2026-08-06

### Major Release (v2.0.0 Roadmap Complete)

#### Added
- **Google ML Kit Document Scanner & On-Device OCR**:
  - `ocr_parser_service.dart`: Automated pattern parsing for Bangladesh Smart NID (10 digits), Old NID (17 digits), and Passport MRZ.
  - `ocr_scanner_screen.dart`: Camera frame alignment overlay with live scanning line animation and 1-tap auto-fill pre-confirm review.
- **PDF Exporter & Encrypted Document Sharing**:
  - `document_pdf_service.dart`: Password-protected, watermarked PDF generation for NID, Passport, Transit Passes, and Academic Certificates.
  - Instant PDF printing and encrypted file sharing via `share_plus` and `printing`.
- **"Hey Moon" Background Wake-Word Engine**:
  - `wake_word_service.dart`: Hands-free background voice keyword detection service triggering Moon AI assistant automatically.
- **Live MFS Sandbox Gateway Integration**:
  - `mfs-sandbox.service.ts`: NestJS mock gateway endpoints (`/api/v1/mfs/sandbox/cashout` and `/api/v1/mfs/sandbox/sendmoney`) for bKash & Nagad transactions.
- **Commercial UI/UX Design System**:
  - Proportional original brand logo alignment, Poppins typography, and dark slate glassmorphic surface tokens.

---

## [1.0.0] - 2026-08-06

### Initial Production Release (Milestones 0 - 10 Complete)

#### Added
- **Architecture & Backend Foundation**:
  - NestJS modular backend architecture (`auth`, `users`, `cards`, `mfs`, `documents`, `certificates`, `transit`, `ai`, `notifications`, `sync`).
  - Prisma ORM migration with PostgreSQL data modeling.
  - Rate limiting (`ThrottlerGuard`), CORS, and Helmet configuration.
- **Security & Envelope Encryption**:
  - Dual-layer AES-256-GCM envelope encryption (`CryptoService`) — KEK (server-held) wraps user-specific DEK.
  - Zero plain-text persistence of NID numbers, Passport data, card numbers, or CVVs.
  - Server-side JWT authentication & refresh token rotation (`JwtAuthGuard`).
- **Cards & MFS Vault**:
  - Bank card vault with last-4 masking and encrypted cardholder details.
  - MFS adapter interface supporting bKash, Nagad, and Upay.
  - Time-limited, revocable QR reference tokens for payment flows.
- **Identity & Documents Vault**:
  - NID and Passport document vault with field-level encryption.
  - Document detail viewer protected behind biometric authentication (`local_auth`).
- **Certificates & Transit Passes**:
  - Certificate manager with 6 categories (Academic SSC→PostDoc, Olympiad, Quiz, Business, Sports, Skills).
  - Transit pass manager with balance recharge, expiry alerts, and revocable QR boarding token generation (`qr_flutter`).
- **AI Companion "Moon"**:
  - Gemini 2.0 Flash integration with tool-calling architecture (`get_wallet_summary`, `get_certificates`, `get_transit_passes`, `get_documents_summary`).
  - Strict server-side scoping (`req.user.id`) ensuring LLM never accesses unmasked PII.
  - Speech-to-Text (STT) input and Text-to-Speech (TTS) playback in full-screen dark glassmorphism chat UI (`MoonChatScreen`).
  - Floating action bubble overlay (`MoonFloatingBubble`) on Dashboard.
- **Notifications & Multi-Device Sync**:
  - Notification center with category filter chips (All, Expiries, Dues, Smart Sync, Custom), swipe-to-dismiss, and mark-as-read.
  - Automated vault scanner for low transit balances (< 100 Tk) and document expiries.
  - Custom reminder creation bottom sheet.
  - AppBar Bell icon with real-time unread badge counter.
- **DevOps & Production Packaging**:
  - Production multi-stage `Dockerfile` and `docker-compose.prod.yml`.
