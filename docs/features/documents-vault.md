# Feature: Secure Document Vault (NID & Passport)

## Purpose
The Secure Document Vault allows users to store, manage, and view sensitive identity documents — specifically Bangladeshi National ID (NID) and International Passport details — with military-grade envelope encryption (AES-256-GCM) and mandatory biometric authentication gates.

## Scope (v1)
- **Document Types Supported**:
  - Bangladeshi NID (National ID Number, Full Name, DOB, Father/Mother Name, Address, NID Front/Back Image metadata).
  - International Passport (Passport Number, Full Name, Country, DOB, Expiry Date, Issue Date, MRZ string).
- **Backend Enclosure**:
  - NestJS `DocumentsModule` providing `/api/v1/documents` CRUD endpoints.
  - Envelope Encryption via `CryptoService` for all sensitive identity fields before database persistence.
- **Mobile Vault UI**:
  - Riverpod `documentsNotifierProvider`.
  - Masked document previews by default (`NID: 1994•••••••1234`).
  - Mandatory `BiometricGate` verification before unmasking raw NID/Passport numbers or exporting QR codes.
  - Time-limited revocable QR code token generation (zero raw personal data encoded directly in QR).

## Data Model (Prisma Schema)
```prisma
enum DocumentType {
  NID
  PASSPORT
}

model Document {
  id              String       @id @default(uuid())
  userId          String
  user            User         @relation(fields: [userId], references: [id], onDelete: Cascade)
  type            DocumentType
  documentNumber  String       // Encrypted envelope ciphertext
  documentData    String       // Encrypted envelope JSON payload (DOB, Names, Addresses, Expiry)
  isVerified      Boolean      @default(false)
  createdAt       DateTime     @default(now())
  updatedAt       DateTime     @updatedAt

  @@index([userId])
}
```

## API Contract
- `GET /api/v1/documents`: List user's encrypted documents (returns masked previews).
- `POST /api/v1/documents/nid`: Store NID document (encrypts sensitive fields before DB save).
- `POST /api/v1/documents/passport`: Store Passport document (encrypts sensitive fields before DB save).
- `POST /api/v1/documents/:id/reveal`: Requires valid session + post-biometric confirmation token to return decrypted payload.
- `DELETE /api/v1/documents/:id`: Remove document from vault.

## Security Considerations
- **Envelope Encryption**: All sensitive identity fields (NID Number, Passport Number, DOB, Addresses) are encrypted using user-specific DEKs via `CryptoService`.
- **Zero Raw Log Policy**: NID and Passport numbers are strictly forbidden from being logged at any log level.
- **Biometric Gate**: Unmasking document details or generating sharing QR codes requires on-device biometric check (`local_auth`).
- **QR Code Tokens**: Sharing QR codes generate short-lived, revocable reference UUID tokens (never raw identity strings).

## Dependencies
- Backend: `PrismaService`, `CryptoService`, NestJS `AuthGuard`.
- Mobile: `flutter_riverpod`, `Dio`, `flutter_secure_storage`, `local_auth`.

## Implementation Notes
- Created during Milestone 5.
- Adheres to `AGENTS.md` Section 5 Security Non-Negotiables.

## Status
Complete — Backend: NestJS DocumentsModule with AES-256-GCM envelope encryption. Mobile: Clean Architecture (Entity → Repository → Provider → Screen) with biometric reveal gate.
