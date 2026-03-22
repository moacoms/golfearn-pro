# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

Golfearn(골프런)은 골프 레슨프로를 위한 CRM 앱입니다. 골프에 집중하되, 향후 다른 스포츠 확장을 위한 멀티스포츠 구조(sport_constants.dart)가 내장되어 있습니다.
Supabase 백엔드를 Golfearn 웹 프로젝트(golfearn.com)와 공유합니다.

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

### Multi-Sport Support
프로 가입 시 종목을 선택하면 UI가 동적으로 변경됩니다:
- **종목 설정**: `lib/core/constants/sport_constants.dart` — 종목별 아이콘, 레슨타입, 라벨 등
- **지원 종목**: 골프, 테니스, 배드민턴, 수영, 필라테스/요가, 기타
- **동적 변경**: 레슨 타입 옵션, 학생 정보 라벨, 노트 힌트, 대시보드 아이콘
- **DB 컬럼**: `profiles.sport_type` (TEXT, 기본값 'golf')

### Current Features (Bottom Nav)
1. **홈** (`/home`) - Dashboard with charts, alerts, upcoming lessons
2. **학생관리** (`/students`) - Student CRUD with search/filter
3. **스케줄** (`/schedule`) - Weekly calendar, recurring lessons
4. **레슨노트** (`/lessons`) - Lesson notes with improvements/homework
5. **패키지** (`/packages`) - Lesson package management
6. **설정** (`/settings`) - Profile edit, sport type change, app settings, logout

### Additional Routes
- `/income` - Income tracking with category/payment stats
- `/analysis` - AI swing analysis (WIP)

### Key Files
- `lib/core/router/app_router.dart` - All routes and auth redirect
- `lib/core/constants/sport_constants.dart` - Sport-specific configs (icons, lesson types, labels)
- `lib/shared/widgets/main_scaffold.dart` - Bottom nav + shell
- `lib/core/services/supabase_service.dart` - DB wrapper
- `lib/features/auth/presentation/providers/auth_controller.dart` - Auth state
- `lib/features/auth/presentation/providers/auth_provider.dart` - currentSportTypeProvider

### Database Tables (Supabase)
- `profiles` - User profiles (is_lesson_pro, is_student, sport_type flags)
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
