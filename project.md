# Hey Cape Cod - AI-Powered Travel Assistant

> A feature-rich SwiftUI iOS app that serves as an AI-powered travel guide for Cape Cod, Massachusetts. Combines real-time data (weather, tides, traffic), community-driven recommendations, audio storytelling, and conversational AI into a single immersive experience.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Directory Structure](#directory-structure)
4. [Design System](#design-system)
5. [Features](#features)
6. [Models](#models)
7. [Services](#services)
8. [Views & ViewModels](#views--viewmodels)
9. [API Endpoints](#api-endpoints)
10. [Backend](#backend)
11. [Data Strategy](#data-strategy)
12. [Authentication](#authentication)
13. [Subscriptions](#subscriptions)
14. [Accessibility](#accessibility)
15. [Dependencies](#dependencies)
16. [Build Configuration](#build-configuration)

---

## Overview

**Hey Cape Cod** is a native iOS 17+ app built entirely in SwiftUI. It provides tourists and locals with:

- **AI Chat & Voice Assistant** — Ask questions about Cape Cod and get context-aware responses powered by OpenAI, with both text and real-time voice interfaces
- **Audio Stories** — Location-triggered narratives about Cape Cod's history, nature, and culture, with content adapted by experience mode (kids, teen, adult, family)
- **Guided Tours** — 12+ curated themed tours (pirate, haunted, maritime, art, romantic, etc.) plus AI-generated custom tours based on user interests
- **Restaurant & Dining Guide** — Community-rated restaurants with full menus, dietary tags, signature dish highlighting, and a personalized recommendation algorithm
- **Weather & Tides** — Real-time conditions via WeatherKit + NOAA, beach safety alerts, tide predictions with chart visualization
- **Bridge & Traffic** — Live status for Sagamore and Bourne bridges with delay estimates
- **Community Reviews** — Rating and review system for POIs, restaurants, and tours with tag-based feedback
- **Interactive Map** — MapKit integration with category filtering, geofence visualization, and nearby POI discovery

**Tech Stack:** SwiftUI, SwiftData, WeatherKit, StoreKit 2, MapKit, AVFoundation, CoreLocation, Firebase Auth, OpenAI API

**Deployment Target:** iOS 17.0+
**Swift Version:** 5.9 with strict concurrency (`SWIFT_STRICT_CONCURRENCY: complete`)

---

## Architecture

### Observable State Pattern
The app uses the `@Observable` macro (iOS 17+) for reactive state management. All service singletons and view models are `@Observable` classes isolated to `@MainActor` for thread safety under Swift 6 strict concurrency.

```
View → ViewModel → Service → APIClient → Backend API
                  ↕
              SwiftData Cache
                  ↕
           BundledContent (offline fallback)
```

### Key Patterns

- **Three-Tier Data Loading**: SwiftData cache (instant) → API fetch (fresh) → Bundled content (offline fallback)
- **Singleton Services**: `POIService.shared`, `WeatherService.shared`, etc. — all `@MainActor @Observable`
- **Centralized Networking**: `APIClient` handles auth token injection, environment switching, error mapping
- **Experience Modes**: Content adapts to kids/teen/adult/family mode throughout the app
- **Concurrency**: Full `async/await` with `@preconcurrency @MainActor` for strict Sendable compliance

---

## Directory Structure

```
HeyCapeCod/
├── App/
│   ├── HeyCapeCodApp.swift           # App entry point, splash screen, auth flow
│   └── AppState.swift                # Global state, tab enum, error handling
│
├── Core/
│   ├── Cache/
│   │   ├── CachedModels.swift        # SwiftData @Model definitions for cache
│   │   └── POICacheManager.swift     # SwiftData read/write for POIs and stories
│   ├── Network/
│   │   └── APIClient.swift           # REST client: GET/POST, auth headers, env config
│   └── Services/
│       ├── POIService.swift          # POI/story fetching + TourGeneratorService
│       ├── ChatService.swift         # AI chat + ReviewService
│       ├── ContentPrefetcher.swift   # Warm caches on launch
│       ├── SpotlightIndexer.swift    # CoreSpotlight indexing
│       └── SiriShortcuts.swift       # AppIntent definitions for Siri
│
├── Services/
│   ├── AuthManager.swift             # Firebase Auth (Apple/Google/Email/Guest)
│   ├── LocationManager.swift         # CLLocationManager async wrapper
│   ├── LocationService.swift         # Geocoding, distance calculations
│   ├── WeatherService.swift          # WeatherKit + NOAA fallback
│   ├── TideService.swift             # NOAA tide station data
│   ├── TrafficService.swift          # Bridge and road condition API
│   ├── AIService.swift               # Backend AI calls with location context
│   ├── AudioService.swift            # Audio recording/playback delegation
│   ├── SubscriptionManager.swift     # StoreKit 2 subscription lifecycle
│   ├── PaywallManager.swift          # Daily usage limits, paywall gating
│   ├── BeachRecommendationEngine.swift # Personalized beach scoring algorithm
│   ├── GeofenceManager.swift         # Location-triggered story activation
│   └── Voice/
│       ├── WebSocketManager.swift    # WebSocket connection for voice relay
│       ├── AudioEngine.swift         # PCM16 24kHz audio capture, VAD, base64 encoding
│       └── AudioPlayer.swift         # PCM16 audio decoding, gapless playback, barge-in
│
├── ViewModels/
│   ├── HomeViewModel.swift           # Dashboard data aggregation
│   ├── ExploreViewModel.swift        # POI filtering and sorting
│   ├── ConversationViewModel.swift   # Chat message management
│   ├── VoiceAssistantViewModel.swift # Voice session state machine
│   └── WeatherViewModel.swift        # Weather data presentation
│
├── Views/
│   ├── MainTabView.swift             # 5-tab navigation + floating action button
│   ├── SplashScreenView.swift        # Launch animation
│   ├── Home/
│   │   └── HomeView.swift            # Dashboard with greeting, metrics, stories
│   ├── Explore/
│   │   ├── ExploreView.swift         # POI list with category filters
│   │   ├── ExploreMapView.swift      # Interactive map with geofence visualization
│   │   ├── LocationDetailView.swift  # POI detail, stories, reviews
│   │   └── StoryPlayerView.swift     # Audio story playback with mode variants
│   ├── Conversation/
│   │   ├── ChatView.swift            # Text chat interface
│   │   └── VoiceAssistantView.swift  # Waveform, listening/thinking/speaking states
│   ├── Tours/
│   │   ├── TourListView.swift        # Browse curated + AI tours
│   │   ├── TourDetailView.swift      # Tour stops, duration, directions
│   │   ├── ActiveTourView.swift      # Real-time navigation during tour
│   │   └── CustomTourBuilderView.swift # AI tour generation interface
│   ├── Dining/
│   │   ├── RestaurantListView.swift  # Restaurant discovery with filters
│   │   ├── RestaurantDetailView.swift # Menu, ratings, reviews, hours
│   │   └── WriteReviewView.swift     # Review submission with menu item ratings
│   ├── Weather/
│   │   ├── WeatherDashboardView.swift # Current conditions, hourly forecast
│   │   ├── BeachConditionsView.swift  # Water temp, waves, rip current alerts
│   │   └── TideChartView.swift       # Tide chart visualization
│   ├── Traffic/
│   │   └── TrafficView.swift         # Sagamore/Bourne bridge status
│   ├── Profile/
│   │   └── ProfileView.swift         # User info, preferences, favorites
│   ├── Settings/
│   │   ├── SettingsView.swift        # App settings
│   │   └── SubscriptionView.swift    # Premium upgrade, pricing
│   └── Onboarding/
│       └── OnboardingView.swift      # Welcome flow, permissions, mode selection
│
├── Models/
│   ├── POI.swift                     # Point of Interest model
│   ├── APIStory.swift                # Story from API response
│   ├── Story.swift                   # Story with experience mode variants
│   ├── Conversation.swift            # Chat conversation container
│   ├── Message.swift                 # Chat message (user/assistant)
│   ├── ChatMessage.swift             # Chat request/response DTOs
│   ├── Location.swift                # CodLocation, Restaurant, MenuItem, Review, enums
│   ├── UserProfile.swift             # SwiftData user model + Firestore sync
│   ├── Weather.swift                 # Weather data models
│   ├── WeatherResponse.swift         # Weather API response DTOs
│   ├── Tide.swift                    # Tide prediction models
│   ├── TideResponse.swift            # NOAA tide API response
│   ├── TrafficReport.swift           # Traffic condition models
│   └── TrafficStatus.swift           # Bridge status enums
│
├── UI/
│   ├── Components/
│   │   ├── CodButton.swift           # Primary/secondary/accent/ghost/icon button variants
│   │   ├── CodCard.swift             # Elevated card with shadow/border
│   │   ├── CodChip.swift             # Tag/filter chip + FlowLayout
│   │   ├── MetricCard.swift          # Big number display (temp, tide, etc.)
│   │   ├── LoadingSkeleton.swift     # Shimmer animation placeholder
│   │   ├── PulsingCircle.swift       # Animated pulse for voice listening
│   │   ├── WaveformView.swift        # Audio level waveform
│   │   ├── MicroInteractions.swift   # Haptic + animation utilities
│   │   └── VisualFlourishes.swift    # Decorative elements
│   ├── Patterns/
│   │   ├── HeroHeader.swift          # Large image header with text overlay
│   │   ├── ScrollScreenLayout.swift  # Pull-to-refresh wrapper
│   │   ├── HorizontalCardScroll.swift # Horizontal carousel pattern
│   │   ├── StatusBanner.swift        # Alert/warning banner
│   │   └── MiniPlayerBar.swift       # Floating audio player bar
│   └── DesignSystemPreview.swift     # Design token preview canvas
│
├── Theme/
│   ├── CapeCodTheme.swift            # Color palette (ocean-inspired)
│   ├── Typography.swift              # Font scale with Dynamic Type
│   ├── Spacing.swift                 # 8-point grid, radii, shadows
│   ├── Animations.swift              # Spring, pulse, shimmer, orbit presets
│   └── Accessibility.swift           # VoiceOver, Dynamic Type, haptics
│
├── Extensions/
│   └── View+Extensions.swift         # Custom view modifiers
│
├── Data/
│   └── BundledContent.swift          # Offline POIs, curated tours, restaurants
│
└── Resources/
    ├── Assets.xcassets               # App icon, accent color
    ├── Info.plist                     # Permissions, build config
    └── HeyCapeCod.entitlements       # iCloud, HealthKit, location
```

---

## Design System

### Color Palette (Ocean-Inspired)

| Token | Light | Dark | Usage |
|-------|-------|------|-------|
| `oceanBlue` | #1A6B8A | #3FA8CC | Primary actions, links, headers |
| `seafoam` | #7EC8B8 | #7EC8B8 | Secondary, AI listening state |
| `sunsetOrange` | #E87040 | #F08860 | Accent, CTAs, AI thinking/speaking |
| `shellWhite` | #FAF6F1 | #111D2B | Page backgrounds |
| `fog` | #F0EDE8 | #162233 | Card/surface backgrounds |
| `deepNavy` | #0D2137 | #FAFAFA | Primary text |
| `driftwood` | #A69279 | #8C7E6A | Secondary text |
| `sandbar` | #E8DFD0 | #1E2D3D | Borders, dividers |
| `cranberry` | #C94E50 | #C94E50 | Error, destructive actions |

**Semantic Traffic Colors:**
- Clear: `duneGrass` (green)
- Moderate: `sandbarYellow`
- Heavy: `sunsetOrange`
- Severe: `lobsterRed`

### Typography Scale

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `heroTitle` | 34pt | Bold Rounded | Screen headers |
| `sectionTitle` | 22pt | Semibold | Section headers |
| `cardTitle` | 17pt | Semibold | Card headers |
| `body` | 15pt | Regular | Body text |
| `storyBody` | 15pt | Regular (1.6 line height) | Editorial content |
| `caption` | 13pt | Regular | Metadata, timestamps |
| `label` | 11pt | Medium | Tags, badges |
| `metric` | 28pt | Light Monospaced | Big numbers (temp, tide) |
| `metricUnit` | 13pt | Regular | Units (°F, ft) |

All text styles support Dynamic Type scaling via `@ScaledMetric`.

### Spacing (8-Point Grid)

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4pt | Tight gaps |
| `sm` | 8pt | Element spacing |
| `md` | 16pt | Section spacing |
| `lg` | 24pt | Major sections |
| `xl` | 32pt | Screen sections |
| `xxl` | 48pt | Hero spacing |
| `screenEdge` | 20pt | Horizontal margins |
| `cardPadding` | 16pt | Card internal padding |

### Corner Radii

- Card: 16pt
- Button: 12pt
- Input: 10pt
- Chip: 8pt
- Featured: 24pt

### Animation Presets

- **spring**: 0.35s response, 0.7 damping — general transitions
- **quick**: 0.25s — button presses, toggles
- **gentle**: 1.0s easeInOut — background elements
- **pulse**: 1.5s repeat — listening indicator
- **shimmer**: 1.2s repeat — loading skeleton
- **orbit**: 2.0s linear repeat — thinking spinner

### Component Library

| Component | File | Description |
|-----------|------|-------------|
| `CodButton` | `CodButton.swift` | 5 variants: primary, secondary, accent, ghost, icon. Press state with scale + opacity. |
| `CodCard` | `CodCard.swift` | Elevated card with shadow, border, padding options |
| `CodChip` | `CodChip.swift` | Tag/filter chip with icon, selectable state, FlowLayout |
| `MetricCard` | `MetricCard.swift` | Big number display with label and trend indicator |
| `LoadingSkeleton` | `LoadingSkeleton.swift` | Shimmer gradient animation for loading states |
| `PulsingCircle` | `PulsingCircle.swift` | Animated concentric circles for voice listening |
| `WaveformView` | `WaveformView.swift` | Real-time audio level visualization |
| `HeroHeader` | `HeroHeader.swift` | Full-width image with gradient text overlay |
| `ScrollScreenLayout` | `ScrollScreenLayout.swift` | Pull-to-refresh wrapper |
| `StatusBanner` | `StatusBanner.swift` | Top-of-screen alert bar |
| `MiniPlayerBar` | `MiniPlayerBar.swift` | Floating audio player |

---

## Features

### 1. Home Dashboard
The landing screen shows a time-aware greeting, quick weather/tide metrics, featured audio stories, and recent AI conversations. Adapts content based on time of day and user's experience mode.

### 2. Explore & Map
Browse 15+ points of interest across 15 Cape Cod towns, organized by 10 categories (beach, restaurant, lighthouse, museum, nature, shopping, marina, historic, entertainment, lodging). Interactive map view with category-colored pins, geofence radius visualization, and nearby POI discovery.

### 3. Audio Stories
Location-triggered narratives about Cape Cod places. Each story has variants for kids, teen, adult, and family audiences. Stories can be played inline or from a dedicated player with progress tracking.

### 4. Guided Tours
**12 curated themed tours:**
- Historic Sandwich Walking Tour
- Provincetown Art & Culture Walk
- Outer Cape Lighthouse Trail
- Cape Cod Maritime Heritage Tour
- Chatham Village Explorer
- Cape Cod Rail Trail Adventure
- Pirate History: Cape Cod's Hidden Past
- Haunted Cape Cod: Ghost Stories After Dark
- Cape Cod for Romantics: Sunset & Wine
- Through the Lens: Cape Cod Photography Tour
- Cape Cod Seafood Trail
- Family Fun: Cape Cod with Kids

**AI-Generated Custom Tours:** Users can create personalized tours by selecting a theme (pirate, haunted, maritime, art, romantic, photography, etc.), duration, and starting location. The `TourGeneratorService` calls the backend AI to generate a tour or falls back to curated content.

**Tour Models:**
- `GuidedTour`: Full tour with stops, difficulty, estimated duration, distance
- `TourCategory`: 13 categories including `.pirate`, `.haunted`, `.maritime`, `.art`, `.romantic`, `.photography`, `.custom`
- `TourDifficulty`: easy, moderate, challenging, strenuous

### 5. Dining & Restaurants
**8 bundled Cape Cod restaurants** with full menus, community ratings, and dietary tags. Features include:
- Restaurant discovery with cuisine and price range filters
- Full menu display organized by category (appetizer, entree, seafood, sandwich, salad, soup, dessert, drink, kids)
- Community-driven rating system with star ratings and review tags
- **Recommendation Algorithm**: Scores menu items based on community rating, rating count, signature dish status, user interests, and dietary preferences
- Dietary tags: vegetarian, vegan, gluten free, dairy free, nut free, local catch
- Price ranges: budget ($), moderate ($$), upscale ($$$), fine dining ($$$$)

### 6. Community Reviews
Users can submit reviews for POIs, restaurants, and tours with:
- 1-5 star rating
- Title and body text
- Visit date
- Menu item ratings (for restaurants)
- Review tags: great food, nice view, family friendly, good service, good value, lively atmosphere, romantic, quick service, pet friendly, local favorite, tourist spot, hidden gem
- Helpful vote system
- Local aggregation with rating trend tracking (rising/stable/declining)

### 7. AI Chat
Text-based conversation with the AI Cape Cod guide. Sends user location and experience mode for context-aware responses. Handles authentication requirements and daily rate limits.

### 8. Voice Assistant
Real-time voice conversation using:
- **AudioEngine**: Captures PCM16 audio at 24kHz with Voice Activity Detection
- **WebSocketManager**: Streams audio to backend voice relay
- **AudioPlayer**: Plays AI audio responses with gapless playback and 50ms barge-in fade
- Visual states: listening (seafoam pulse), thinking (orbit animation), speaking (waveform)

### 9. Weather & Tides
- Current conditions via WeatherKit with NOAA fallback
- Beach conditions: water temperature, wave height, rip current alerts
- Tide predictions from NOAA CO-OPS stations with chart visualization
- Hourly forecast display

### 10. Bridge & Traffic
Live status monitoring for Sagamore and Bourne bridges — the two bridges connecting Cape Cod to the mainland. Shows delay estimates and road conditions.

### 11. Siri Shortcuts
Three AppIntent integrations:
- "Ask Cape Cod about [question]" — routes to AI chat
- "Check Cape Cod traffic" — bridge status report
- "Check Cape Cod tides" — next tide prediction

### 12. Subscriptions
StoreKit 2 integration with two products:
- Monthly: $4.99/month
- Annual: $29.99/year (save 50%)

Premium unlocks unlimited AI conversations, all audio stories, and custom tour generation. Free tier has daily usage limits managed by `PaywallManager`.

---

## Models

### Core Data Models

| Model | File | Key Fields |
|-------|------|------------|
| `POI` | `POI.swift` | id, name, description, lat/lng, category, town, storyIDs, facts, tips |
| `CodLocation` | `Location.swift` | id, name, lat/lng, category, town, storyIDs, isFavorite, rating |
| `Restaurant` | `Location.swift` | id, name, cuisine, priceRange, menuHighlights, averageRating, tags |
| `MenuItem` | `Location.swift` | id, name, category, price, communityRating, ratingCount, dietaryTags |
| `Review` | `Location.swift` | id, userId, targetId, rating, title, body, menuItemRatings, tags |
| `GuidedTour` | `BundledContent.swift` | id, name, description, category, difficulty, stops, duration, distance |
| `UserProfile` | `UserProfile.swift` | uid, displayName, email, mode, interests, isPremium, dailyCounters |
| `Conversation` | `Conversation.swift` | id, title, messages, timestamps |
| `Message` | `Message.swift` | id, content, role (user/assistant), timestamp |

### Enums

| Enum | Cases | File |
|------|-------|------|
| `LocationCategory` | beach, restaurant, lighthouse, museum, nature, shopping, marina, historic, entertainment, lodging | `Location.swift` |
| `CapeCodTown` | 15 towns across 4 regions | `Location.swift` |
| `CapeRegion` | upperCape, midCape, lowerCape, outerCape | `Location.swift` |
| `TourCategory` | 13 categories including pirate, haunted, maritime, art, romantic, photography, custom | `BundledContent.swift` |
| `CuisineType` | seafood, american, italian, portuguese, newEngland, farmToTable, casual, fineDining, cafe, iceCream | `Location.swift` |
| `MenuCategory` | appetizer, entree, seafood, sandwich, salad, soup, dessert, drink, kids | `Location.swift` |
| `DietaryTag` | vegetarian, vegan, glutenFree, dairyFree, nutFree, localCatch | `Location.swift` |
| `ReviewTag` | 12 tags (greatFood, niceView, familyFriendly, etc.) | `Location.swift` |
| `ExperienceMode` | kids, teen, adult, family | `UserProfile.swift` |

---

## Services

### Networking
- **`APIClient`** (`Core/Network/APIClient.swift`): Centralized REST client. Handles GET/POST requests with JSON encoding/decoding, auth token injection via `Authorization: Bearer` header, environment switching (dev/staging/production), and typed error mapping (`APIError`: unauthorized, rateLimited, serverError, etc.).

### Data Services
- **`POIService`** (`Core/Services/POIService.swift`): Fetches POIs and stories with three-tier loading (cache → API → bundled). Also contains `TourGeneratorService` for AI-powered custom tour creation with theme-based POI scoring and fallback to curated tours.
- **`ChatService`** (`Core/Services/ChatService.swift`): Sends text messages to `/api/chat` with experience mode and optional location context.
- **`ReviewService`** (`Core/Services/ChatService.swift`): CRUD for reviews — fetch, submit, mark helpful, rate menu items. Includes local aggregation updates and the recommendation algorithm for menu items.
- **`POICacheManager`** (`Core/Cache/POICacheManager.swift`): SwiftData persistence for POIs and stories.
- **`ContentPrefetcher`** (`Core/Services/ContentPrefetcher.swift`): Warms up caches on app launch.

### Location & Weather
- **`LocationManager`**: Async CLLocationManager wrapper with geofencing support.
- **`WeatherService`**: WeatherKit with NOAA fallback for conditions and forecasts.
- **`TideService`**: NOAA CO-OPS tide station predictions.
- **`TrafficService`**: Bridge and road condition data.
- **`BeachRecommendationEngine`**: Scores beaches based on weather, tides, crowd level, and user preferences.

### Voice
- **`AudioEngine`**: Captures microphone audio in PCM16 at 24kHz, performs Voice Activity Detection (VAD), and emits base64-encoded ~100ms chunks for WebSocket transmission. End-of-turn detection via 1.5s silence threshold.
- **`AudioPlayer`**: Decodes and plays PCM16 audio responses with gapless buffer scheduling, 50ms fade-out for barge-in support, and output level metering for waveform visualization.
- **`WebSocketManager`**: Manages persistent WebSocket connection to the voice relay backend. Handles connect/disconnect/reconnect with exponential backoff (up to 8 attempts). Ping keepalive every 30s.

### Auth & Payments
- **`AuthManager`**: Firebase Authentication supporting Sign in with Apple, Google Sign-In, email/password, and guest mode. Session restore from Keychain.
- **`SubscriptionManager`**: StoreKit 2 lifecycle — product loading, purchasing, restoring, transaction listening, Family Sharing, and server-side receipt verification.
- **`PaywallManager`**: Tracks daily usage counts, enforces free tier limits, and triggers paywall presentation.

### Platform Integration
- **`SpotlightIndexer`**: Indexes POIs for CoreSpotlight search.
- **`SiriShortcuts`**: Three `AppIntent` definitions for Siri integration.
- **`GeofenceManager`**: Monitors CLCircularRegion boundaries to trigger audio stories when the user enters a POI's vicinity.

---

## Views & ViewModels

### Navigation Structure
```
MainTabView (5 tabs + floating action button)
├── Tab 1: HomeView
├── Tab 2: ExploreView / ExploreMapView
├── Tab 3: TourListView
├── Tab 4: WeatherDashboardView
├── Tab 5: ProfileView
└── FAB → ChatView / VoiceAssistantView
```

### ViewModels
Each major view has a corresponding ViewModel that:
- Binds to one or more services
- Transforms service data for presentation
- Handles user actions and delegates to services
- Manages loading and error states

---

## API Endpoints

**Base URLs:**
- Development: `http://localhost:3000/api`
- Staging: `https://staging-cape-cod.vercel.app/api`
- Production: `https://v0-cape-cod-ai-travel-assistant.vercel.app/api`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/pois` | List all POIs |
| GET | `/pois/nearby?lat=X&lng=Y&radius=M` | Nearby POIs by location |
| GET | `/pois/{id}` | POI detail with stories |
| GET | `/stories?mode=X&category=Y` | List stories with filters |
| GET | `/stories/{id}` | Story detail |
| POST | `/chat` | AI chat: `{message, mode, location}` |
| WS | `/voice` | WebSocket voice relay |
| GET | `/weather?lat=X&lng=Y` | Current weather |
| GET | `/weather/tides?station=XXXX` | Tide predictions |
| GET | `/traffic` | Bridge and road status |
| GET | `/users/{uid}` | User profile |
| PUT | `/users/{uid}` | Update user profile |
| GET | `/reviews?targetId=X&targetType=Y` | Fetch reviews |
| POST | `/reviews` | Submit review |
| POST | `/reviews/{id}/helpful` | Mark review helpful |
| POST | `/reviews/menu-ratings` | Submit menu item ratings |
| POST | `/subscriptions/verify` | Server-side receipt verification |
| GET | `/health` | API health check |

**Authentication:** Firebase ID token in `Authorization: Bearer <token>` header. Guest mode allows limited unauthenticated access.

---

## Backend

The backend is a Node.js serverless API deployed on Vercel:

```
hey-cape-cod-backend/
├── api/                    # Vercel serverless functions
│   ├── chat/index.js       # OpenAI GPT-4 integration
│   ├── pois/               # Firestore POI queries
│   ├── stories/            # Story retrieval
│   ├── weather/            # WeatherKit proxy + NOAA tides
│   ├── traffic/            # Bridge condition data
│   ├── voice/              # WebSocket relay (needs long-lived server)
│   └── user/               # Profile CRUD
├── lib/
│   ├── auth-middleware.js  # Firebase token verification
│   ├── openai-client.js    # GPT-4 wrapper
│   ├── firebase-admin.js   # Firestore/Auth admin
│   ├── rate-limiter.js     # Daily usage limits
│   └── cost-controls.js    # API spend budgets
└── vercel.json             # Deployment config
```

**Key Dependencies:** firebase-admin, openai, ws, cors, helmet, sanitize-html, @vercel/kv

> **Note:** WebSocket connections are NOT supported on Vercel's free tier (10s timeout). The voice relay backend must be migrated to a long-lived server platform (Railway, Render, or Fly.io) for production voice support.

---

## Data Strategy

### Three-Tier Loading
1. **SwiftData Cache** (Tier 1): Fastest. Loaded immediately on launch via `POICacheManager`. Provides instant UI with last-known data.
2. **API Fetch** (Tier 2): Freshest. Replaces cache on success. Runs in background after initial cache load.
3. **Bundled Content** (Tier 3): Always available. 15+ hardcoded Cape Cod POIs with full story variants, 12 curated tours, and 8 restaurants. Never deleted. Used when cache is empty and API is unreachable.

### Bundled Content (`BundledContent.swift`)
Contains ~1000 lines of offline-available data:
- **POIs**: Nauset Light Beach, Chatham Lighthouse, Provincetown Commercial Street, Cape Cod National Seashore, Sandwich Boardwalk, Hyannis Main Street, Race Point Beach, Wellfleet Drive-In, Falmouth Heights Beach, Chatham Pier, Pilgrim Monument, Cape Cod Canal, Nickerson State Park, Brewster General Store, Mashpee Commons
- **Tours**: 12 curated themed tours with full stop lists and descriptions
- **Restaurants**: 8 Cape Cod restaurants with menus, prices, ratings, and dietary tags

---

## Authentication

### Supported Methods
1. **Sign in with Apple** — AuthenticationServices framework
2. **Google Sign-In** — Google Identity SDK
3. **Email/Password** — Firebase Auth
4. **Guest Mode** — No authentication, limited daily usage

### Flow
1. Onboarding presents auth options
2. `AuthManager` handles credential exchange with Firebase
3. Firebase ID token stored and refreshed automatically
4. `APIClient` injects token into all API requests
5. `UserProfile` created in SwiftData, synced to Firestore
6. Session restored from Keychain on cold launch

---

## Subscriptions

### Products
| Product | ID | Price | Billing |
|---------|----|-------|---------|
| Monthly | `capecod_monthly` | $4.99/mo | Auto-renewable |
| Annual | `capecod_annual` | $29.99/yr | Auto-renewable (save 50%) |

### Premium Features
- Unlimited AI conversations (chat + voice)
- All audio stories
- Custom AI tour generation
- No daily usage limits

### Implementation
- **StoreKit 2** with `Product.products(for:)` and `product.purchase()`
- Transaction listener via `Transaction.updates` for real-time entitlement tracking
- Server-side receipt verification via `/subscriptions/verify`
- Family Sharing support
- `UserProfile` synced with subscription status

---

## Accessibility

- **VoiceOver**: Labels, hints, and traits on all interactive elements
- **Dynamic Type**: Full support from xSmall to accessibility3 via `@ScaledMetric`
- **Reduce Motion**: Respects `UIAccessibility.isReduceMotionEnabled`, disables animations
- **Haptic Feedback**: Selection (light), tap (medium), success/warning/error feedback
- **Color Contrast**: WCAG AA compliant color pairs
- **Large Content Viewer**: Supported for key UI elements

---

## Dependencies

### iOS App
| Framework | Usage |
|-----------|-------|
| SwiftUI | UI framework |
| SwiftData | Local persistence (iOS 17+) |
| WeatherKit | Apple weather data |
| CoreLocation | GPS, geofencing, geocoding |
| MapKit | Map visualization |
| StoreKit 2 | In-app subscriptions |
| AuthenticationServices | Sign in with Apple |
| AVFoundation | Audio recording/playback |
| Accelerate | Audio signal processing |
| CoreSpotlight | Search indexing |
| WidgetKit | Home screen widgets |
| AppIntents | Siri shortcuts |

### Third-Party
| Package | Version | Usage |
|---------|---------|-------|
| MacPaw/OpenAI | 0.3.0+ | Chat streaming SDK |

---

## Build Configuration

```yaml
Product Name: HeyCapeCod
Bundle Identifier: com.heycapecod
Deployment Target: iOS 17.0
Swift Language Version: 5.9
Strict Concurrency: complete
Xcode: 15.0+
```

### Entitlements
- iCloud: Key-value store, Documents, CloudKit
- HealthKit: Read/write access
- Background Modes: Location updates, audio playback
- Siri & Shortcuts

### Info.plist Permissions
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `NSMicrophoneUsageDescription`
- `NSHealthShareUsageDescription`

---

## Development Notes

### Swift 6 Concurrency
All `@Observable` service classes use `@preconcurrency @MainActor` for strict Sendable compliance. Init methods that access MainActor-isolated stored properties defer initialization to `Task { @MainActor in }` blocks to satisfy Swift 6's nonisolated init requirement.

### File Consolidation Strategy
To avoid Xcode project file (pbxproj) registration issues, several model and service definitions are consolidated into existing compiled files:
- Tour models (`GuidedTour`, `TourCategory`) → `BundledContent.swift`
- Restaurant/Review models → `Location.swift`
- `TourGeneratorService` → `POIService.swift`
- `ReviewService` → `ChatService.swift`
- Bundled restaurant data → `BundledContent.swift`

### Code Style
- `@Observable` over `ObservableObject` (iOS 17+)
- `async/await` over Combine publishers
- Singleton pattern for services (`static let shared`)
- Three-letter prefix `Cod` for custom UI components
- Cape Cod themed naming throughout (ocean, sand, drift, shell, etc.)
