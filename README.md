# Golfearn - 골프 레슨프로 CRM

골프 레슨프로를 위한 고객 관리 시스템 (CRM) Flutter 앱

**Live Demo**: https://golfearn-pro.vercel.app

## 주요 기능

### 레슨프로 (강사)

#### 대시보드
- 오늘의 레슨 일정 및 예정 레슨 목록
- 주간 레슨 차트 (fl_chart)
- 만료 임박 패키지 알림
- 학생 수, 월 수입, 주간 레슨 통계
- 퀵액션: 학생 추가, 레슨 추가, 노트 작성, 수입 관리, AI 분석

#### 학생 관리
- 학생 프로필 등록/수정/삭제
- 이름, 전화번호, 이메일 검색
- 골프 정보 (레벨, 목표, 평균 타수, 레슨 이력)
- 앱으로 연결된 학생 구분 표시 ("앱 연결됨" 배지)

#### 스케줄
- 주간 캘린더 뷰
- 레슨 타입 선택 (일반/필드/숏게임/퍼팅)
- 레슨 예약/완료/취소/노쇼 처리
- 반복 레슨 등록 (매주/격주)
- 패키지 연동 시 자동 횟수 차감

#### 레슨노트
- 레슨 내용, 개선사항, 숙제 기록
- 학생별 레슨 기록 관리

#### 패키지 관리
- 레슨권 생성 및 사용 현황 추적
- 결제 상태 관리 (대기/부분/완납)
- 진행률 시각화

#### 수입 관리
- 월별 수입 기록 및 조회
- 카테고리별 통계 (레슨비/패키지/기타)
- 결제방법별 분석 (현금/카드/이체)

#### AI 스윙 분석
- 학생 선택 + 스윙 설명 입력
- Claude API 기반 AI 분석 (문제점/교정방법/연습드릴)

#### 설정
- 프로필 편집 (이름, 전화번호)
- 기본 레슨 시간/단가 설정
- 데이터 내보내기 (CSV, 한글 Excel 호환)
- 로그아웃

### 학생 (일반회원)

#### 학생 대시보드
- 총 레슨 횟수 (실데이터)
- 활성 패키지 목록 + 진행률 바
- 다가오는 레슨 (프로 이름, 시간, 장소 포함)

#### 레슨프로 찾기
- 등록된 레슨프로 목록 (경력, 위치, 소개)
- 레슨 신청 기능 → lesson_students 자동 등록
- 이미 연결된 프로 표시

#### 레슨프로로 전환
- 학생 → 프로 역할 변환 기능

### 공통 기능
- 비밀번호 찾기/재설정 (Supabase 이메일 발송)
- 회원가입 (학생/프로 선택)
- 이메일/전화번호 중복 체크 (포커스 해제 시 실시간)

## 기술 스택

| 영역 | 기술 |
|------|------|
| Framework | Flutter 3.41 (Dart >=3.8.0) |
| State Management | Riverpod + riverpod_generator |
| Navigation | GoRouter |
| Backend | Supabase |
| Charts | fl_chart |
| UI | flutter_screenutil |
| Font | Noto Sans KR (bundled) |
| AI | Claude API |
| Deployment | Vercel (Web) |

## 프로젝트 구조

```
lib/
├── core/                    # 핵심 인프라
│   ├── constants/           # DB 상수, 종목별 설정
│   ├── router/              # GoRouter 설정
│   ├── services/            # Supabase, Claude 서비스
│   └── theme/               # 앱 테마 (Noto Sans KR)
├── features/                # 기능별 모듈 (Clean Architecture)
│   ├── auth/                # 인증 (로그인/회원가입/비밀번호 재설정)
│   ├── dashboard/           # 대시보드 (프로/학생), 레슨프로 찾기
│   ├── students/            # 학생 관리
│   ├── schedule/            # 스케줄
│   ├── lessons/             # 레슨 노트
│   ├── packages/            # 패키지
│   ├── income/              # 수입 관리
│   ├── settings/            # 설정 + 데이터 내보내기
│   └── analysis/            # AI 스윙 분석
└── shared/                  # 공유 위젯/유틸
```

## 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 개발 서버 실행
flutter run -d chrome --web-port 5000

# 웹 빌드
flutter build web --release
```

## 환경 변수

`.env` 파일 생성:
```env
SUPABASE_URL=https://bfcmjumgfrblvyjuvmbk.supabase.co
SUPABASE_ANON_KEY=your_anon_key
ANTHROPIC_API_KEY=your_claude_api_key
```

## 데이터베이스 (Supabase)

| 테이블 | 설명 |
|--------|------|
| `profiles` | 사용자 프로필 (레슨프로/학생 구분, sport_type) |
| `lesson_students` | 학생 정보 (user_id로 앱 사용자 연결) |
| `lesson_schedules` | 레슨 스케줄 |
| `lesson_packages` | 수강권/패키지 |
| `lesson_notes` | 레슨 노트 |
| `pro_income_records` | 수입 기록 |

## 라이선스

Private Repository - All Rights Reserved

## 문의

- Email: hdopen@moacoms.com
- Website: [www.golfearn.com](https://www.golfearn.com)

---
© 2026 Golfearn. All rights reserved.
