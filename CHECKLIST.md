# Hey Cape Cod - v1.0.0 Release Checklist

## Build & Code Quality
- [x] Clean build with zero warnings (Xcode 15.2+)
- [x] Strict concurrency enabled (complete mode)
- [x] No force-unwraps except for known-safe static URLs
- [x] No hardcoded API keys in source (environment variables only)
- [x] All `@Observable` classes properly configured

## Testing
- [x] Unit tests pass (50+ model tests, service tests)
- [x] UI tests pass (onboarding, navigation, tabs, voice, settings, explore)
- [x] Backend API endpoint tests (scripts/test-api.sh) — all green
- [x] Tested on iPhone 15 Pro simulator
- [x] Tested on iPad (adaptive layout)

## Performance
- [x] App launch < 2 seconds (splash + warmup)
- [x] ContentPrefetcher warms caches on launch
- [x] Weather cache TTL: 15 minutes
- [x] Traffic cache TTL: 5 minutes
- [x] Tide cache TTL: 1 hour
- [x] POI cache TTL: 24 hours
- [x] WebSocket pre-connect on voice tab selection
- [x] Lazy loading on all list views
- [x] No memory leaks (Instruments verified)

## Accessibility
- [x] VoiceOver labels on all custom components
- [x] VoiceOver hints on interactive elements
- [x] VoiceOver grouping on composite cards
- [x] Decorative images hidden from VoiceOver
- [x] Dynamic Type supported (xSmall to accessibility3)
- [x] Reduce Motion respected (all animations conditional)
- [x] WCAG AA color contrast verified
- [x] All touch targets >= 44x44pt
- [x] Haptic feedback on all interactions (CodHaptic)
- [x] Semantic traits (.isButton, .isHeader) applied

## Features
- [x] Voice conversations (OpenAI Realtime API via WebSocket)
- [x] GPS-triggered stories (20-geofence management)
- [x] Interactive explore map with 100+ POIs
- [x] Weather dashboard (WeatherKit + NOAA fallback)
- [x] Tide predictions (7 stations via NOAA CO-OPS)
- [x] Bridge traffic (Sagamore & Bourne live status)
- [x] Beach conditions report card
- [x] Onboarding flow (4 pages)
- [x] Sign in with Apple + guest mode
- [x] StoreKit 2 subscriptions (monthly + annual)
- [x] Free tier gating (3 voice/day, 5 stories/day)
- [x] User profile with Firestore sync
- [x] Text chat fallback

## Platform Integration
- [x] Widgets: Beach Conditions (small), Bridge Traffic (medium)
- [x] Siri Shortcuts: Ask Cape Cod, Check Traffic, Check Tides
- [x] Spotlight indexing for all POIs
- [x] Lock screen Now Playing controls for story player
- [x] Background audio for story playback

## App Store
- [x] App icon (1024x1024 PNG)
- [x] Screenshots defined (6.7" and 6.1")
- [x] App Store metadata (title, subtitle, keywords, description)
- [x] Privacy policy URL configured
- [x] Privacy labels defined
- [x] Age rating: 4+
- [x] Subscription products configured in App Store Connect
- [x] Release notes written

## Design System
- [x] Cape Cod color palette (light + dark adaptive)
- [x] CodTextStyle typography system with Dynamic Type
- [x] CodSpacing + CodRadius + CodShadow tokens
- [x] CodAnimation presets (spring, quick, bouncy, stagger)
- [x] AdaptiveCardStyle (shadow in light, border in dark)
- [x] Custom tab bar with raised voice FAB
- [x] Loading skeletons for all async content
