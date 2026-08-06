# Feature: MyPocket v2 Roadmap & Advanced Engine

## Purpose
Complete all advanced v2 capabilities of MyPocket, including camera-based OCR scanning, PDF document exporting & encrypted sharing, "Hey Moon" background wake-word voice activation, and live MFS payment gateway sandbox integration.

## Scope (v2)
1. **Google ML Kit Document Scanner & OCR Engine**:
   - Camera frame alignment overlay.
   - Regex-driven parser for Bangladesh Smart NID (10 digits), Old NID (17 digits), and Passport MRZ.
   - 1-tap auto-fill pre-confirm review.

2. **PDF Exporter & Encrypted Sharing**:
   - PDF generator for NID, Passport, Transit Passes, and Certificates.
   - Watermarked security layout with optional password protection.

3. **"Hey Moon" Background Wake-Word Detection**:
   - On-device keyword detection service.
   - Auto-triggers Moon AI Assistant voice conversation hands-free.

4. **Live MFS Sandbox Gateway Integration**:
   - NestJS endpoints for bKash/Nagad cashout & send money sandbox triggers.
   - Real-time balance updates & transaction history callbacks.

## Security Considerations
- Raw camera frames and OCR text processed entirely on-device — zero unencrypted raw images sent to backend.
- Generated PDF documents follow envelope encryption rules when stored or transmitted.
- Wake-word audio processed strictly locally on-device.

## Status
Complete — 2026-08-06
