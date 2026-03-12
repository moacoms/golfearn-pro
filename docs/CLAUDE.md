# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Golfearn Pro is a Flutter application for golf lesson professionals to manage students, schedules, packages, and income. It's part of the Golfearn ecosystem that includes a Next.js website (golfearn.com) and shares a Supabase backend.

## Essential Commands

### Development
```bash
# Install dependencies
flutter pub get

# Run the app in development mode
flutter run

# Run on web with specific port
flutter run -d chrome --web-port 5000

# Run on specific device
flutter run -d <device_id>

# Hot reload (automatically available in debug mode)
# Press 'r' to hot reload, 'R' to hot restart
```

### Build Commands
```bash
# Build for Android
flutter build apk

# Build for iOS
flutter build ipa

# Build for web
flutter build web

# Build app bundle for Play Store
flutter build appbundle
```

### Code Generation
```bash
# Generate code (for Riverpod, Freezed, JSON serialization)
dart run build_runner build

# Generate and delete conflicting outputs
dart run build_runner build --delete-conflicting-outputs

# Watch for changes and regenerate
dart run build_runner watch
```

### Testing and Analysis
```bash
# Run tests
flutter test

# Analyze code
flutter analyze

# Check Flutter environment
flutter doctor
```

## Code Architecture

### State Management
- **Riverpod** for state management with providers
- Code generation using `riverpod_generator` and annotations
- Services exposed through providers (e.g., `supabaseServiceProvider`)

### Navigation
- **GoRouter** for declarative routing
- Authentication-aware routing with redirect logic in `lib/core/router/app_router.dart:22-38`
- Shell routes for bottom navigation structure

### Backend Integration
- **Supabase** client shared with existing Golfearn web project
- Connection configured in `lib/main.dart:14-17` using environment variables
- Service wrapper in `lib/core/services/supabase_service.dart` for common operations

### Feature Structure
```
lib/features/
├── auth/           # Authentication (login, register)
├── students/       # Student management
├── schedule/       # Lesson scheduling  
├── packages/       # Package/course management
├── lessons/        # Lesson notes
├── income/         # Income tracking
└── analysis/       # Video analysis with Claude AI
```

### Core Services
- **SupabaseService** (`lib/core/services/supabase_service.dart`): Database operations, auth, storage
- **ClaudeService** (`lib/core/services/claude_service.dart`): AI-powered swing analysis and lesson note generation

### Database Schema
Key tables from shared Supabase instance:
- `profiles` - User profiles with role flags (`is_lesson_pro`, `is_student`)
- `lesson_students` - Student records managed by pros
- `lesson_schedules` - Lesson appointments and scheduling
- `lesson_packages` - Course packages and pricing
- `lesson_notes` - Lesson documentation
- `pro_income_records` - Income tracking

## Environment Configuration

Required environment variables in `.env` file:
```env
SUPABASE_URL=https://bfcmjumgfrblvyjuvmbk.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
ANTHROPIC_API_KEY=your_claude_api_key_here
```

## Development Workflow

1. **Authentication Flow**: App checks user authentication status and redirects appropriately
2. **Role-based Access**: Users must have `is_lesson_pro: true` in profiles table to access main features
3. **Real-time Updates**: Supabase real-time subscriptions for live data synchronization
4. **Responsive Design**: Uses `flutter_screenutil` with iPhone 13 design size (390x844)

## Key Dependencies

- `supabase_flutter` - Backend integration
- `flutter_riverpod` - State management
- `go_router` - Navigation
- `flutter_screenutil` - Responsive UI
- `table_calendar` - Calendar functionality
- `fl_chart` - Data visualization
- `image_picker`, `video_player`, `camera` - Media handling

## Documentation

All documentation is organized in the `docs/` folder:
- `docs/SETUP_GUIDE.md` - Development environment setup
- `docs/DEVELOPMENT_LOG.md` - Development progress tracking
- `docs/INTEGRATION.md` - Integration with existing Golfearn ecosystem
- `docs/CLAUDE.md` - This file (Claude Code guidance)

## Flutter SDK Configuration

Flutter SDK location: `C:\flutter_windows_3.41.4-stable`
PATH environment variable: `C:\flutter_windows_3.41.4-stable\bin`