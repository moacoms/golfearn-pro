# ADR-0002: 코스 타입 4종 분류 (`full` / `front_9` / `back_9` / `nine_double`)

**Date**: 2026-04-21
**Status**: accepted
**Deciders**: hdopen@moacoms.com

## Context

한국에는 9홀 구장이 적지 않고, 대다수는 같은 9홀을 두 번 도는 운영(9홀 × 2 = 18홀)을 한다. 초기 구현은 `full`(18)/`front_9`/`back_9` 3종만 지원해 9홀×2 라운드를 표현할 방법이 없었다. 사용자가 같은 홀번호를 두 번 입력해도 1차/2차를 구분할 수 없어 통계·UI에서 혼란.

## Decision

`course_type`에 `nine_double`을 추가해 총 4종 운영. `nine_double`은 18개 홀을 생성하되 각 홀에 `round_number: 1|2`와 `hole_number: 1~9`를 부여하여 같은 홀번호가 두 번 등장. UI는 "1차 라운드 / 2차 라운드" 섹션 헤더로 구분 표시.

## Alternatives Considered

### 대안 1: 별도 `rounds` 배열로 중첩 모델링 (`rounds[].holes[]`)
- **Pros**: 의미적으로 명확 (round 내 hole 배열)
- **Cons**: 기존 `holes` 평탄 배열 기반 통계·렌더링 로직 전면 수정 필요
- **Why not**: 기존 구조에 `round_number` 필드만 추가하면 호환 유지됨

### 대안 2: `course_type`을 자유 문자열로 변경
- **Pros**: 유연성 최대
- **Cons**: UI 선택지 관리 어려움, 검증 불가
- **Why not**: 선택지가 한정적인 편이 UX·검증 측면에서 유리

## Consequences

### Positive
- 실제 라운드 운영을 1:1로 기록 가능
- 기존 `holes` 평탄 배열 구조·통계 로직 변경 최소

### Negative
- `hole_number`만으로 홀 식별 불가 → `(round_number, hole_number)` 조합 필요
- UI 섹션 헤더 분기 로직 추가

### Risks
- 3라운드 이상 도는 희귀 케이스(챔피언십 등)는 미지원 — 필요 시 별도 확장
