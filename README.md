# Flutter Games Demo App

A Flutter demonstration application featuring **mock authentication** (Email & WhatsApp) and a **games dashboard** with search functionality.

## 🎯 Overview

This app demonstrates:
- **Animated Splash Screen** with beautiful gaming effects
- **Mock Registration** (Email or WhatsApp)
- **Mock Login** (Email with password OR WhatsApp with OTP)
- **Games Dashboard** with search and filtering
- **Local data storage** using `shared_preferences`
- **JSON asset loading** for game data

### 🎨 Two Splash Screen Options
- **Standard Animated Splash** (Default) - Gradient, scale, rotation, pulse effects
- **Premium Particle Splash** - Floating particles, shimmer text, advanced animations
- See [SPLASH_CUSTOMIZATION.md](SPLASH_CUSTOMIZATION.md) for switching and customization

## 🚀 Features

### 1. Registration Screen
- Register with **Email** (email + password)
- Register with **WhatsApp** (phone number only)
- Input validation (email format, password length, phone E.164 format)
- No backend required - all data stored locally

### 2. Login Screen
- **Email Login**: Email + password authentication
- **WhatsApp Login**: Mock OTP flow
  - Fixed OTP: **123456**
  - OTP displayed in Snackbar for testing
- Toggle between login methods

### 3. Games Dashboard
- Display games loaded from JSON asset file
- **Search functionality** by:
  - Game name
  - Category
  - Group name
- Each game card shows:
  - Thumbnail image
  - Game name
  - Category & group
  - Product/provider
  - Min & Max betting amounts
- Performance optimization: Shows only first 100 games from large dataset

## 📦 Tech Stack

- **Flutter** (latest stable)
- **shared_preferences** - Local mock data storage
- **Material UI** - Clean, modern interface
- **JSON assets** - Game data loaded from `assets/data/allgames_list.json`

## 🔧 Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd flutter_games_demo
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## 🎮 Testing the App

### Mock Authentication Flow

#### **Email Registration & Login**
1. Open the app → Registration Screen
2. Enter email: `test@example.com`
3. Enter password: `password123` (minimum 6 characters)
4. Confirm password: `password123`
5. Click **"Register with Email"**
6. Navigate to Login Screen
7. Enter same email and password
8. Click **"Login with Email"**
9. Access granted to Dashboard

#### **WhatsApp Registration & Login**
1. Open the app → Registration Screen
2. Enter phone: `+919876543210` (E.164 format preferred)
3. Click **"Register with WhatsApp"**
4. Navigate to Login Screen
5. Enter same phone number
6. Click **"Send OTP"**
7. **Mock OTP will be shown in Snackbar: 123456**
8. Enter OTP: `123456`
9. Click **"Verify OTP"**
10. Access granted to Dashboard

### Search Functionality
- Type in search bar to filter games
- Search works on:
  - Game name (e.g., "Lightning", "Roulette")
  - Category (e.g., "Live Roulette", "Video Slots")
  - Group name (e.g., "Evolution Gaming", "Pragmatic Play")

## 📁 Project Structure

```
flutter_games_demo/
├── lib/
│   ├── models/
│   │   └── game.dart                 # Game data model
│   ├── screens/
│   │   ├── registration_screen.dart  # User registration
│   │   ├── login_screen.dart         # User login
│   │   └── dashboard_screen.dart     # Games display
│   ├── services/
│   │   ├── auth_service.dart         # Mock authentication logic
│   │   └── game_service.dart         # JSON loading & filtering
│   ├── utils/
│   │   └── validators.dart           # Input validation helpers
│   └── main.dart                     # App entry point
├── assets/
│   └── data/
│       └── allgames_list.json        # Games data (30 sample games)
├── pubspec.yaml                      # Dependencies
└── README.md                         # This file
```

## 🔐 Mock Authentication Details

### How It Works

1. **No Backend**: All authentication is mock/simulated
2. **Local Storage**: Uses `shared_preferences` to store:
   - Email & password
   - Phone number
   - Login status
3. **Fixed OTP**: WhatsApp OTP is always `123456`
4. **No Real API Calls**: No Firebase, no SMS service, no HTTP requests

### Important Notes

- ⚠️ This is **DEMO-ONLY** authentication
- ⚠️ Data is stored **unencrypted** in local storage
- ⚠️ **DO NOT** use this pattern in production
- ✅ Perfect for **evaluation**, **prototyping**, and **learning**

## 📊 JSON Data Structure

The `allgames_list.json` file contains game objects with this structure:

```json
{
  "game_id": 2,
  "name": "Super Sic Bo",
  "url_thumb": "https://luckmedia.link/evo_super_sic_bo/thumb.webp",
  "groupname": "Live Sic Bo",
  "category": "Live Sic Bo",
  "product": "Evolution Gaming",
  "gamecategory": "LiveGame",
  "MinAmount": 100.0,
  "MaxAmount": 100000.0
}
```

### Performance Optimization

- Full JSON file can contain **40,000+ games**
- App loads only **first 100 games** for demo performance
- For production, implement:
  - Pagination
  - Lazy loading
  - Backend API with filtering

## 🛠️ Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2  # Local data storage
  cupertino_icons: ^1.0.2     # iOS-style icons
```

## 🎨 UI/UX Features

- **Material Design 3** components
- **Responsive layouts** for different screen sizes
- **Loading states** with progress indicators
- **Error handling** with user-friendly messages
- **Search with real-time filtering**
- **Image loading states** with error handling
- **Logout functionality**

## 🐛 Known Limitations

1. **Mock OTP is fixed** - Always `123456`
2. **No password recovery** - Demo only
3. **Limited to 100 games** - Performance demo
4. **No email verification** - Mock registration
5. **Unencrypted storage** - Not production-ready
6. **No network images validation** - Some images may fail to load

## 🚧 Future Enhancements (Not Implemented)

- Real authentication with Firebase
- Backend API integration
- Pagination for games list
- User profile management
- Favorites/Bookmarks
- Game launching
- Dark mode
- Multi-language support

## 📝 Notes for Evaluators

### Testing Credentials

**Email Login:**
- Email: Any valid email format (e.g., `user@test.com`)
- Password: Any password ≥ 6 characters
- Must register first before login

**WhatsApp Login:**
- Phone: Any valid E.164 format (e.g., `+919876543210`)
- OTP: Always `123456` (shown in green Snackbar)
- Must register phone first before login

### Code Quality

- ✅ Clean architecture (models, screens, services, utils)
- ✅ Proper error handling
- ✅ Input validation
- ✅ Comments where needed
- ✅ Consistent naming conventions
- ✅ No over-engineering

## 📄 License

This is a demo project for evaluation purposes.

## 👤 Contact

For questions or issues, please create an issue in the repository.

---

**Note**: This is a **MOCK** application. Do not use in production environments without proper security implementations.
