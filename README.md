# MyPocket — A Unified Digital Wallet 💳🛡️🌙

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![NestJS](https://img.shields.io/badge/NestJS-10.0+-E0234E?logo=nestjs&logoColor=white)](https://nestjs.com)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![Prisma](https://img.shields.io/badge/Prisma-5.22+-2D3748?logo=prisma&logoColor=white)](https://www.prisma.io)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org)
[![Security](https://img.shields.io/badge/Security-AES--256--GCM-00C853?logo=shield&logoColor=white)](#security--privacy)

**MyPocket** is an all-in-one secure digital wallet application designed for portable identity, mobile finance, transit boarding, academic credentials, and AI-assisted financial management.

---

## ✨ Key Features

### 💳 Cards & Mobile Financial Services (MFS)
- **Bank Cards Vault**: Securely store debit/credit cards with last-4 masking and encrypted details.
- **MFS Wallets**: Deep integration with **bKash**, **Nagad**, and **Upay**.
- **Secure Payment QR**: Generates time-limited, revocable reference QR tokens — never exposes raw account data.

### 🛡️ Government Identity Vault (NID & Passport)
- **Document Vault**: Encrypted storage for National ID (NID) and Passport credentials.
- **Biometric Security Gate**: Sensitive document details locked behind device biometrics (`Fingerprint` / `FaceID`).

### 🎓 Certificate Manager
- Categorized digital credential vault: **Academic** (SSC → PostDoc), **Olympiad**, **Quiz**, **Business**, **Sports**, and **Skills**.

### 🚇 Transit Pass Manager
- **Metro & Bus Passes**: Manage MRT Pass, Rapid Pass, and transit balances in BDT.
- **Top-Up & Boarding QR**: Instant balance recharge dialog & revocable QR boarding token generation.

### 🌙 AI Companion "Moon"
- **Gemini 2.0 Flash Tool-Calling**: Answers natural language questions about your stored cards, balances, certificates, and documents.
- **Strict Server Scoping**: Moon's tools run server-side using your authenticated session — zero raw PII sent to LLM prompts.
- **Voice I/O**: On-device Speech-to-Text (STT) query input and Text-to-Speech (TTS) response playback.

### 🔔 Notifications & Reminders Engine
- **Automated Vault Scanner**: Background alerts for low transit balances (< 100 Tk) and upcoming document expiries.
- **Custom Due Reminders**: Set custom due dates for loan installments, utility bills, or document renewals.
- **Unread Badge**: Live notification count integrated into the Dashboard AppBar.

---

## 🔒 Security & Privacy Architecture

- **Envelope Encryption**: Data Encryption Keys (DEKs) wrapped with a server-held Key Encryption Key (KEK) using AES-256-GCM.
- **Zero Raw PII Persistence**: NID numbers, full card numbers, CVVs, and biometrics are never stored in plain text.
- **Zero Sensitive Logging**: Backend loggers strip sensitive fields at all log levels.
- **JWT Authentication**: Short-lived access tokens with secure refresh token rotation.
- **Rate Limiting**: Protected by `@nestjs/throttler` (100 req/min global, 10 req/min on AI endpoints).

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Mobile App** | Flutter 3.22+, Dart, Riverpod 2.6, Dio, Speech-to-Text, Flutter TTS, Local Auth |
| **Backend API** | NestJS 10, TypeScript, RxJS, Class Validator, Passport JWT, Google Generative AI |
| **Database & ORM**| PostgreSQL 16, Prisma ORM 5.22 |
| **Containerization**| Docker, Docker Compose |

---

## 📁 Repository Structure

```
MyPocket--A-Unified-Digital-Wallet/
├── application files/          # Flutter Mobile Application
│   ├── lib/
│   │   ├── core/               # Theme, Network (ApiClient), Biometrics, Storage
│   │   └── features/
│   │       ├── auth/           # Login, Register, Clean Dashboard
│   │       ├── cards_mfs/      # Bank Cards & MFS screens & providers
│   │       ├── documents/      # NID & Passport vault screens & providers
│   │       ├── certificates/   # Academic & Skill certificates vault
│   │       ├── transit/        # Transit pass manager & QR boarding
│   │       ├── ai/             # Moon assistant chat UI, floating bubble, voice I/O
│   │       └── notifications/  # Notification center & custom reminder sheet
├── backend/                    # NestJS Backend API Service
│   ├── src/
│   │   ├── auth/               # JWT authentication & refresh tokens
│   │   ├── crypto/             # AES-256-GCM envelope encryption service
│   │   ├── cards/              # Bank card vault management
│   │   ├── mfs/                # bKash, Nagad, Upay adapter services
│   │   ├── documents/          # NID & Passport document service
│   │   ├── certificates/       # Certificate vault service
│   │   ├── transit/            # Transit pass & QR token service
│   │   ├── ai/                 # Gemini 2.0 Flash AI proxy & tool execution
│   │   ├── notifications/      # Notification center & automated vault scanner
│   │   └── sync/               # Multi-device token registration & sync status
│   ├── prisma/                 # Prisma database schema & migrations
│   ├── Dockerfile              # Multi-stage production build
│   └── docker-compose.prod.yml # Production Docker compose setup
├── docs/                       # Architectural specs & feature documentation
├── CHANGELOG.md                # Release changelog
└── IMPLEMENTATION_STATUS.md    # Completed milestone roadmap
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.22+)
- [Node.js](https://nodejs.org) (v20+)
- [Docker & Docker Compose](https://www.docker.com/) (Optional, for containerized DB/Backend)

---

### 1. Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
npm install

# Configure environment variables
cp .env.example .env

# Generate Prisma Client
npx prisma generate

# Run database migrations / push schema
npx prisma db push

# Start NestJS development server
npm run start:dev
```

The NestJS backend will run at `http://localhost:3000/api/v1`.

---

### 2. Mobile App Setup

```bash
# Navigate to application directory
cd "application files"

# Get Flutter dependencies
flutter pub get

# Run on emulator/device
flutter run
```

---

### 3. Production Docker Deployment

To spin up the production NestJS backend & PostgreSQL instance using Docker:

```bash
cd backend
docker-compose -f docker-compose.prod.yml up --build -d
```

---

## 🧪 Testing

```bash
# Run NestJS Unit Tests
cd backend
npm test

# Run Flutter Application Tests & Analysis
cd "application files"
flutter analyze
flutter test
```

---

## 📄 License

This project is maintained under the MIT License. See [LICENSE](LICENSE) for details.
