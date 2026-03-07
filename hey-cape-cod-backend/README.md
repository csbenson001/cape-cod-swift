# Hey Cape Cod Backend

Vercel serverless backend for the Hey Cape Cod iOS app. Provides REST APIs for POIs, stories, weather, tides, traffic, chat, and user management.

## Stack

- **Runtime**: Node.js on Vercel Serverless Functions
- **Database**: Firebase Firestore
- **Auth**: Firebase Admin SDK (JWT verification)
- **AI**: OpenAI GPT-4o-mini for chat
- **External APIs**: NOAA Weather, NOAA CO-OPS Tides, MassDOT Traffic

## Setup

1. Copy `.env.example` to `.env` and fill in values:
   ```
   cp .env.example .env
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Seed the database (requires Firebase credentials):
   ```
   node scripts/seed-database.js
   ```

4. Run locally:
   ```
   npx vercel dev
   ```

## API Endpoints

### Public (no auth required)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/health` | Health check |
| GET | `/api/pois` | List POIs (query: `category`, `town`) |
| GET | `/api/pois/[id]` | POI detail with stories |
| GET | `/api/pois/nearby` | Nearby POIs (query: `lat`, `lng`, `radius`) |
| GET | `/api/stories` | List stories (query: `mode`, `category`) |
| GET | `/api/stories/[id]` | Story detail |
| GET | `/api/weather` | Weather data (query: `lat`, `lng`) |
| GET | `/api/weather/tides` | Tide predictions (query: `station`) |
| GET | `/api/traffic` | Cape Cod traffic & bridge status |

### Authenticated (requires Firebase JWT)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/api/chat` | AI chat (body: `message`, `mode`, `location`, `history`) |
| GET | `/api/user/profile` | Get user profile (auto-creates on first call) |
| PUT | `/api/user/profile` | Update profile fields |
| GET | `/api/user/usage` | Usage stats and limits |

## Caching

In-memory cache with TTL per data type:
- Traffic: 5 minutes
- Weather: 15 minutes
- Tides: 24 hours
- POI list: 1 hour

## Rate Limits

Free tier users:
- 10 chat conversations per day
- 20 stories per day
- 3 voice minutes per day

Premium users: unlimited.

## Environment Variables

See `.env.example` for the full list. Required:
- `FIREBASE_PROJECT_ID`, `FIREBASE_CLIENT_EMAIL`, `FIREBASE_PRIVATE_KEY`
- `OPENAI_API_KEY`

Optional:
- `GOOGLE_MAPS_API_KEY` (traffic fallback)
- `NOAA_USER_AGENT` (defaults to `HeyCapeCod/1.0`)

## Deployment

```
npx vercel --prod
```

The production URL is configured in the iOS app's `APIClient.swift` (`baseURL` for release builds).

## Voice WebSocket

Vercel does not support WebSocket connections. The voice relay endpoint (`/api/voice`) is a placeholder. Deploy the voice relay to Railway, Render, or Fly.io for persistent WebSocket support.
