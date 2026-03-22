# Golfearn - 골프 레슨프로 CRM

골프 레슨프로를 위한 고객 관리 시스템 (CRM) Flutter 앱
향후 다양한 스포츠 레슨 확장을 위한 멀티스포츠 구조가 내장되어 있습니다.

**Live Demo**: https://golfearn-pro.vercel.app

## 주요 기능

### 멀티 스포츠 지원
- 프로 가입 시 종목 선택 (골프/테니스/배드민턴/수영/필라테스·요가/기타)
- 종목별 레슨 타입, 아이콘, 노트 힌트 자동 변경
- 설정에서 언제든 종목 변경 가능

### 대시보드
- 오늘의 레슨 일정 및 예정 레슨 목록
- 주간 레슨 차트 (fl_chart)
- 만료 임박 패키지 알림
- 학생 수, 월 수입, 주간 레슨 통계 (종목별 아이콘)

### 학생 관리
- 학생 프로필 등록/수정/삭제
- 이름, 전화번호, 이메일 검색
- 종목별 학생 정보 (레벨, 목표, 기록, 레슨 이력)

### 스케줄
- 주간 캘린더 뷰
- 종목별 레슨 타입 선택 (골프: 일반/필드/숏게임/퍼팅, 테니스: 포핸드/백핸드/서브/경기 등)
- 레슨 예약/완료/취소/노쇼 처리
- 반복 레슨 등록 (매주/격주)
- 패키지 연동 시 자동 횟수 차감

### 레슨노트
- 레슨 내용, 개선사항, 숙제 기록
- 학생별 레슨 기록 관리

### 패키지 관리
- 레슨권 생성 및 사용 현황 추적
- 결제 상태 관리 (대기/부분/완납)
- 진행률 시각화

### 수입 관리
- 월별 수입 기록 및 조회
- 카테고리별 통계 (레슨비/패키지/기타)
- 결제방법별 분석 (현금/카드/이체)

### 설정
- 프로필 편집 (이름, 전화번호)
- 레슨 종목 변경
- 기본 레슨 시간/단가 설정
- 데이터 내보내기 (준비 중)

## 기술 스택

| 영역 | 기술 |
|------|------|
| Framework | Flutter 3.x (Dart >=3.8.0) |
| State Management | Riverpod + riverpod_generator |
| Navigation | GoRouter |
| Backend | Supabase |
| Charts | fl_chart |
| UI | flutter_screenutil |
| AI | Claude API |
| Deployment | Vercel (Web) |

## 프로젝트 구조

```
lib/
├── core/                    # 핵심 인프라
│   ├── constants/           # DB 상수, 종목별 설정 (sport_constants.dart)
│   ├── router/              # GoRouter 설정
│   ├── services/            # Supabase, Claude 서비스
│   └── theme/               # 앱 테마
├── features/                # 기능별 모듈 (Clean Architecture)
│   ├── auth/                # 인증 (로그인/회원가입)
│   ├── dashboard/           # 대시보드
│   ├── students/            # 학생 관리
│   ├── schedule/            # 스케줄
│   ├── lessons/             # 레슨 노트
│   ├── packages/            # 패키지
│   ├── income/              # 수입 관리
│   ├── settings/            # 설정
│   └── analysis/            # AI 분석 (개발중)
└── shared/                  # 공유 위젯/유틸
```

각 feature 모듈:
```
feature/
├── data/models/             # JSON 모델
├── data/repositories/       # Repository 구현
├── domain/entities/         # 도메인 엔티티
└── presentation/
    ├── pages/               # UI 화면
    └── providers/           # Riverpod 프로바이더
```

## 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 개발 서버 실행
flutter run -d chrome

# 웹 빌드
flutter build web --release

# Vercel 배포
vercel deploy --prod --yes
```

## 환경 변수

`.env` 파일 생성:
```env
SUPABASE_URL=https://bfcmjumgfrblvyjuvmbk.supabase.co
SUPABASE_ANON_KEY=your_anon_key
ANTHROPIC_API_KEY=your_claude_api_key
```

## 데이터베이스 (Supabase)

기존 Golfearn 프로젝트와 공유하는 테이블:

| 테이블 | 설명 |
|--------|------|
| `profiles` | 사용자 프로필 (레슨프로/학생 구분, sport_type 종목) |
| `lesson_students` | 학생 정보 |
| `lesson_schedules` | 레슨 스케줄 |
| `lesson_packages` | 수강권/패키지 |
| `lesson_notes` | 레슨 노트 |
| `pro_income_records` | 수입 기록 |

## 플랫폼

- Web (Vercel 배포)
- iOS
- Android
- Desktop (macOS/Windows)

## 라이선스

Private Repository - All Rights Reserved

## 문의

- Email: hdopen@moacoms.com
- Website: [www.golfearn.com](https://www.golfearn.com)

---
© 2026 Golfearn. All rights reserved.
