# Golfearn Pro - 레슨프로 CRM 앱

골프 레슨 프로를 위한 고객 관리 시스템 (CRM) Flutter 앱

## 📚 문서
상세한 개발 가이드와 진행 상황은 `docs/` 폴더를 확인하세요:
- **[개발 환경 설정](docs/SETUP_GUIDE.md)** - Flutter, IntelliJ 설정 방법
- **[개발 진행 상황](docs/DEVELOPMENT_LOG.md)** - 현재까지 완성된 기능들
- **[통합 가이드](docs/INTEGRATION.md)** - 기존 Golfearn 시스템과의 연동
- **[Claude Code 가이드](docs/CLAUDE.md)** - AI 개발 도우미 사용법

## 📱 플랫폼
- iOS
- Android  
- Web
- Desktop (Windows/Mac)

## 🎯 핵심 기능

### 레슨프로용 (메인 앱)
- 👥 학생 관리 (프로필, 연락처, 실력)
- 📅 스케줄/예약 관리
- 💰 수강권/패키지 관리
- 📝 레슨 노트 작성
- 📹 영상 분석 (AI 기반)
- 📊 수입/통계 관리
- 🔔 자동 알림 (예약, 만료)

### 학생용 (서브 앱 - 추후)
- 레슨 예약 확인
- 레슨 노트 조회
- 영상/피드백 확인
- 수강권 구매

## 🏗️ 프로젝트 구조

```
golfearn-pro/
├── lib/
│   ├── main.dart                 # 앱 진입점
│   ├── app.dart                  # 앱 설정
│   ├── core/                     # 핵심 기능
│   │   ├── constants/            # 상수
│   │   ├── theme/               # 테마
│   │   ├── router/              # 라우팅
│   │   └── services/            # 서비스
│   ├── features/                 # 기능별 모듈
│   │   ├── auth/                # 인증
│   │   ├── students/            # 학생 관리
│   │   ├── schedule/            # 스케줄
│   │   ├── packages/            # 수강권
│   │   ├── lessons/             # 레슨 노트
│   │   ├── income/              # 수입 관리
│   │   └── analysis/            # 영상 분석
│   └── shared/                   # 공유 컴포넌트
│       ├── widgets/             # 공통 위젯
│       └── utils/               # 유틸리티
├── test/                         # 테스트
├── assets/                       # 리소스
│   ├── images/
│   └── fonts/
└── pubspec.yaml                  # 의존성 관리
```

## 🔗 연동 서비스

### Supabase (백엔드)
- 기존 Golfearn 프로젝트의 Supabase 인스턴스 공유
- URL: `https://bfcmjumgfrblvyjuvmbk.supabase.co`
- 인증, 데이터베이스, 스토리지 통합 사용

### 기존 테이블 활용
```sql
- profiles            # 사용자 프로필
- lesson_students     # 학생 정보
- lesson_packages     # 수강권/패키지
- lesson_schedules    # 레슨 스케줄
- lesson_notes        # 레슨 노트
- pro_income_records  # 수입 기록
```

## 💰 수익 모델

| 플랜 | 월 요금 | 기능 |
|------|---------|------|
| **Free** | ₩0 | 학생 5명, 기본 기능 |
| **Basic** | ₩19,900 | 학생 30명, 레슨 노트 |
| **Pro** | ₩39,900 | 무제한, AI 분석 |
| **Academy** | ₩99,900 | 다중 프로, 통합 관리 |

## 🚀 개발 로드맵

### Phase 1: 기초 (Week 1-2)
- [x] 프로젝트 설정
- [ ] Supabase 연동
- [ ] 인증 시스템
- [ ] 기본 UI/네비게이션

### Phase 2: 핵심 CRM (Week 3-4)
- [ ] 학생 관리 CRUD
- [ ] 스케줄 캘린더
- [ ] 수강권 시스템
- [ ] 기본 레슨 노트

### Phase 3: 차별화 (Week 5-6)
- [ ] 영상 업로드/재생
- [ ] AI 스윙 분석
- [ ] 진도 리포트
- [ ] 자동화 기능

### Phase 4: 출시 (Week 7-8)
- [ ] 결제 시스템
- [ ] 푸시 알림
- [ ] 테스트/디버깅
- [ ] 스토어 배포

## 🛠️ 기술 스택

- **Framework**: Flutter 3.x
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Backend**: Supabase
- **Storage**: Supabase Storage
- **AI**: Claude API
- **Payment**: In-App Purchase / Lemon Squeezy

## 📦 설치 및 실행

### 사전 요구사항
- Flutter SDK 3.x
- Dart SDK
- Android Studio / Xcode
- VS Code (권장)

### 설치 방법
```bash
# 1. Flutter 설치 확인
flutter doctor

# 2. 의존성 설치
flutter pub get

# 3. 실행
flutter run

# 웹 실행
flutter run -d chrome

# 특정 플랫폼 빌드
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
```

## 🔐 환경 변수

`.env` 파일 생성:
```env
SUPABASE_URL=https://bfcmjumgfrblvyjuvmbk.supabase.co
SUPABASE_ANON_KEY=your_anon_key
ANTHROPIC_API_KEY=your_claude_api_key
```

## 📱 스크린샷
(추후 추가)

## 🤝 기여 방법
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## 📄 라이선스
Private Repository - All Rights Reserved

## 📞 문의
- Email: hdopen@moacoms.com
- Website: [www.golfearn.com](https://www.golfearn.com)

---

© 2026 Golfearn. All rights reserved.