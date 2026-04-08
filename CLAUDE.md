# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

Golfearn(골프런)은 골프 레슨프로를 위한 CRM 앱입니다. 골프에 집중하되, 향후 다른 스포츠 확장을 위한 멀티스포츠 구조(sport_constants.dart)가 내장되어 있습니다.
Supabase 백엔드를 Golfearn 웹 프로젝트(golfearn.com)와 공유합니다.
원래 golfearn.com(Next.js)에서 시작 → 맥 구매 후 Flutter로 전환하여 진행 중.

**Live URL**: https://golfearn-pro.vercel.app
**Production URL**: https://golfearn-pro-git-main-hdopens-projects.vercel.app

## Essential Commands

```bash
# Install dependencies
flutter pub get

# Run (web) — 로컬 개발은 .env fallback 사용
flutter run -d chrome --web-port 5000

# Build web (배포용) — 반드시 --dart-define 사용
flutter build web --release \
  --dart-define=SUPABASE_URL=https://bfcmjumgfrblvyjuvmbk.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<key>

# Code generation (Riverpod providers)
dart run build_runner build --delete-conflicting-outputs
```

> **주의**: `.env`는 assets에서 제거됨. 웹 빌드 시 `--dart-define`으로 환경변수를 주입해야 함.
> 로컬 `flutter run`은 `.env` 파일을 fallback으로 읽음.

## Architecture

### Tech Stack
- **Framework**: Flutter 3.41 (SDK >=3.8.0)
- **State**: Riverpod (with riverpod_generator annotations)
- **Navigation**: GoRouter (shell routes for bottom nav)
- **Backend**: Supabase (shared instance with golfearn.com)
- **Charts**: fl_chart
- **UI**: flutter_screenutil
- **Font**: Noto Sans KR (bundled asset + web font)
- **AI**: Claude API (swing analysis)
- **Web Renderer**: CanvasKit (default, HTML renderer deprecated in 3.41)

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

### Multi-Sport Support (비활성 상태)
향후 확장을 위한 구조가 코드에 내장되어 있으나, 현재 golf 전용으로 운영:
- `lib/core/constants/sport_constants.dart` — 종목별 아이콘, 레슨타입, 라벨 등
- `profiles.sport_type` DB 컬럼 존재 (기본값 'golf')
- sport_type DB 읽기/쓰기 코드는 주석 처리 상태 (활성화 시 주석 해제)

### Pro Features (Bottom Nav: 홈/학생관리/스케줄/레슨노트/패키지/설정)
1. **홈** (`/home`) - 대시보드: 오늘 일정, 주간 차트, 통계, 패키지 알림, 퀵액션
2. **학생관리** (`/students`) - 학생 CRUD, 검색/필터, 앱 연결 학생 배지
3. **스케줄** (`/schedule`) - 주간 캘린더, 반복 레슨, 패키지 연동 자동 차감
4. **레슨노트** (`/lessons`) - 레슨 내용/개선사항/숙제 기록
5. **패키지** (`/packages`) - 레슨권 관리, 진행률, 결제 상태
6. **설정** (`/settings`) - 프로필 편집, 기본 설정, 데이터 내보내기(CSV), 로그아웃

### Student Features (Bottom Nav: 홈/내 레슨/레슨노트/설정)
- 학생 대시보드: 총 레슨 횟수, 활성 패키지(진행률 바), 다가오는 레슨
- 내 레슨 (`/schedule`): student_id 기반 스케줄 조회, 프로 이름 표시, 읽기 전용 (FAB 숨김)
- 레슨노트 (`/lessons`): student_id 기반 노트 열람, 프로 이름 표시, 읽기 전용 (FAB/삭제 숨김, 상세 다이얼로그)
- 설정 (`/settings`): 프로필 수정 + 계정만 표시 (앱 설정/데이터 내보내기 등 프로 전용 항목 숨김)
- 레슨프로 찾기 (`/find-pro`): 프로 목록 + 레슨 신청 기능
- 레슨프로로 전환: 학생 → 프로 역할 변환

### Additional Routes
- `/income` - 수입 관리 (카테고리/결제방법별 통계)
- `/analysis` - AI 스윙 분석 (Claude API)
- `/find-pro` - 레슨프로 찾기 (학생용)

### Key Files
- `lib/core/router/app_router.dart` - All routes and auth redirect
- `lib/core/constants/sport_constants.dart` - Sport-specific configs (비활성)
- `lib/shared/widgets/main_scaffold.dart` - Bottom nav + shell
- `lib/core/services/supabase_service.dart` - DB wrapper
- `lib/core/services/claude_service.dart` - AI analysis service
- `lib/features/auth/presentation/providers/auth_controller.dart` - Auth state
- `lib/features/auth/presentation/providers/auth_provider.dart` - User/role providers

### Database Tables (Supabase)
- `profiles` - User profiles (is_lesson_pro, is_student, sport_type)
- `lesson_students` - Student records (user_id로 앱 사용자와 연결 가능)
- `lesson_schedules` - Lesson appointments
- `lesson_packages` - Course packages
- `lesson_notes` - Lesson documentation
- `pro_income_records` - Income records

### Supabase Trigger
- `on_auth_user_created` → `handle_new_user()`: 회원가입 시 profiles 자동 생성
- 주의: signUp metadata에 트리거가 모르는 필드를 넣으면 500 에러 발생
- 기존 golfearn.com의 point_wallets, referral_codes, user_experience 트리거는 삭제됨

## Conventions

- **Providers**: Use `@riverpod` annotations, generate with build_runner
- **Entities**: Plain Dart classes with copyWith, fromJson, toJson
- **Sizing**: Always use flutter_screenutil (.sp, .w, .h, .r)
- **Colors**: Primary green is `Color(0xFF10B981)`
- **Language**: UI text in Korean, code in English
- **Imports**: Relative imports within features, package imports for cross-feature
- **Font**: Noto Sans KR (bundled in assets/fonts, loaded via FontLoader in main.dart)

## Known Issues

- **한글 IME**: CanvasKit에서 한글 조합 중 ☒ 글리프가 간헐적으로 보임 (Flutter web 한계)
- **macOS Tab 키**: macOS에서 한글 입력 후 Tab 시 이중 포커스 이동 (Windows/모바일은 정상)
- **HTML renderer**: Flutter 3.41에서 제거됨, CanvasKit만 사용 가능

## Environment

Required `.env` file:
```
SUPABASE_URL=https://bfcmjumgfrblvyjuvmbk.supabase.co
SUPABASE_ANON_KEY=<key>
ANTHROPIC_API_KEY=<key>
```

## Deployment

- GitHub push → Vercel 자동 배포 (build/web 디렉토리)
- `vercel.json`으로 SPA 라우팅 설정
- Preview 배포는 Vercel Authentication이 걸림 (Standard Protection)
- Production 배포만 공개 접근 가능
