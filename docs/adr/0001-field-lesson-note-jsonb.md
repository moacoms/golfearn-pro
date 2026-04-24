# ADR-0001: 필드 레슨 노트를 `lesson_notes.field_data` JSONB로 저장

**Date**: 2026-04-18
**Status**: accepted
**Deciders**: hdopen@moacoms.com

## Context

필드 레슨 노트는 홀 9~18개 + 홀별 샷 배열 + 프리샷 루틴 체크 + 코스 메타(이름·티·타입) 등 복합·중첩 구조를 갖는다. 기존 `lesson_notes` 테이블에 일반 레슨 노트가 이미 존재하고, 필드 여부는 노트별 선택사항이다. 관계형 테이블로 분리(`field_rounds`/`field_holes`/`field_shots` 3~4개 추가)하면 RLS·마이그레이션 비용이 커지고, pre-launch 단계에서 스키마 유연성이 집계 기능보다 중요하다.

## Decision

`lesson_notes` 테이블에 `field_data JSONB NULL` 컬럼 하나만 추가하고 전체 필드 트리를 JSON 한 덩어리로 저장. 일반 노트만 있는 레코드는 `field_data IS NULL`. 통계는 앱 클라이언트에서 계산.

## Alternatives Considered

### 대안 1: 관계형 분리 (field_rounds / field_holes / field_shots 테이블)
- **Pros**: SQL로 홀·샷 단위 집계·필터 용이
- **Cons**: 마이그레이션 3~4개, RLS 정책 중복, 스키마 변경 시 조인 다수
- **Why not**: pre-launch 단계라 스키마가 자주 바뀌고, 현재는 통계를 앱에서 계산하므로 DB 집계 이득이 작음

### 대안 2: 별도 `field_lesson_notes` 테이블 (1:1 분리)
- **Pros**: 관심사 분리, 일반 노트 조회 성능 영향 없음
- **Cons**: student_id·날짜·메모 등 공유 필드 중복, 조회 시 조인 필요
- **Why not**: 일반/필드를 같은 폼·리스트에서 다루는 UX라 분리 이득이 작음

## Consequences

### Positive
- 스키마 변경 없이 필드 구조 진화 가능 (이후 `green_side`, `tee_box`, `yardage_m`, `penalty_strokes`, `distance_m` 등을 DB 마이그레이션 없이 추가함)
- 일반 노트와 필드 노트를 한 쿼리로 조회

### Negative
- Supabase에서 홀/샷 단위 SQL 집계가 어려움 (JSONB 함수 필요)
- 스키마 강제력 없음 — 앱 코드에서 검증해야 함

### Risks
- 장기적으로 집계·분석 니즈가 커지면 관계형 전환이 필요 → 그 시점에 새 ADR로 supersede
