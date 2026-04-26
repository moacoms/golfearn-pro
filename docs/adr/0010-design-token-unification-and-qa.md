# ADR-0010: 디자인 토큰 일원화 + QA 동시 패스

**Date**: 2026-04-26
**Status**: accepted
**Deciders**: hdopen@moacoms.com

## Context

`AppTheme`에 "Green Course" 디자인 시스템(Deep Forest Green + Emerald + Gold)이 정의되어 있지만 features 코드에서 토큰을 우회하는 사례가 다수 발견:

- 하드코딩 hex 색상 51건 (`Color(0xFF1F2937)`, `Color(0xFF6B7280)` 등 — 대부분 `AppTheme.textPrimary` / `textSecondary`로 매핑 가능)
- `Colors.red` / `Colors.orange` / `Colors.blue` 직접 사용 14건+ (의미 토큰 `errorColor` / `warningColor` / `secondaryColor` 회피)
- 로딩 인디케이터 색상·굵기 제각각 (splash 흰색, login 기본, analysis 흰색, schedule 기본 등)
- 결과: 첫 로딩 화면과 메인 화면의 시각적 톤이 어긋난다는 사용자 피드백 (2026-04-26)

QA 측면에서도 pre-launch 단계에서 페이지별 핵심 동작이 정상인지 확인이 필요.

## Decision

디자인 일원화와 QA를 **단일 패스**로 묶어 페이지 단위로 진행:

1. **공용 `AppLoadingView` 위젯** 신설 — 모든 로딩 인디케이터를 동일 색상(`primaryColor`) · 굵기 · 사이즈로 통일. 인라인 `CircularProgressIndicator()` 모두 이걸로 교체
2. **디자인 토큰 강제 치환** — features 내 하드코딩 hex 색상과 `Colors.{red,orange,blue,green}` 사용처를 의미 토큰으로 변환:
   - `Color(0xFF1F2937)` → `AppTheme.textPrimary`
   - `Color(0xFF6B7280)` → `AppTheme.textSecondary`
   - `Color(0xFF9CA3AF)` → `AppTheme.textMuted`
   - `Colors.red` (에러) → `AppTheme.errorColor`
   - `Colors.orange` (경고) → `AppTheme.warningColor`
   - `Colors.blue` (정보) → `AppTheme.secondaryColor`
3. **페이지별 QA 체크** — 토큰 치환을 위해 어차피 페이지를 열어보는 김에 5분 스모크 테스트(열기 → 핵심 버튼 → 저장 → 재열기). 항목: 홈/학생/스케줄/레슨노트/패키지/설정/수입/분석/필드레슨

## Alternatives Considered

### 대안 1: 디자인 일원화만 우선, QA는 별도 패스
- **Pros**: 작업 단위 명확
- **Cons**: 토큰 치환 시 페이지를 어차피 열어봐야 하는데 같은 페이지를 두 번 도는 비효율
- **Why not**: 묶어서 한 번에 통과시키는 게 빠름

### 대안 2: lint 규칙으로 하드코딩 색상 차단 (custom lint or `flutter_lints` 확장)
- **Pros**: 미래 회귀 방지
- **Cons**: pre-launch 단계 단일 개발자 환경에서 lint 인프라 도입 부담. 일회성 정리가 더 빠름
- **Why not**: 도입은 좋지만 이번 패스 범위 밖. 추후 별도 ADR로 검토

### 대안 3: 자동화 회귀 테스트 추가 (위젯 테스트 / golden test)
- **Pros**: QA 자동화
- **Cons**: pre-launch 0 사용자 단계에서 변경 빈도가 높아 골든이 자주 깨짐. ROI 낮음
- **Why not**: 런칭 후 안정화 단계에 도입

## Consequences

### Positive
- splash → login/home 전환 시 로딩 인디케이터·배경 톤 일관 → 첫인상 개선
- 디자인 변경 시 `AppTheme`만 수정하면 전 앱 반영
- 페이지별 동작 이상 발견 시 즉시 수정

### Negative
- 다수 파일 변경 — git diff 비대 (단순 치환이지만 리뷰 부담)
- 일부 의도적 색상(예: 카카오 노랑 `_kakaoYellow`, 골드 액센트)은 토큰화 대상 아님 → 분기 판단 필요

### Risks
- 무차별 치환으로 의미가 어긋나는 색상 발생 가능 (예: 알림 칩의 빨강이 "에러"가 아니라 "긴급" 의미인 경우) → 페이지 열어 시각 확인 후 커밋
- QA 중 치명적 버그 발견 시 디자인 작업이 길어짐 → 발견되면 ADR-0011 등으로 분리 처리
