# ADR-0006: 필드 레슨 기록 정확도 확장 (티박스·yardage·벌타·샷 거리)

**Date**: 2026-04-23
**Status**: accepted
**Deciders**: hdopen@moacoms.com

## Context

초기 필드 레슨 노트는 홀별 `par`·`score`·`putts`와 샷별 `result`·`causes`·`club`·`lie` 수준만 기록. 레슨프로 관점에서 평가 맥락이 부족함:

- 같은 파4라도 300m와 400m는 평가가 완전히 다름
- OB/해저드 등 벌타를 별도로 기록할 곳이 없어 "왜 이 점수가 나왔는가"가 유실
- 어프로치의 "남은 거리"가 없어 클럽 선택 평가 불가

## Decision

4개 필드를 단계적 확장의 첫 묶음(묶음 A)으로 추가. 모두 선택사항(nullable)이며 기존 데이터 호환성 유지:

- 라운드 단위: `field_data.tee_box` (`black` / `blue` / `white` / `gold` / `red`)
- 홀 단위: `yardage_m` (int?), `penalty_strokes` (int, 0~4)
- 샷 단위: `distance_m` (int?) — `shot_type`에 따라 UI 라벨 자동 변환 (티=비거리, 2nd/어프로치=남은거리, 퍼트=거리)

## Alternatives Considered

### 대안 1: 한꺼번에 샌드세이브·업앤다운 등 고급 지표까지
- **Pros**: 평가 완전성 ↑
- **Cons**: 입력 부담 급증, pre-launch 단계에 과함
- **Why not**: 단계적 확장 — 묶음 B(사용성: 자동 저장, 홀 네비게이터), 묶음 C(통계: 샌드세이브·업앤다운)로 분리

### 대안 2: 샷 거리를 두 필드로 분리 (친 거리 `distance_hit` + 남은 거리 `distance_remaining`)
- **Pros**: 의미가 명확히 구분됨
- **Cons**: 샷 카드 입력 필드 2배, UI 혼잡
- **Why not**: 단일 `distance_m`에 컨텍스트 라벨만 바꿔 충분. 필요 시 추후 분리

## Consequences

### Positive
- 같은 스코어라도 거리·벌타 맥락으로 더 정확한 평가 가능
- 향후 "드라이빙 평균 거리"·"어프로치 정밀도" 통계의 기초 데이터 확보

### Negative
- 홀 카드 UI 세로 길이 증가 → 18홀 스크롤이 길어짐 (묶음 B의 홀 네비게이터로 완화 예정)
- 모든 필드가 선택사항이라 미입력 데이터가 섞여 통계 계산 시 null 처리 필수

### Risks
- 기존 노트에는 새 필드가 없음 — 앱의 표시·통계 로직에서 null 허용 필수
- 묶음 B·C 진행 전엔 홀 입력 UI가 더 길어져 라운드 중 실시간 입력이 불편할 수 있음
