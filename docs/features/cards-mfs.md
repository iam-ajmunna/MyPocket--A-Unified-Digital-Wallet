# Feature: Cards & Mobile Financial Services (MFS Vault) (Milestone 4)

## Purpose
Enables users to digitize and manage their bank cards and Mobile Financial Services (MFS: bKash, Nagad, Upay) in a secure, encrypted wallet. Card details and MFS entries are tokenized, envelope-encrypted, and protected by immutability enforcement upon user confirmation. Includes **Smart Sync** (Android-only notification listener) for auto-extracting transactions and notices strictly from linked provider package names.

## Scope (v1)
### Included
- **Bank Cards Vault**:
  - Camera card scanner / manual entry for cardholder name, bank name, last 4 digits, and expiry date.
  - **Zero CVV Storage**: CVV is never requested, read, logged, or persisted anywhere.
  - Envelope Encryption: Card details are encrypted with the user's DEK before database insertion.
  - Review & Confirm Flow: Editable pre-confirm, **immutable after confirm** (`confirmed_at` timestamp set).
- **MFS Accounts (bKash, Nagad, Upay)**:
  - Adapter Pattern (`MfsProvider` interface): Decouples generic wallet logic from specific MFS provider details.
  - Static Reference Entry: Store account number, name, and provider logo for generating receive payment QR codes.
  - Immutable after confirm (`confirmed_at` timestamp set).
- **Smart Sync Engine (Android Only)**:
  - Per-account opt-in dialog: *"Enable automatic transaction & notice detection for this account?"*
  - `NotificationListenerService` strictly allowlisted to linked bank/MFS package names (e.g., `com.bKash.customerapp`, `com.nagad.customerapp`).
  - On-device parsing engine extracts transaction amount, date, reference, and notice types.
  - **Raw notification text is discarded immediately from memory** — only structured, parsed fields are persisted (encrypted).
- **UI Components**:
  - Interactive Card & MFS Carousel with glassmorphism styling and smooth flip animations.

### Excluded
- Live balance pulling or automated bank transfers (v1 is reference-only for MFS).
- Full card number display without biometric re-authentication.

## Data Model

### Backend Schema (`BankCard` & `MfsAccount`)

```prisma
model BankCard {
  id                String    @id @default(uuid()) @db.Uuid
  userId            String    @map("user_id") @db.Uuid
  bankName          String    @map("bank_name")
  lastFourDigits    String    @map("last_four_digits")
  encryptedCardData String    @map("encrypted_card_data")
  iv                String
  authTag           String    @map("auth_tag")
  confirmedAt       DateTime? @map("confirmed_at") // Immutability timestamp
  createdAt         DateTime  @default(now()) @map("created_at")
  updatedAt         DateTime  @updatedAt @map("updated_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
  @@map("bank_cards")
}
```

## API Contract

### Backend Endpoints (`/api/v1/cards` & `/api/v1/mfs`)
- `GET /api/v1/cards`: Returns list of user's bank cards (masked last-4-digits, bank name, confirmation status).
- `POST /api/v1/cards`: Creates new card draft.
- `POST /api/v1/cards/:id/confirm`: Locks card state and sets `confirmedAt` timestamp (immutable).
- `DELETE /api/v1/cards/:id`: Deletes card entry (required to modify an immutable entry).
- `GET /api/v1/mfs`: Returns list of linked MFS accounts.
- `POST /api/v1/mfs`: Creates new MFS reference entry.
- `POST /api/v1/mfs/:id/confirm`: Locks MFS entry and sets `confirmedAt` timestamp.

## Security Considerations
- **Strict CVV Exclusion**: The API schema and mobile forms contain zero fields for CVV.
- **Immutability Enforcement**: Server-side guards reject `PUT`/`PATCH` updates on records where `confirmedAt != null`.
- **Smart Sync Privacy**: Notification listener is restricted by Android Manifest package allowlist filters. Raw notification strings are processed entirely in ephemeral RAM and never written to disk or sent over network.

## Dependencies
- `@nestjs/common`, `@prisma/client`
- Flutter `flutter_riverpod`, `flip_card: ^0.7.0`, `qr_flutter`

## Implementation Notes
- MFS provider adapter design (`MfsAdapter` interface) allows instant integration of live bKash/Nagad REST APIs in future releases without breaking UI or database models.

## Status
In Progress
