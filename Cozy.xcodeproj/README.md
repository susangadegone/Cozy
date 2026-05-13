# Cozy

A SwiftUI-based iOS application for managing household chores and tasks.

## Features

- User authentication (email/password and social sign-in)
- Onboarding flow for new users
- Chore management and tracking
- Insights and analytics
- Clean, modern UI with custom theming

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/cozy.git
   cd cozy
   ```

2. Open the project in Xcode:
   ```bash
   open Cozy.xcodeproj
   ```
   or if using a workspace:
   ```bash
   open Cozy.xcworkspace
   ```

3. Build and run the project in Xcode (⌘+R)

## Project Structure

- **Views**: SwiftUI views for different screens
  - `SignUpView`: User registration interface
  - `OnboardingComponents`: Reusable onboarding UI elements
  - `AddChoreView`: Interface for adding new chores
  - `InsightsView`: Analytics and insights display

- **View Models**: Business logic and state management
- **Authentication**: User authentication and session management
- **Theme**: Custom theming with `CozyTheme`

## Architecture

This project follows the MVVM (Model-View-ViewModel) architecture pattern with SwiftUI.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

[Add your license here]

## Contact

[Add your contact information here]
