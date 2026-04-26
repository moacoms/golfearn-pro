# ADR-0004: `flutter_screenutil` designSize 동적 조정으로 데스크탑 과확대 방지

**Date**: 2026-04-21
**Status**: accepted
**Deciders**: hdopen@moacoms.com
**Related**: 실패한 대안(MediaQuery 오버라이드 방식)은 커밋 `8020c6c` → `438d90a`로 원복됨

## Context

앱은 모바일 우선(iPhone 13, designSize 390×844)으로 설계됐고 `flutter_screenutil`의 `.sp`/`.w` 스케일은 `screenWidth / 390`에 비례. 1440px 데스크탑 브라우저에서 스케일이 **3.7배**가 되어 UI가 과도하게 확대. Vercel 웹 배포 대상에 데스크탑 사용자가 포함되므로 해결 필요.

## Decision

`MediaQuery`는 건드리지 않고, `Builder` 안에서 `MediaQuery.of(context).size`를 읽어 `ScreenUtilInit.designSize`를 동적으로 조정. 화면 너비 > 507px이면 `designWidth = screenWidth / 1.3`로 설정해 스케일을 **1.3배로 고정**. 좁은 화면(≤ 507px)은 자연 스케일(392 기준 그대로) 유지.

**2026-04-26 후속 수정**: 초기엔 `designHeight`를 `designWidth`에 비례해서 산출(=designWidth × 844/390)했는데, 이로 인해 데스크탑(예: 1440×1161)에서 `designHeight ≈ 2400`이 되어 `.h` 단위가 ~0.48배로 축소됨. 결과: 차트 `reservedSize: 24.h` 같은 세로 예약 공간이 12px 정도로 줄어 라벨이 짤림. 수정: `designHeight`도 `screenHeight / 1.3`로 독립 캡(자연 cutoff = 844 × 1.3 = 1097). `.w`와 `.h`가 동일한 1.3배로 유지되도록 보장.

## Alternatives Considered

### 대안 1: MediaQuery.copyWith(size: ...) 오버라이드 + 중앙 정렬 프레임
- **Pros**: 모바일 프리뷰 형태로 직관적, 데스크탑에서 콘텐츠 폭도 500px로 제한 가능
- **Cons**: `MaterialApp.router`의 `builder` 내부에서 override 시 Router/Navigator 렌더링이 깨져 첫 화면이 회색으로만 표시됨
- **Why not**: 실제 시도했으나 재현 가능한 렌더링 버그로 원복 (`feedback_mediaquery_override.md` 참고)

### 대안 2: 데스크탑 전용 반응형 레이아웃 전면 재설계
- **Pros**: 데스크탑 UX 최적화 가능
- **Cons**: 앱 모든 페이지 레이아웃 재작성 필요
- **Why not**: pre-launch 단계에 과투자

### 대안 3: 현상 유지 (과확대 용인)
- **Pros**: 작업 없음
- **Cons**: 데스크탑 사용자 UX 최악
- **Why not**: 사용자 피드백으로 거부

## Consequences

### Positive
- 데스크탑/태블릿에서 텍스트·아이콘·카드 크기가 모바일의 1.3배 수준으로 적정
- `MediaQuery`·Router 로직을 건드리지 않아 안정적

### Negative
- 데스크탑에서 콘텐츠가 전체 화면 너비를 채움 (세로 스크롤 중심의 모바일 레이아웃이 1.3배로 확대된 형태)
- 진정한 "데스크탑 반응형"과는 다름

### Risks
- 실제 데스크탑 UX 최적화가 필요한 시점엔 별도 반응형 설계로 supersede 필요
