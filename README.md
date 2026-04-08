# ArmaFit - Fitness Tracking for Athletes and Coaches

A Flutter application designed for athletes and coaches to track workouts, monitor weight progress, and communicate through built-in messaging.

## Features

- **Authentication** - Login and registration
- **Workout Plans** - Create, view, and manage workout plans
- **Session Logging** - Log and track workout sessions
- **Weight Tracking** - Monitor weight changes over time with charts
- **Coach-Athlete Management** - Connect coaches with athletes
- **Messaging** - In-app conversations between users

## Tech Stack

- **Framework**: Flutter (SDK ^3.11.1)
- **State Management**: Provider
- **Navigation**: GoRouter
- **Local Storage**: SharedPreferences
- **HTTP Client**: http package
- **Charts**: fl_chart
- **Internationalization**: intl

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── core/                     # Core utilities
│   ├── constants.dart        # App-wide constants
│   ├── api_client.dart       # HTTP client configuration
│   └── storage_service.dart  # Local storage wrapper
├── models/                   # Data models
│   ├── user.dart
│   ├── message.dart
│   ├── weight_entry.dart
│   ├── workout_plan.dart
│   ├── workout_session.dart
│   └── coach_athlete.dart
├── services/                 # Business logic & API calls
│   ├── auth_service.dart
│   ├── weight_service.dart
│   ├── workout_plan_service.dart
│   ├── workout_session_service.dart
│   ├── coach_athlete_service.dart
│   └── message_service.dart
├── providers/                # State management (Provider pattern)
│   ├── auth_provider.dart
│   ├── weight_provider.dart
│   ├── workout_plan_provider.dart
│   ├── workout_session_provider.dart
│   ├── coach_athlete_provider.dart
│   └── message_provider.dart
└── screens/                  # UI screens
    ├── login_screen.dart
    ├── register_screen.dart
    ├── home_screen.dart
    ├── weight_screen.dart
    ├── workout_plan_detail_screen.dart
    ├── create_workout_plan_screen.dart
    ├── log_session_screen.dart
    ├── workout_session_detail_screen.dart
    ├── coach_athlete_screen.dart
    ├── conversations_screen.dart
    └── chat_screen.dart
```

## Getting Started

### Prerequisites

- Flutter SDK ^3.11.1
- Dart SDK
- A device/emulator (iOS, Android, macOS, Windows, Linux, or Web)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd Armafit-Frontend
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Supported Platforms

- iOS
- Android
- macOS
- Windows
- Linux
- Web

## Development

Run the app in debug mode:
```bash
flutter run
```

Run tests:
```bash
flutter test
```

Analyze code:
```bash
flutter analyze
```

## License

This project is proprietary and confidential.
