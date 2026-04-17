# 보안 체크리스트 — 서비스 런칭 전 일괄 처리

마지막 업데이트: 2026-04-14

이 문서는 **현재 개발 단계에서 보류된 보안 항목**을 서비스 런칭 직전에 일괄 처리하기 위한 체크리스트다. 완료된 작업은 `git log --grep=security` 를 참고.

---

## 완료된 보안 작업 (요약)

코드 레벨:
- Repository 5곳 인가 검증 (`pro_id = auth.uid()` 필터)
- 라우터 역할 기반 접근 제어
- Mass assignment whitelist 4개 메서드
- 입력 검증 + maxLength + 에러 메시지 원문 제거
- HTTP 타임아웃 (Claude API)
- 비밀번호 정책 (8자+영숫자)
- 패키지 잔여 0 차감 방지 + 트랜잭션 롤백
- `.env` 커밋 차단, `--dart-define` 빌드
- Android `usesCleartextTraffic=false`, iOS ATS
- vercel.json: CSP/HSTS/X-Frame-Options/Referrer-Policy

DB 레벨 (SQL Editor 실행 완료):
- `handle_new_user` 트리거: 신규 가입은 항상 학생 역할
- `profiles` RLS: 자가 update 시 권한 필드 변경 차단
- `promote_to_lesson_pro()` 보안 함수 (프로 전환 전용)
- 5개 데이터 테이블 RLS (`lesson_students`, `lesson_schedules`, `lesson_packages`, `lesson_notes`, `pro_income_records`)

---

## 서비스 런칭 전 처리 필요

### 1. Supabase anon key 로테이션 (🔴 필수)

**이유**: `anon` 키가 Git 이력(`vercel.json` 이전 버전 + 과거 `.env`)에 노출되어 GitHub에 영구 기록됨. RLS 적용으로 데이터 유출 위험은 해소되었으나 Rate Limit 남용/Auth 엔드포인트 악용 가능.

**절차**:
1. 모든 사용자에게 재로그인 안내 공지 (JWT secret 재생성 시 세션 전체 만료)
2. Supabase Dashboard → Project Settings → API → `JWT Settings` → **Generate new JWT secret**
3. 새 `anon` 키 복사
4. Vercel Dashboard → golfearn-pro → Settings → Environment Variables
   - `SUPABASE_ANON_KEY` 값 교체 (Production + Preview 모두)
5. 로컬 `.env` 파일의 `SUPABASE_ANON_KEY` 교체 (개발자 기기 전부)
6. Vercel → Deployments → 최신 배포 옆 ⋯ → **Redeploy**
7. 재배포 후 웹 + Android 앱에서 로그인 정상 확인

### 2. Git 이력에서 `.env` 완전 제거 (🟡 권장)

**이유**: anon key 로테이션 후에도 과거 키가 이력에 남아있으면 분석 대상이 될 수 있음.

**절차** (`git filter-repo` 사용):
```bash
# 백업 브랜치
git branch backup-before-filter

# git-filter-repo 설치 (brew)
brew install git-filter-repo

# .env 완전 제거
git filter-repo --path .env --invert-paths --force

# 원격 강제 푸시 (⚠️ 팀원 모두 재클론 필요)
git push origin main --force
```

**주의**:
- `git filter-repo` 는 **전체 이력을 다시 씁니다**. 진행 전 반드시 팀원에게 공지하고, 모든 클론을 재클론하게 해야 합니다.
- 다른 브랜치가 있다면 전부 rebase 필요.
- Vercel도 이력 재인식 필요할 수 있음 → 재배포 권장.

### 3. RLS 실사용 테스트 (🟡 런칭 전 필수)

RLS가 기능을 차단하지 않는지 검증. 사용자가 브라우저/앱에서 직접 수행.

**프로 계정 체크리스트**:
- [ ] 홈 대시보드 — 오늘 일정, 통계, 주간 차트 로드
- [ ] 학생관리 — 목록, 생성, 수정, 삭제, 검색/필터
- [ ] 스케줄 — 주간 뷰, 레슨 생성/수정/삭제, 반복 레슨
- [ ] 레슨노트 — 생성/수정/삭제, 학생별 조회
- [ ] 패키지 — 생성, 차감, 결제 상태 변경, 진행률 표시
- [ ] 수입 — 기록 생성/삭제, 카테고리/결제방법 통계
- [ ] 설정 — 프로필 편집, CSV 내보내기

**학생 계정 체크리스트**:
- [ ] 홈 대시보드 — 총 레슨 수, 활성 패키지, 다가오는 레슨
- [ ] 내 레슨 — 스케줄 목록 조회, 프로 이름 표시 (읽기 전용)
- [ ] 레슨노트 — 노트 열람 (읽기 전용)
- [ ] 레슨프로 찾기 — 프로 목록 조회, 레슨 신청
- [ ] 프로 전환 — "레슨프로로 전환" 버튼, RPC 경유 성공
- [ ] 설정 — 프로필 수정

**문제 발생 시**: Supabase Dashboard → Logs → Postgres Logs 에서 `permission denied` / `new row violates row-level security` 메시지 확인. 해당 정책 수정 필요.

### 4. 프로덕션 release keystore 로그인 테스트 (🟡 Android 런칭 전)

- 카카오 로그인 추가 후: release 빌드용 keyhash를 카카오 개발자 콘솔에 등록
- Play Store 앱 서명 키 사용 시 Play Console → 앱 무결성 → 앱 서명 키에서 SHA-1 확보

### 5. 보안 헤더 검증 (🟢 선택)

서비스 런칭 후 한 번만:
- https://securityheaders.com → `https://golfearn-pro.vercel.app` 입력 → A 등급 확인
- https://observatory.mozilla.org → 동일 URL → B 이상 목표

---

## 향후 고려 사항 (우선순위 낮음)

- **감사 로그**: 중요 작업(프로 전환, 학생 삭제, 패키지 변경)에 대한 audit log 테이블
- **Rate Limiting**: Supabase 기본값 외 Edge Function 커스텀 제한
- **MFA**: Supabase Auth MFA 옵션 활성화 검토
- **데이터 백업**: Supabase Pro 플랜 자동 백업 vs 수동 pg_dump 스크립트
- **GDPR/개인정보법**: 회원 탈퇴 시 데이터 완전 삭제 절차 정의
