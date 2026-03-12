# 🔗 Golfearn 프로젝트 통합 가이드

## 📋 프로젝트 구조

```
Golfearn 생태계
├── golfearn (Next.js)         # 웹사이트 (서비스 소개)
│   ├── 역할: 랜딩, SEO, 마케팅
│   ├── URL: www.golfearn.com
│   └── 저장소: github.com/moacoms/Golfearn
│
├── golfearn-pro (Flutter)     # 레슨프로 CRM 앱
│   ├── 역할: 레슨프로 전용 모바일/데스크톱 앱
│   ├── 플랫폼: iOS, Android, Web, Desktop
│   └── 저장소: github.com/moacoms/golfearn-pro
│
└── Supabase (공유 백엔드)
    ├── 인증: 통합 사용자 시스템
    ├── DB: PostgreSQL (공유 스키마)
    └── Storage: 이미지/영상 저장소
```

## 🌐 Supabase 공유 설정

### 1. 연결 정보 (동일하게 사용)
```env
SUPABASE_URL=https://bfcmjumgfrblvyjuvmbk.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 2. 공유 테이블
```sql
-- 사용자 관련
auth.users              # Supabase 인증 (공통)
public.profiles         # 사용자 프로필 (공통)

-- 레슨프로 CRM (Flutter 앱에서 주로 사용)
public.lesson_students     # 학생 관리
public.lesson_packages     # 수강권
public.lesson_schedules    # 스케줄
public.lesson_notes        # 레슨 노트
public.pro_income_records  # 수입 관리

-- 기타 기능 (웹에서 주로 사용)
public.posts              # 커뮤니티
public.products           # 중고거래
public.join_posts         # 조인 매칭
```

### 3. Storage 버킷
```
avatars/        # 프로필 사진 (공통)
lesson-videos/  # 레슨 영상 (Flutter)
lesson-images/  # 레슨 이미지 (Flutter)
products/       # 중고거래 이미지 (웹)
```

## 🔄 데이터 흐름

### 1. 사용자 인증 플로우
```mermaid
graph LR
    A[사용자] --> B[웹사이트 방문]
    B --> C[회원가입/로그인]
    C --> D[Supabase Auth]
    D --> E[프로필 생성]
    E --> F[레슨프로 등록]
    F --> G[Flutter 앱 로그인]
```

### 2. 레슨프로 등록 과정
```typescript
// 웹사이트에서 (Next.js)
1. /pro-register 페이지에서 레슨프로 신청
2. profiles.is_lesson_pro = true 설정
3. 프로 정보 입력 (자격증, 경력 등)

// Flutter 앱에서
4. 로그인 시 is_lesson_pro 확인
5. true인 경우 메인 화면 진입
6. false인 경우 레슨프로 등록 유도
```

### 3. 학생 등록 연동
```dart
// Flutter 앱에서 학생 등록 시
1. 기존 회원 검색 (profiles 테이블)
2. 회원인 경우: user_id 연결
3. 비회원인 경우: 정보만 저장
4. 학생용 앱 초대 링크 발송
```

## 📱 크로스 플랫폼 기능

### 1. 웹 → 앱 연동
```typescript
// Next.js 컴포넌트
<AppDownloadBanner>
  - iOS 앱스토어 링크
  - Android 플레이스토어 링크
  - "앱에서 더 많은 기능을 사용하세요"
</AppDownloadBanner>

// 딥링크 처리
golfearn.com/pro/dashboard → 앱 열기
golfearn.com/app/download → 스토어 리다이렉트
```

### 2. 앱 → 웹 연동
```dart
// Flutter에서 웹 링크
- 이용약관: golfearn.com/terms
- 개인정보처리방침: golfearn.com/privacy
- 도움말: golfearn.com/help
- 블로그: golfearn.com/blog
```

### 3. 웹 대시보드 (읽기 전용)
```typescript
// Next.js 대시보드 페이지
/dashboard
  - 이번 달 수입 (차트)
  - 학생 현황 (통계)
  - 이번 주 일정 (캘린더 뷰)
  - "상세 관리는 앱에서" 버튼
```

## 🔐 권한 관리

### 1. 사용자 역할
```sql
profiles 테이블:
- is_admin: 관리자 (전체 권한)
- is_lesson_pro: 레슨프로 (CRM 사용)
- is_student: 학생 (학생 앱 사용)
```

### 2. RLS 정책
```sql
-- 레슨프로는 자신의 데이터만
CREATE POLICY "프로는 자신의 학생만 조회"
ON lesson_students
FOR SELECT
USING (auth.uid() = pro_id);

-- 학생은 자신의 레슨만
CREATE POLICY "학생은 자신의 레슨만 조회"
ON lesson_schedules
FOR SELECT
USING (
  auth.uid() IN (
    SELECT user_id FROM lesson_students 
    WHERE id = lesson_schedules.student_id
  )
);
```

## 📊 통계 공유

### 1. 웹사이트에 표시할 통계
```typescript
// API 엔드포인트
/api/stats/public
  - 전체 레슨프로 수
  - 전체 학생 수
  - 이번 달 레슨 수
  - 누적 거래액

/api/stats/pro/[id]
  - 특정 프로 통계 (공개 프로필용)
```

### 2. Flutter 앱 통계
```dart
// 실시간 대시보드
- 오늘 일정
- 이번 주/월 수입
- 학생별 진도
- 패키지 만료 알림
```

## 🚀 배포 전략

### 1. 웹사이트 (Vercel)
```bash
# 자동 배포
git push origin main
→ Vercel 자동 빌드/배포
→ www.golfearn.com 업데이트
```

### 2. Flutter 앱
```bash
# Android
flutter build appbundle
→ Play Console 업로드

# iOS
flutter build ipa
→ App Store Connect 업로드

# Web
flutter build web
→ Firebase Hosting or Vercel
```

## 🔧 개발 환경 설정

### 1. 로컬 개발
```bash
# Next.js (포트 3000)
cd golfearn
npm run dev

# Flutter (포트 5000)
cd golfearn-pro
flutter run -d chrome --web-port 5000

# Supabase (로컬 - 선택사항)
supabase start
```

### 2. 환경 변수 동기화
```bash
# 두 프로젝트 모두 동일한 Supabase 키 사용
# .env 파일 복사 또는 환경변수 관리 도구 사용
```

## 📈 모니터링

### 1. 통합 대시보드 (Supabase)
- 데이터베이스 사용량
- API 호출 수
- 스토리지 사용량
- 인증 사용자 수

### 2. 앱별 모니터링
- Vercel Analytics (웹)
- Firebase Analytics (Flutter)
- Sentry (에러 트래킹)

## 🤝 협업 가이드

### 1. Git 브랜치 전략
```
main        # 프로덕션
develop     # 개발
feature/*   # 기능 개발
hotfix/*    # 긴급 수정
```

### 2. 커밋 메시지 규칙
```
feat: 새로운 기능
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 리팩토링
test: 테스트 추가
chore: 빌드/설정 수정
```

### 3. 이슈 관리
- GitHub Issues 사용
- 라벨: web, flutter, supabase, urgent
- 프로젝트 보드: 칸반 방식

## 📞 문의 및 지원
- 기술 문의: hdopen@moacoms.com
- 문서: github.com/moacoms/golfearn-pro/wiki
- 이슈: github.com/moacoms/golfearn-pro/issues