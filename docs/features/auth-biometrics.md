# Feature: Authentication & Biometric Security UI (Milestone 3)

## Purpose
Provides the user authentication screens (Login and Registration) connected to the NestJS backend API via Riverpod, and implements the **Biometric Security Gate** (`local_auth` + `flutter_secure_storage`) required for unlocking the application and authorizing payment/sensitive document view actions.

## Scope (v1)
### Included
- **Login Screen UI**:
  - Accepts Email or Phone Number + Password.
  - Connected to `authNotifierProvider` (`login` action).
  - Displays error toast/snackbars for invalid credentials.
  - Redirects to main app shell upon successful JWT issuance.
- **Registration Screen UI**:
  - Fields: Full Name, Email, Bangladeshi Phone Number (`01...`), Password (min 8 chars).
  - Connected to `authNotifierProvider` (`register` action).
  - Automatically initializes per-user Envelope Encryption key upon sign-up.
- **Biometric Gate (`BiometricGate` widget)**:
  - Integration with `local_auth` package.
  - Checks device hardware support (Fingerprint / Face ID).
  - **App Unlock Gate**: Requires biometric or fallback device PIN (never app PIN `1234`) on app launch and resume.
  - **Action Confirmation Gate**: Requires biometric check before viewing NID/Passport raw scans or confirming payment actions.
  - Auto-lock session policy after 5 minutes of inactivity.

### Excluded
- Hardcoded test PIN `1234` (explicitly forbidden in v2.0 rebuild).
- Storage of unencrypted passwords or raw biometric data (managed strictly by hardware OS KeyStore/Keychain).

## Data Model
- `BiometricAuthState`: `isEnrolled`, `isAuthenticated`, `isSupported`, `biometricType` (Fingerprint / Face).
- `SessionState`: `lastActiveTime`, `isLocked`.

## API Contract
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/register`
- `POST /api/v1/auth/logout`

## Security Considerations
- **No Hardcoded App PIN**: Fallback authentication relies strictly on OS-level device PIN/Pattern, preventing old `1234` bypass vulnerabilities.
- **In-Memory Token Handling**: Access tokens are kept in memory and passed via Dio request headers; refresh tokens are stored exclusively inside hardware-backed `flutter_secure_storage`.
- **App Resume Lock**: When app transitions from background to foreground, `BiometricGate` automatically re-locks the UI until verified.

## Dependencies
- `local_auth`
- `flutter_riverpod`
- `flutter_secure_storage`

## Implementation Notes
- Screens must strictly consume `authNotifierProvider` for state changes. No direct HTTP calls from UI widgets.
- Password fields must obscure text and allow visibility toggling.

## Status
In Progress
