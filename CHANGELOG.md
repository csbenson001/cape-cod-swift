# Changelog

All notable changes to Hey Cape Cod are documented in this file.

## [1.0.0] - 2026-03-07

### Added

#### Voice & Conversation
- Voice-powered AI conversations about Cape Cod using OpenAI Realtime API
- PCM16 audio capture at 24kHz with Voice Activity Detection
- Gapless streaming audio playback for AI responses
- WebSocket connection with reconnection logic and auth token injection
- Text chat fallback when voice is unavailable

#### GPS Stories
- GPS-triggered audio stories at 50+ Cape Cod landmarks
- 20-geofence management with dynamic re-evaluation on movement
- 24-hour cooldown per POI to prevent repeat triggers
- Story queue for back-to-back triggers
- Kids, Teen, Adult, and Family content modes

#### Explore & Map
- Interactive map with 100+ categorized Points of Interest
- 10 POI categories: beaches, restaurants, lighthouses, museums, nature, shopping, marinas, historic, entertainment, lodging
- 15 Cape Cod towns across 4 regions (Upper, Mid, Lower, Outer Cape)
- Loading skeletons and offline banner for connectivity awareness

#### Weather & Tides
- WeatherKit integration with NOAA Weather API fallback
- NOAA NDBC Buoy 44018 data: water temperature, wave height, wave period, wind
- Tide predictions from NOAA CO-OPS for 7 Cape Cod stations
- Tide chart with Swift Charts (catmull-rom interpolation, current time marker)
- Smart beach recommendation engine scoring 12 beaches on wind shelter, waves, crowds, UV, and tide
- Beach conditions report card with shark advisory, lifeguard status, UV warnings

#### Traffic
- Live Sagamore and Bourne Bridge delay times
- Route 6 and Route 3 congestion tracking
- Auto-refresh every 5 minutes
- Stale data indicators

#### Auth & Subscriptions
- Sign in with Apple (required for App Store)
- Google Sign-In and email/password support
- Guest mode with usage tracking and upgrade prompts
- Session persistence and secure token refresh
- UserProfile SwiftData model with Firestore sync
- StoreKit 2 subscriptions: Monthly ($4.99) and Annual ($29.99)
- Free trial (7 days) with Family Sharing support
- Paywall gating: 3 voice conversations/day, 5 GPS stories/day (free tier)
- Server-side receipt verification

#### Onboarding
- 4-page onboarding flow: Welcome, Choose Mode, Select Interests, Sign In
- 10 interest categories with pill selection
- Smooth page transitions with skip option

#### Backend Integration
- APIClient with environment switching (dev/staging/production)
- Three-tier data loading: SwiftData cache, API fetch, BundledContent fallback
- Codable models for POI, Story, Traffic, Weather, Tide, Chat
- SwiftData caching layer for offline resilience

#### Design System
- Cape Cod-inspired color palette: ocean blue, sunset orange, seafoam, sand, driftwood
- Custom typography with CodTextStyle (heroTitle, sectionTitle, cardTitle, body, caption, metric)
- Spacing system (CodSpacing), corner radii (CodRadius), shadow presets (CodShadow)
- Custom tab bar with raised voice FAB button
- AdaptiveCardStyle modifier

#### Performance
- Content prefetching for nearby POIs
- Aggressive weather caching (15-min TTL)
- WebSocket pre-connect when voice tab selected
- Launch warmup for critical paths

#### Accessibility
- VoiceOver support with semantic labels and hints
- Dynamic Type support across all text
- Reduce Motion respect (disables animations)
- WCAG AA color contrast
- Haptic feedback on all interactive elements (CodHaptic)

#### Widgets
- Beach Conditions widget (small): temperature, water temp, beach recommendation
- Bridge Traffic widget (medium): Sagamore/Bourne delay, status, recommendation

#### Platform Integration
- Siri Shortcuts: "Ask Cape Cod", "Check Traffic", "Check Tides"
- Spotlight indexing for all POIs
- Splash screen with lighthouse beam animation

#### Testing
- Unit tests: models, traffic, geofence, paywall, weather, audio, user profile, app state
- UI tests: onboarding flow, tab navigation, voice assistant, settings, explore, weather, traffic

### Technical Details
- iOS 17.0+ / Swift 5.9 / SwiftUI
- Strict concurrency (complete mode)
- XcodeGen project configuration
- OpenAI Swift SDK for AI conversations
- WeatherKit + NOAA (NWS, NDBC, CO-OPS) for weather data
- StoreKit 2 for subscriptions
- SwiftData for local persistence
- CoreLocation + CoreSpotlight + AppIntents
