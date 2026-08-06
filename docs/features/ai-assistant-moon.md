# Feature: AI Assistant — "Moon"

## Purpose
Moon is MyPocket's conversational AI assistant. It answers questions about the user's own stored wallet data (cards, balances, certificates, transit, documents) via a tool-calling architecture. The LLM never directly queries the database — it calls backend tools scoped to the authenticated session.

## Scope (v1)
**Phase 1 (this milestone):**
- Backend AI proxy service (`/api/v1/ai/chat`) — Gemini API key server-side only
- Tool-calling architecture: 5 tools (`get_wallet_summary`, `get_certificates`, `get_transit_passes`, `get_documents_summary`, `get_upcoming_expirations`)
- Data masking enforced: card → last-4, NID/Passport → type + masked number only, full names → first name
- Multi-turn conversation memory (in-memory per session, not persisted to DB)
- Chat UI: `MoonChatScreen` — full-screen dark glassmorphism, message bubbles, typing indicator
- Floating bubble overlay on Dashboard → navigates to chat
- Rate limiting: 10 req/min per user
- Voice STT + TTS (speech_to_text + flutter_tts)

**Phase 2 (deferred):**
- Wake word "Hey Moon" — pending Porcupine AccessKey

## Data Model
No new Prisma models. Session state is in-memory Map keyed by `sessionId` (UUID from client).

```
InMemorySession {
  userId: string
  sessionId: string
  history: { role: 'user' | 'model', parts: string }[]
  lastActivityAt: Date  // TTL: 30 min idle = cleared
}
```

## API Contract
- `POST /api/v1/ai/chat` — JWT required, body: `{ message, sessionId }`
- Response: `{ reply: string, sessionId: string }`
- `DELETE /api/v1/ai/session/:sessionId` — clears conversation history

## Tool Definitions (Gemini Function Calling)

| Tool | Description | Returns |
|------|-------------|---------|
| `get_wallet_summary` | Summary of all linked cards + MFS accounts | masked card list, account names |
| `get_certificates` | List of certificates in vault | name, category, issueDate |
| `get_transit_passes` | List of transit cards + balances | name, type, masked card, balance (Tk) |
| `get_documents_summary` | Documents stored in vault | type + masked number only |
| `get_upcoming_expirations` | Cards/passes expiring within N days | name, type, expiryDate |

## Security Considerations
- API key (`GEMINI_API_KEY`) loaded from `process.env` — never in client bundle
- `userId` sourced exclusively from `req.user.id` (JWT) — LLM output cannot influence data scope
- Raw NID/Passport numbers NEVER included in any LLM prompt or tool result
- Full card numbers NEVER included in any LLM prompt or tool result
- No raw chat messages persisted to database or disk
- Session TTL: 30 minutes idle → auto-cleared from memory

## Dependencies
- Backend: `@google/generative-ai` npm package, `PrismaService`, existing `JwtAuthGuard`
- Mobile: `speech_to_text`, `flutter_tts`, `uuid` packages

## Implementation Notes
- LLM provider: Google Gemini `gemini-2.0-flash`
- Mascot: animated gradient pulse circle placeholder (v1) — swap for Lottie JSON in v2
- Wake word deferred to v2 (Porcupine key not yet available)
- Voice: speech_to_text for STT, flutter_tts for TTS, both on-device

## Status
Complete (v1 scope) — 2026-08-06
