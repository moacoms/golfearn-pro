# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

Golfearn Pro is a Flutter CRM app for golf lesson professionals. It shares a Supabase backend with the Golfearn web project (golfearn.com).

**Live URL**: https://golfearn-pro.vercel.app

## Essential Commands

```bash
# Install dependencies
flutter pub get

# Run (web)
flutter run -d chrome --web-port 5000

# Build web
flutter build web --release

# Deploy to Vercel
vercel deploy --prod --yes

# Code generation (Riverpod providers)
dart run build_runner build --delete-conflicting-outputs
```

## Architecture

### Tech Stack
- **Framework**: Flutter 3.x (SDK >=3.8.0)
- **State**: Riverpod (with riverpod_generator annotations)
- **Navigation**: GoRouter (shell routes for bottom nav)
- **Backend**: Supabase (shared instance)
- **Charts**: fl_chart
- **UI**: flutter_screenutil

### Feature Module Structure
Each feature follows clean architecture:
```
lib/features/<feature>/
├── data/
│   ├── models/        # Supabase JSON models
│   └── repositories/  # Repository implementations
├── domain/
│   └── entities/      # Domain entities
└── presentation/
    ├── pages/         # UI screens
    └── providers/     # Riverpod providers
```

### Current Features (Bottom Nav)
1. **홈** (`/home`) - Dashboard with charts, alerts, upcoming lessons
2. **학생관리** (`/students`) - Student CRUD with search/filter
3. **스케줄** (`/schedule`) - Weekly calendar, recurring lessons
4. **레슨노트** (`/lessons`) - Lesson notes with improvements/homework
5. **패키지** (`/packages`) - Lesson package management
6. **설정** (`/settings`) - Profile edit, app settings, logout

### Additional Routes
- `/income` - Income tracking with category/payment stats
- `/analysis` - AI swing analysis (WIP)

### Key Files
- `lib/core/router/app_router.dart` - All routes and auth redirect
- `lib/shared/widgets/main_scaffold.dart` - Bottom nav + shell
- `lib/core/services/supabase_service.dart` - DB wrapper
- `lib/features/auth/presentation/providers/auth_controller.dart` - Auth state

### Database Tables (Supabase)
- `profiles` - User profiles (is_lesson_pro, is_student flags)
- `lesson_students` - Student records
- `lesson_schedules` - Lesson appointments
- `lesson_packages` - Course packages
- `lesson_notes` - Lesson documentation
- `pro_income_records` - Income records

## Conventions

- **Providers**: Use `@riverpod` annotations, generate with build_runner
- **Entities**: Plain Dart classes with copyWith, fromJson, toJson
- **Sizing**: Always use flutter_screenutil (.sp, .w, .h, .r)
- **Colors**: Primary green is `Color(0xFF10B981)`
- **Language**: UI text in Korean, code in English
- **Imports**: Relative imports within features, package imports for cross-feature

## Environment

Required `.env` file:
```
SUPABASE_URL=https://bfcmjumgfrblvyjuvmbk.supabase.co
SUPABASE_ANON_KEY=<key>
ANTHROPIC_API_KEY=<key>
```

## Deployment

Web builds deploy to Vercel. The `vercel.json` configures SPA routing with `build/web` as output directory.
