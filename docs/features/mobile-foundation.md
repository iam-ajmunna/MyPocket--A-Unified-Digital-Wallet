# Feature: Mobile App Foundation & Clean Architecture (Milestone 2)

## Purpose
Establishes the Flutter mobile client application structure for MyPocket v2.0 using Clean Architecture (`core/`, `features/<feature>/data`, `domain`, `presentation`), Riverpod for state management, Dio for network communications, and localized string management (Bangla & English).

## Scope (v1)
### Included
- Flutter application scaffold structured by feature domains (`auth`, `cards`, `mfs`, `documents`, `certificates`, `transit`, `assistant`).
- Clean Architecture division per feature:
  - `data/`: Data sources, DTO models, repository implementations.
  - `domain/`: Business entities, repository interfaces, use cases.
  - `presentation/`: Riverpod providers, UI screens, reusable widgets.
- **Riverpod State Management**: Compile-time safe providers (`NotifierProvider`, `FutureProvider`, `StreamProvider`).
- **Network Layer**: `Dio` HTTP client configured with TLS 1.3 settings, base API URL configuration, and Auth Refresh Interceptor for automatic JWT token rotation.
- **Hardware-backed Storage**: `flutter_secure_storage` wrapper for secure local token and key handling.
- **Design System & Theme**: Centralized color palette, dark/light theme definitions, custom typography via `google_fonts` (Poppins, Manrope, Urbanist).
- **Localization**: `flutter_localizations` setup with externalized ARB files (`intl_en.arb`, `intl_bn.arb`) and dynamic language toggle.
- Navigation shell with animated bottom bar.

### Excluded
- Legacy Firestore direct connections (replaced by NestJS REST API).
- Raw unencrypted local storage for personal document data.

## Data Model

### Client Data Models & Entities
- `UserEntity`: User ID, Full Name, Email, Phone.
- `AuthToken`: Access Token, Refresh Token, Expiry DateTime.
- `AppTheme`: ThemeMode state provider.
- `LocaleState`: Current app language preference (English / Bangla).

## API Contract (Client Integration)
- Connects to NestJS Backend endpoints via `Dio` interceptor.
- Automatic header insertion: `Authorization: Bearer <accessToken>`.
- Token Refresh Interceptor: Automatically pauses queued requests when `401 Unauthorized` is returned, calls `/api/v1/auth/refresh`, updates `flutter_secure_storage`, and retries the failed requests seamlessly.

## Security Considerations
- **Secure Token Storage**: Access and refresh tokens are stored in hardware-backed storage (`flutter_secure_storage` with Android KeyStore & iOS Keychain).
- **Biometric Gate Ready**: App architecture includes a security barrier wrapper (`BiometricGate`) that blocks presentation screens until authenticated when enabled.
- **No Insecure Storage**: SharedPreferences is restricted strictly to non-sensitive preferences (e.g. current language, dark mode preference).

## Dependencies
- `flutter_riverpod`, `riverpod_annotation`
- `dio`
- `flutter_secure_storage`
- `google_fonts`
- `flutter_localizations`, `intl`
- `go_router` or native clean navigator

## Implementation Notes
- GetX is explicitly replaced by Riverpod for state management to avoid service locator anti-patterns and ensure compile-time testability.
- Business logic is strictly prohibited inside Flutter UI widget build methods.

## Status
In Progress
