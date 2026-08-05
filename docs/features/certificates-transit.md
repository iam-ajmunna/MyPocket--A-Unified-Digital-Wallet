# Feature: Certificates & Transit Passes Vault

## Purpose
Rebuild the Certificate Manager and Transit Pass features from the legacy prototype with the new secure architecture. Certificates are stored with encrypted metadata, organised by category. Transit cards are backend-persisted (replacing raw SharedPreferences), and include a QR boarding flow.

## Scope (v1)
**Certificates:**
- Categories: Academic (SSC / HSC / Under Grad / Grad / PhD / Post Doc), Olympiad, Quiz Competition, Business Competition, Sports, General Skills
- Manual entry: certificate name, issuer, date, category/subcategory
- No file upload in v1 (image upload deferred to v2)
- Backend-persisted, per-user encrypted storage via `CryptoService`

**Transit Passes:**
- Types: Metro, Bus, Train, Ferry, Tram, Subway, Light Rail, Bike Share
- Fields: card name, card number (last-4 masked), expiry date, transit type, balance (Tk)
- Balance tracked in DB (replaces SharedPreferences raw float)
- QR code generated from a revocable reference token (never raw card number in QR)
- Recharge flow: add balance to existing card

## Data Model

```prisma
model Certificate {
  id             String   @id @default(uuid()) @db.Uuid
  userId         String   @map("user_id") @db.Uuid
  name           String
  issuer         String
  issueDate      String   @map("issue_date")      // YYYY-MM-DD
  category       String                            // ACADEMIC | OLYMPIAD | QUIZCOMP | BIZCOMP | SPORTS | SKILLS
  subCategory    String?  @map("sub_category")     // SSC | HSC | UNDERGRAD | GRAD | PHD | POSTDOC
  encryptedData  String   @map("encrypted_data")   // Encrypted JSON of all fields
  iv             String
  authTag        String   @map("auth_tag")
  createdAt      DateTime @default(now()) @map("created_at")
  updatedAt      DateTime @updatedAt @map("updated_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
  @@map("certificates")
}

model TransitPass {
  id            String    @id @default(uuid()) @db.Uuid
  userId        String    @map("user_id") @db.Uuid
  name          String
  lastFourDigits String   @map("last_four_digits")
  transitType   String    @map("transit_type")    // Metro | Bus | Train | Ferry | Tram | Subway | Light Rail | Bike Share
  expiryDate    String    @map("expiry_date")     // YYYY-MM-DD
  balance       Float     @default(0)
  qrToken       String?   @map("qr_token")        // Revocable reference token for boarding QR
  encryptedData String    @map("encrypted_data")  // Encrypted full card number
  iv            String
  authTag       String    @map("auth_tag")
  createdAt     DateTime  @default(now()) @map("created_at")
  updatedAt     DateTime  @updatedAt @map("updated_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)
  @@map("transit_passes")
}
```

## API Contract

### Certificates
- `GET /api/v1/certificates` — list user's certificates (name, category, subCategory, issuer, issueDate)
- `POST /api/v1/certificates` — create certificate (encrypts fields before DB save)
- `DELETE /api/v1/certificates/:id` — remove certificate

### Transit Passes
- `GET /api/v1/transit` — list user's transit cards (masked card, balance, type)
- `POST /api/v1/transit` — add transit card
- `POST /api/v1/transit/:id/recharge` — add balance to a transit card
- `POST /api/v1/transit/:id/qr` — generate or refresh revocable QR token
- `DELETE /api/v1/transit/:id` — remove transit card

## Security Considerations
- Transit card full numbers stored encrypted via `CryptoService`. Only last-4 digits served in list response.
- QR codes reference a server-generated UUID token, never the raw card number.
- Certificate data encrypted at rest (name, issuer, date, etc.).
- No raw card number or personal data encoded in QR payloads.

## Dependencies
- Backend: `PrismaService`, `CryptoService`, NestJS `JwtAuthGuard`
- Mobile: `flutter_riverpod`, `Dio`, `qr_flutter`

## Implementation Notes
- Replacing legacy SharedPreferences-based persistence with proper backend storage.
- Certificate category taxonomy preserved exactly from legacy code.
- Transit types preserved exactly from legacy code.

## Status
Complete (v1 scope) — 2026-08-05
