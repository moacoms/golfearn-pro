# ADR-0003: 홀별 좌/우 그린 필드

**Date**: 2026-04-21
**Status**: accepted
**Deciders**: hdopen@moacoms.com

## Context

한국 골프장은 잔디 관리·코스 운영 이유로 한 홀에 좌그린/우그린 두 개를 두고 교대로 사용하는 경우가 많다. 같은 홀이어도 좌/우 그린에 따라 거리·레이아웃·난이도·공략법이 달라 레슨프로가 평가·분석할 때 의미가 다르다.

## Decision

각 홀 데이터에 `green_side: 'left' | 'right' | null` 필드를 추가. 입력 시 홀 카드 제목에 "좌그린/우그린"을 표기. 미입력 허용(nullable).

## Alternatives Considered

### 대안 1: 도입하지 않음
- **Pros**: 데이터 모델·UI 단순
- **Cons**: 한국 골프장 특수성을 표현 불가 → 프로 분석 가치 손실
- **Why not**: 타겟 사용자가 한국 레슨프로라 필수 요구

### 대안 2: 좌/우에 개별 `yardage_m`·`par` 필드까지 확장
- **Pros**: 정확한 거리 기록 가능
- **Cons**: 입력 부담 2배, pre-launch 단계에 과함
- **Why not**: 일단 `green_side`만 도입. 필요 시 추후 확장

## Consequences

### Positive
- "3번홀 좌그린은 항상 쇼트" 류의 패턴 분석 가능 기반 확보

### Negative
- 홀 카드 UI에 선택 필드 하나 추가 → 세로 길이 약간 증가

### Risks
- 데이터 축적 전엔 통계적 의미가 없음 — 실사용자 확보 후 활용
