# Feature: Notifications, Reminder Engine & Sync

## Purpose
This feature provides a unified notification & reminder engine for MyPocket users across devices. It automatically generates warnings for upcoming NID/Passport expiries, low transit pass balances, and due installment/bill payments detected via Smart Sync or added manually. It also maintains device registrations for push notifications and multi-device sync status.

## Scope (v1)
- **Backend Schema**: `Notification` and `DeviceToken` models in Prisma.
- **Backend Services**:
  - NestJS `NotificationsModule`: GET/PATCH read status, POST manual reminder.
  - Automatic scheduled audit service (`NotificationSchedulerService`): scans for expiring documents, low transit balances, and due payments.
  - NestJS `SyncModule`: POST `/api/v1/sync/device` for device token registration, GET `/api/v1/sync/status` for multi-device timestamp sync.
- **Mobile (Flutter)**:
  - `flutter_local_notifications` for on-device local notifications & scheduled reminder alarms.
  - `NotificationsCenterScreen`: filter chips (All, Expiry, Dues, Smart Sync), mark as read, swipe/tap action.
  - "Add Manual Reminder" bottom sheet: custom due dates/installments (iOS parity path).
  - Dashboard Bell Icon: badge counter showing unread notification count.

## Data Model (Prisma)

```prisma
model Notification {
  id           String    @id @default(uuid()) @db.Uuid
  userId       String    @map("user_id") @db.Uuid
  title        String
  body         String
  type         String    // EXPIRY_WARNING, DUE_PAYMENT, SMART_SYNC, ANNOUNCEMENT, CUSTOM
  isRead       Boolean   @default(false) @map("is_read")
  scheduledFor DateTime? @map("scheduled_for")
  dismissedAt  DateTime? @map("dismissed_at")
  createdAt    DateTime  @default(now()) @map("created_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, isRead])
  @@map("notifications")
}

model DeviceToken {
  id          String   @id @default(uuid()) @db.Uuid
  userId      String   @map("user_id") @db.Uuid
  deviceToken String   @map("device_token")
  platform    String   // ANDROID, IOS, WEB
  lastSyncAt  DateTime @default(now()) @map("last_sync_at")
  createdAt   DateTime @default(now()) @map("created_at")

  user User @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([userId, deviceToken])
  @@map("device_tokens")
}
```

## API Contract
- `GET /api/v1/notifications` — returns `{ notifications: [...], unreadCount: number }`
- `PATCH /api/v1/notifications/:id/read` — marks single notification as read
- `POST /api/v1/notifications/read-all` — marks all unread as read
- `POST /api/v1/notifications/reminder` — creates custom reminder `{ title, body, scheduledFor, type }`
- `POST /api/v1/sync/device` — registers device `{ deviceToken, platform }`
- `GET /api/v1/sync/status` — returns `{ lastSyncAt: string, serverTime: string }`

## Security Considerations (AGENTS.md §5)
- Notification body/title MUST NEVER contain raw NID/Passport numbers or full credit card numbers. Only masked names/last-4 (e.g. "Passport expiring in 15 days", "City Bank card ending 4321").
- All endpoints protected with `JwtAuthGuard`. Users can only view or mutate their own notifications and device tokens.

## Dependencies
- Backend: `@nestjs/schedule` (for automated background audit scanner).
- Mobile: `flutter_local_notifications` (already installed in pubspec.yaml).

## Status
Complete (v1 scope) — 2026-08-06
