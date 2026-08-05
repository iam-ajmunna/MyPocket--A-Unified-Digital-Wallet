# Feature: Backend Foundation & Security Core (Milestone 1)

## Purpose
Establishes the core containerized backend architecture for MyPocket v2.0 using NestJS, Prisma ORM, and PostgreSQL. It provides authentication (JWT Access & Refresh token rotation), user account management, and the envelope encryption service required to secure sensitive identity and financial data before persistence.

## Scope (v1)
### Included
- Containerized NestJS application scaffolded with modular domain structure (`auth`, `users`, `crypto`, `cards`, `documents`, `mfs`, `transit`, `certificates`, `ai`, `common`).
- PostgreSQL database setup via Docker Compose.
- Prisma ORM schema definitions, migration tools, and type-safe database access layer.
- Argon2id password hashing for secure authentication credentials.
- JWT Authentication (Access tokens with 15-min expiry + Refresh token rotation stored securely).
- Envelope Encryption Service (`CryptoModule` using AES-256-GCM with Key Encryption Keys / Data Encryption Keys).
- Input validation pipes (`class-validator`) and rate-limiting middleware (`@nestjs/throttler`).
- Structured logging & Health check endpoints (`/health`).

### Excluded
- Live payment processor or live MFS gateway APIs (reference-only for v1).
- Frontend UI components (handled in Flutter mobile repository).

## Data Model

### PostgreSQL Tables (via Prisma)

#### Users Table (`users`)
- `id`: UUID (Primary Key)
- `email`: String (Unique, Indexed)
- `phone`: String (Unique, Indexed)
- `passwordHash`: String (Argon2id)
- `fullName`: String
- `createdAt`: Timestamp
- `updatedAt`: Timestamp

#### Refresh Tokens Table (`refresh_tokens`)
- `id`: UUID (Primary Key)
- `userId`: UUID (Foreign Key -> `users.id`)
- `tokenHash`: String (Hashed Refresh Token)
- `expiresAt`: Timestamp
- `isRevoked`: Boolean

#### Encryption Metadata / User Keys Table (`user_keys`)
- `userId`: UUID (Primary Key, Foreign Key -> `users.id`)
- `wrappedDek`: Bytea / Ciphertext (DEK encrypted by server KEK)
- `keyAlgorithm`: String (`AES-256-GCM`)
- `createdAt`: Timestamp

### Field Sensitivity Classification
- **Public/Unrestricted**: User Full Name, Created Date, Transaction categories.
- **Sensitive**: Email, Phone Number (requires JWT auth to access).
- **Highly Sensitive / Encrypted at Rest**: NID Numbers, Passport Numbers, Bank Card Numbers, Raw Scanned Document Files (encrypted via Envelope DEK before database insertion).

## API Contract

### Auth Endpoints
- `POST /api/v1/auth/register`
  - Body: `{ email, phone, password, fullName }`
  - Response: `{ userId, accessToken, refreshToken }`
- `POST /api/v1/auth/login`
  - Body: `{ identifier, password }` (identifier can be email or phone)
  - Response: `{ userId, accessToken, refreshToken }`
- `POST /api/v1/auth/refresh`
  - Body: `{ refreshToken }`
  - Response: `{ accessToken, refreshToken }`
- `POST /api/v1/auth/logout`
  - Headers: `Authorization: Bearer <accessToken>`
  - Response: `{ success: true }`

### System Endpoints
- `GET /health`
  - Response: `{ status: "ok", timestamp, database: "connected" }`

## Security Considerations
- **Envelope Encryption**: All sensitive records must be encrypted using AES-256-GCM before write operations. Compromising the database alone does not expose raw document values without the server-held KEK key.
- **Argon2id Hashing**: Password storage uses Argon2id with strong memory and iteration cost parameters.
- **Token Security**: Refresh tokens are stored hashed in the database and rotated on every refresh call. Revoked tokens are immediately rejected.
- **No PII Logging**: Interceptors and loggers filter out authorization headers, password fields, NID numbers, card numbers, and raw payloads.

## Dependencies
- `@nestjs/core`, `@nestjs/common`, `@nestjs/jwt`, `@nestjs/passport`, `@nestjs/throttler`
- `@prisma/client`, `prisma`
- `argon2`
- `crypto` (Node.js native crypto module for AES-256-GCM)

## Implementation Notes
- Modular structure ensures zero direct cross-module database imports; modules communicate exclusively via injected domain services.
- Prisma schema maintains strict foreign key constraints and cascade rules on token cleanup.

## Status
In Progress
