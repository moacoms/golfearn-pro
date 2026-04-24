# ADR-0005: Vercel 배포 — prebuilt `build/web` 서빙 구조

**Date**: 2026-03
**Status**: accepted
**Deciders**: hdopen@moacoms.com

## Context

Flutter 웹 앱을 Vercel에 배포. Vercel 공식 런타임은 Flutter SDK를 제공하지 않아 빌드 컨테이너에서 `flutter build web`을 직접 실행하려면 부가 설정 필요. pre-launch 단계에선 배포 파이프라인을 단순하게 유지하고 싶고, 빌드 결과가 환경에 덜 의존적이길 원했음.

## Decision

`vercel.json`의 `buildCommand`는 `echo`만 실행, `outputDirectory: build/web`. 로컬에서 `flutter build web --release --dart-define=...`로 빌드 후 `build/web` 산출물을 Git에 커밋(.gitignore에 `!/build/web/` 예외 설정, `git add -f`로 강제 추가). Vercel은 SPA rewrites + 보안 헤더만 적용하고 정적 파일을 서빙.

## Alternatives Considered

### 대안 1: Vercel 빌드에서 Flutter 설치 후 자동 빌드
- **Pros**: 소스만 푸시하면 자동 빌드, Git 히스토리 경량
- **Cons**: 빌드 시간 2~3분 추가, Flutter SDK 캐시 관리, 빌드 실패 시 배포 막힘
- **Why not**: pre-launch에선 로컬 빌드가 더 빠르고 제어 쉬움

### 대안 2: GitHub Actions로 빌드 후 Vercel 배포
- **Pros**: CI 단계에서 빌드, 로컬 부담 없음
- **Cons**: 파이프라인 구성·시크릿 관리 복잡, 디버깅 오버헤드
- **Why not**: 오버엔지니어링

### 대안 3: Firebase Hosting / Cloudflare Pages 등 대체 호스트
- **Pros**: Firebase는 Flutter 웹 공식 지원
- **Cons**: 이미 Vercel 사용 중, 마이그레이션 비용
- **Why not**: 기존 인프라 유지

## Consequences

### Positive
- 배포 흐름 단순 (로컬 빌드 → 커밋 → 푸시)
- 로컬에서 검증한 빌드가 그대로 운영에 배포되어 결과 재현성 높음

### Negative
- **코드 변경 시 반드시 로컬 빌드 + `build/web` 재커밋 필수** — 소스만 푸시하면 운영에 반영되지 않음 (실제로 최근 발생한 실수 사례 있음)
- `build/web` 커밋으로 인해 Git 히스토리가 비대 (커밋당 수만 줄 추가/삭제)
- `--dart-define`으로 환경변수 주입하므로 빌드 스크립트 표준화 필요

### Risks
- 실수로 소스만 커밋하고 `build/web` 누락 → 이전 빌드가 유지되어 사용자가 변경 미반영으로 오해
- 완화: 배포 체크리스트 / 커밋 훅으로 `build/web` 최신 여부 검증 검토
