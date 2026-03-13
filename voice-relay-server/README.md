# Hey Cape Cod - Voice Relay Server

WebSocket relay server that bridges the iOS app to OpenAI's Realtime API for voice conversations with Captain Cod.

## Why a separate server?

Vercel serverless functions do not support persistent WebSocket connections. This server runs on a long-lived platform (Railway or Fly.io) to maintain bidirectional audio streaming.

## Environment Variables

| Variable | Description |
|---|---|
| `PORT` | Server port (default: 8080) |
| `OPENAI_API_KEY` | OpenAI API key with Realtime API access |
| `FIREBASE_PROJECT_ID` | Firebase project ID for auth token verification |
| `FIREBASE_CLIENT_EMAIL` | Firebase service account email |
| `FIREBASE_PRIVATE_KEY` | Firebase service account private key |

## Local Development

```bash
cp .env.example .env
# Fill in your environment variables
npm install
npm run dev
```

Test the health endpoint:
```bash
curl http://localhost:8080/health
```

## Deploy to Fly.io

```bash
# Install flyctl: https://fly.io/docs/flyctl/install/
fly auth login
fly launch          # First time — creates the app
fly secrets set OPENAI_API_KEY=sk-... FIREBASE_PROJECT_ID=hey-cape-cod FIREBASE_CLIENT_EMAIL=... FIREBASE_PRIVATE_KEY=...
fly deploy
```

The app will be available at `wss://<app-name>.fly.dev/relay`.

## Deploy to Railway

1. Push this directory to a GitHub repo (or use the monorepo).
2. Create a new project on [railway.app](https://railway.app).
3. Connect the repo and set the root directory to `voice-relay-server/`.
4. Add environment variables in the Railway dashboard.
5. Railway auto-detects the Dockerfile and deploys.

The app will be available at `wss://<project>.up.railway.app/relay`.

## Protocol

**iOS app connects to:** `wss://<host>/relay` with `Authorization: Bearer <firebase-token>` header.

**Client -> Server:**
- `{ "type": "audio", "audio": "<base64 PCM16>", "timestamp": <ms> }`
- `{ "type": "control", "action": "interrupt" | "end_turn" | "disconnect" }`

**Server -> Client:**
- `{ "type": "audio", "audio": "<base64>", "is_final": bool }`
- `{ "type": "transcript", "text": "...", "role": "user" | "assistant" }`
- `{ "type": "status", "state": "listening" | "thinking" | "speaking" }`
- `{ "type": "error", "message": "..." }`

## Limits

- Max 5 concurrent connections per user
- 15-minute absolute session timeout
- 10-minute idle timeout
- 30-second ping/pong keep-alive
