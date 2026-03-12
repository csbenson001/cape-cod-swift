# Cape Cod Area Preferences — Design Spec

## Overview
Add region and town preferences to user profiles, allowing users to specify which areas of Cape Cod they're visiting or interested in. Presented via a reusable picker with Map (default) and List tabs.

## Regions & Towns

| Region | Towns |
|--------|-------|
| Upper Cape | Bourne, Falmouth, Sandwich, Mashpee |
| Mid Cape | Barnstable, Yarmouth, Dennis |
| Lower Cape | Harwich, Brewster, Chatham, Orleans |
| Outer Cape | Eastham, Wellfleet, Truro, Provincetown |

## Data Model

### CapeCodRegion enum
- Cases: `.upperCape`, `.midCape`, `.lowerCape`, `.outerCape`
- Properties: `displayName`, `towns: [String]`
- Identifiable, CaseIterable

### UserProfile (SwiftData)
- Add `preferredRegions: [String]` — region rawValues
- Add `preferredTowns: [String]` — town names
- Include in `toFirestoreData()` and `updateFromFirestore()`

### UserProfileManager (UserDefaults-backed)
- `preferredRegions: [CapeCodRegion]` — get/set via UserDefaults
- `preferredTowns: [String]` — get/set via UserDefaults

## UI: AreaPickerView (reusable sheet)

### Map Tab (default)
- Cape Cod silhouette shape (SwiftUI Path/Shape)
- 4 tappable region bubbles positioned on the silhouette
- Tapping a region: selects the region, shows town dots within it
- Tapping a town dot: toggles individual town selection
- Selected items shown as pills at bottom
- Ocean blue theme, haptic feedback on selection

### List Tab
- Region chips at top (horizontal scroll, multi-select capsules)
- Town chips below, filtered to show towns from selected regions (or all if no region selected)
- Same selection state shared with Map tab
- Matches existing chip pattern (CodButtonPressStyle)

### Shared behavior
- Multi-select for both regions and towns
- "Done" button in toolbar to dismiss
- Selections saved immediately on dismiss

## Integration Points

### Onboarding
- New page inserted as page 3 (after OnboardingInterestsPage, before OnboardingReadyPage)
- Title: "Where on the Cape?"
- Subtitle: "Tap regions or towns you want to explore"
- Optional — user can skip (existing skip button)
- Selections saved in `completeOnboarding()`

### ProfileView
- New row: "Cape Cod Areas" in a section after Visit Type
- Subtitle shows current selections (e.g., "Mid Cape, Chatham")
- Tapping opens AreaPickerView as a sheet

## Out of Scope
- Content filtering based on area preferences (future work)
- Complex map interactions (pinch/zoom/pan)
- Map annotations beyond region bubbles and town dots
