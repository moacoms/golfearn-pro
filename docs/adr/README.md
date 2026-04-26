# Architecture Decision Records

Golfearn 프로젝트의 아키텍처/설계 결정을 기록합니다. 이후 의미 있는 결정이 발생할 때마다 새 ADR을 추가합니다.

## 규칙

- 새 결정은 다음 번호 ADR로 추가 (예: `0007-...md`)
- 파일명: `NNNN-kebab-case-제목.md`
- 상태: `proposed` / `accepted` / `deprecated` / `superseded by ADR-NNNN`
- 슈퍼세드 시 원 ADR 상태 갱신 + 대체 ADR 링크 명시
- 2분 내 읽을 수 있도록 Context는 5문장 이내, Decision은 3문장 이내

## Index

| ADR | Title | Status | Date |
|-----|-------|--------|------|
| [0001](0001-field-lesson-note-jsonb.md) | 필드 레슨 노트를 lesson_notes.field_data JSONB로 저장 | accepted | 2026-04-18 |
| [0002](0002-course-type-four-variants.md) | 코스 타입 4종 분류 (full / front_9 / back_9 / nine_double) | accepted | 2026-04-21 |
| [0003](0003-per-hole-green-side.md) | 홀별 좌/우 그린 필드 (한국 골프장 특화) | accepted | 2026-04-21 |
| [0004](0004-screenutil-dynamic-design-size.md) | flutter_screenutil designSize 동적 조정으로 데스크탑 과확대 방지 | accepted | 2026-04-21 |
| [0005](0005-vercel-prebuilt-deploy.md) | Vercel 배포 — prebuilt build/web 서빙 구조 | accepted | 2026-03 |
| [0006](0006-field-lesson-accuracy-group-a.md) | 필드 레슨 기록 정확도 확장 (티박스·yardage·벌타·샷 거리) | accepted | 2026-04-23 |
| [0007](0007-field-lesson-usability-group-b.md) | 필드 레슨 노트 사용성 개선 — 자동 저장 + 홀 네비게이터 (묶음 B) | accepted | 2026-04-26 |
| [0008](0008-field-lesson-shortgame-stats-group-c.md) | 필드 레슨 노트 숏게임 통계 — 샌드세이브 + 업앤다운 + 드라이빙 평균 (묶음 C) | accepted | 2026-04-26 |
| [0009](0009-golf-course-autocomplete.md) | 골프장 자동완성 — 프로별 누적 입력 기반 | accepted | 2026-04-26 |
| [0010](0010-design-token-unification-and-qa.md) | 디자인 토큰 일원화 + QA 동시 패스 | accepted | 2026-04-26 |
