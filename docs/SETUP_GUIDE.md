# Golfearn Pro 개발 환경 설정 가이드

## 📱 IntelliJ IDEA Flutter 개발 환경 설정

### 1. Flutter SDK 설치 ✅
1. Flutter SDK가 `C:\flutter_windows_3.41.4-stable`에 설치 완료
2. 시스템 PATH에 `C:\flutter_windows_3.41.4-stable\bin` 추가 완료
3. 새 터미널에서 `flutter doctor` 실행하여 설치 확인

### 2. IntelliJ IDEA 플러그인 설치 ✅
1. `File` > `Settings` > `Plugins`
2. "Flutter" 플러그인 검색 및 설치 (Dart 플러그인 자동 포함)
3. IntelliJ IDEA 재시작 필요

### 3. Flutter SDK 경로 설정
1. `File` > `Settings` > `Languages & Frameworks` > `Flutter`
2. Flutter SDK path: `C:\flutter_windows_3.41.4-stable`
3. Dart SDK path: `C:\flutter_windows_3.41.4-stable\bin\cache\dart-sdk` (자동 설정)

### 4. 프로젝트 실행 방법
```bash
# 의존성 설치
flutter pub get

# 코드 생성 (Freezed, Riverpod)
dart run build_runner build

# 앱 실행 (웹)
flutter run -d chrome

# 앱 실행 (Android 에뮬레이터)
flutter run
```

## 🏗️ 프로젝트 구조

### 완성된 기능들 (Phase 1)
- ✅ Supabase 연동 설정
- ✅ 인증 시스템 (로그인/회원가입)
- ✅ Clean Architecture 구조
- ✅ Riverpod 상태관리
- ✅ GoRouter 네비게이션
- ✅ 기본 UI/UX (스플래시, 대시보드)

### 주요 파일들
- `lib/main.dart` - 앱 진입점
- `lib/app.dart` - 앱 설정 및 테마
- `lib/features/auth/` - 인증 관련 기능
- `lib/features/dashboard/` - 대시보드
- `lib/core/` - 공통 서비스 및 설정
- `lib/shared/` - 공유 위젯 및 유틸리티

### 다음 단계 (Phase 2)
- [ ] 학생 관리 CRUD
- [ ] 스케줄 캘린더 기능
- [ ] 패키지 관리 시스템
- [ ] 레슨 노트 기능

## 🔧 문제 해결

### Flutter Doctor 오류 시
```bash
# Android 라이선스 동의
flutter doctor --android-licenses

# 의존성 재설치
flutter clean
flutter pub get
```

### 코드 생성 오류 시
```bash
# 생성된 파일 삭제 후 재생성
dart run build_runner clean
dart run build_runner build
```

## 📞 도움이 필요한 경우
- Claude Code 대화 기록 확인
- `CLAUDE.md` 파일 참조
- Flutter 공식 문서: https://docs.flutter.dev/