# ADR-0009: 골프장 자동완성 — 프로별 누적 입력 기반

**Date**: 2026-04-26
**Status**: accepted
**Deciders**: hdopen@moacoms.com
**Related**: [ADR-0006](0006-field-lesson-accuracy-group-a.md) — 필드 레슨 노트의 코스명 입력 보조

## Context

필드 레슨 노트의 `course_name`은 자유 문자열 입력. 같은 프로가 같은 골프장을 여러 번 방문하는 경우가 많은데 매번 "스카이밸리CC" 같은 긴 이름을 다시 타이핑해야 한다. 한국 골프장은 약 500여 개로 유한하지만 공식 오픈 API가 없고 마스터 DB도 없는 상태.

## Decision

신규 골프장 마스터 테이블/외부 API 없이, 해당 프로 본인이 과거 작성한 노트의 `field_data.course_name` 중 비어있지 않은 값을 distinct로 모아 자동완성 후보로 제공. Flutter `Autocomplete` 위젯으로 입력 중 substring 매칭 결과를 드롭다운 표시.

신규 provider `proCourseNamesProvider`를 추가해 lesson_notes 전체에서 한 번에 추출(클라이언트 측 distinct), `field_lesson_tab`의 `_buildCourseNameField`를 `Autocomplete<String>`으로 교체.

## Alternatives Considered

### 대안 1: 공통 `golf_courses` 테이블 신설
- **Pros**: 모든 프로가 입력한 값을 공유 → 데이터 빠르게 축적
- **Cons**: 중복·오타·표기 흔들림(예: "스카이밸리CC" vs "Sky Valley") 정규화 필요. 권한·관리 정책 필요. 0 사용자 단계에선 데이터가 없어 이득 없음
- **Why not**: pre-launch 단계에서 운영 부담 크고 가치 적음. 사용자 기반이 커지면 `proCourseNamesProvider`를 그대로 두고 추가 ADR로 글로벌 fallback 도입

### 대안 2: 공공데이터/외부 API 시드
- **Pros**: 첫 사용자도 자동완성 혜택
- **Cons**: 한국 골프장 통합 API 부재. 공공데이터포털(전국체육시설업체)은 골프장 필터·홀구성 정보 부족. 직접 수집·갱신 부담
- **Why not**: ROI 낮음. 향후 별도 시도 가능성 열어둠

### 대안 3: 자동완성 도입하지 않음
- **Pros**: 작업 0
- **Cons**: 같은 코스 반복 방문 시 매번 타이핑 → UX 손실
- **Why not**: 최소 비용으로 큰 가치 — 도입할 만함

## Consequences

### Positive
- 첫 입력 후 동일 프로의 후속 입력은 한두 글자 + 탭으로 완료
- 새 테이블/마이그레이션/외부 의존성 없음 — 기존 `lesson_notes`만 사용
- 글로벌 DB로 확장 시에도 본 자동완성 위젯 그대로 활용 가능

### Negative
- 첫 라운드 한 번 입력해야 다음부터 자동완성 가능 (cold-start)
- 다른 프로 입력은 활용 못 함 — 각 프로가 자기 데이터만
- 동일 골프장을 여러 표기로 입력하면 별도 후보로 등장 (정규화 안 함)

### Risks
- 노트 수가 많아지면 메모리에 distinct 계산 부담. 현재 규모에선 무시 가능. 향후 SQL `DISTINCT` 쿼리로 분리 가능
- 사용자가 오타로 입력한 값이 자동완성 후보에 노출 → 다음 번 입력 시 동일 오타 재선택 가능. 실사용 후 정규화/편집 기능 검토
