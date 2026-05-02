# Cozy Chores 🏡

A warm, human-centered chore management app for iOS. Built with SwiftUI and designed around empathy, not pressure.

## ✨ Features

### 🎭 Mood-Based Interface
- **Three mood states**: Fine, Manageable, Too Much
- Adaptive UI that adjusts chore visibility based on how you're feeling
- Quick wins prioritization (shorter tasks first)
- Snooze functionality for overwhelming days

### 📚 Preset Chore Library
- 29 curated preset chores across 4 rooms (Kitchen, Bedroom, Bathroom, Living Room)
- Auto-add during onboarding (2 chores per selected room)
- Browse library to add more anytime
- Smart scheduling with load balancing

### 📊 Progress Tracking
- Weekly progress visualization
- Streak tracking with celebration
- Activity feed
- Badge system for achievements

### 🎨 Cozy Design System
- Warm, earth-tone palette (beeswax amber, unbleached linen, warm brown)
- Serif headers with clean sans-serif body text
- Gentle animations and micro-interactions
- No harsh colors or urgent language

## 🏗️ Architecture

### Tech Stack
- **SwiftUI** - Modern declarative UI
- **Swift Concurrency** - async/await for smooth performance
- **Local Storage** - JSON-backed persistence (Supabase-ready)
- **MVVM Pattern** - Clean separation of concerns

### Key Components
- `AppState` - Central state management
- `LocalStore` - Persistence layer
- `PresetChoreLibrary` - Curated chore templates
- `CozyTheme` - Design system tokens

### Screen Flow
```
Splash → Welcome → Onboarding (5 steps) → Dashboard
                                          ├─ Home (Dashboard with mood controls)
                                          ├─ Chores (Browse library, manage tasks)
                                          ├─ Calendar (Schedule view)
                                          └─ Profile (Settings, badges, stats)
```

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- macOS Sonoma+

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/cozy-chores.git
cd cozy-chores
```

2. Open in Xcode:
```bash
open CozyChores.xcodeproj
```

3. Build and run (⌘R)

### Testing Individual Screens

The project includes preview configurations in `AppFlowPreviews.swift`:
- Onboarding flow
- Dashboard with sample data
- Chores screen
- Chore library
- Profile view

To view previews:
1. Open any preview file in Xcode
2. Press ⌥⌘↩ (Option + Command + Return) to show the canvas
3. Select the preview you want to view

### Resetting App Data

To test onboarding from scratch:
1. Delete the app from the simulator
2. Rebuild and run

Or use launch arguments:
1. Edit Scheme (⌘<)
2. Run → Arguments → Add `-reset YES`

## 📂 Project Structure

```
CozyChores/
├── Models/
│   ├── Models.swift           # Core data models (Chore, Profile, Room)
│   ├── PresetChoreLibrary.swift
│   └── AppState.swift         # Central state management
├── Views/
│   ├── Onboarding/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   └── DashboardView.swift # Mood-based dashboard
│   ├── Chores/
│   │   ├── ChoresView.swift
│   │   ├── ChoreLibraryView.swift
│   │   └── ChoreDetailView.swift
│   ├── Calendar/
│   └── Profile/
├── Services/
│   ├── LocalStore.swift       # Persistence
│   └── BadgeService.swift
├── Theme/
│   └── CozyTheme.swift        # Design tokens
└── Utilities/
    ├── AppRouter.swift
    └── DragDropManager.swift
```

## 🎯 Key User Journeys

### First-Time User
1. Sees welcome screen
2. Completes 5-step onboarding (name, home name, rooms, etc.)
3. System auto-adds 2 preset chores per selected room
4. First chores distributed across days 1-8 (1 per day max)
5. Lands on dashboard with personalized greeting

### Daily Use
1. Opens app → sees today's chores
2. Selects mood (Fine/Manageable/Too Much)
3. UI adapts: shows 1-3 chores or all based on mood
4. Can snooze overwhelming tasks to tomorrow
5. Completes chores → sees confetti + updates streak

### Adding More Chores
1. Taps "Browse chore library" on Chores tab
2. Sees presets filtered by their rooms
3. Taps to add → scheduled on least-busy day in next 7 days
4. Toast confirms: "Added to [Room]"

## 🎨 Design Philosophy

**Cozy Chores is built on three principles:**

1. **Empathy First** - The app adapts to your mental state, not the other way around
2. **Quick Wins Matter** - Shorter tasks shown first for momentum
3. **Gentle Accountability** - Progress tracking without guilt or pressure

**Color Palette:**
- Background: #FBF8F3 (unbleached linen)
- Primary: #2B2520 (warm brown)
- Accent: #BA7517 (beeswax amber)
- Success: #4CAF82 (sage green)
- Alert: #E57373 (warm coral)

## 🧪 Testing

Run tests:
```bash
# In Xcode
⌘U
```

Or via command line:
```bash
xcodebuild test -scheme CozyChores -destination 'platform=iOS Simulator,name=iPhone 15'
```

## 📝 Roadmap

- [ ] Recurring chore templates
- [ ] Multi-user households
- [ ] Shared spaces
- [ ] Custom badge creation
- [ ] Insights dashboard
- [ ] Export/import chore data
- [ ] Supabase backend integration
- [ ] Apple Watch companion app

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Design inspired by warm, human-centered UX principles
- Icons: SF Symbols
- Fonts: System (San Francisco, New York)

## 📧 Contact

Questions? Reach out at [your@email.com]

---

**Built with ❤️ and SwiftUI**
