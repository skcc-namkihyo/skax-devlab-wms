---
description: "프로젝트 컨텍스트 저장 | Save project context to .cursor for AI continuity"
---

# /save-context

## 개요
현재 프로젝트의 핵심 컨텍스트를 `.cursor/` 구조에 저장하여 AI 세션 간 연속성을 보장합니다.

## 입력
- 없음 (자동 수집)

## 워크플로우

1. **프로젝트 구조 스캔**
   - `backend/`, `frontend/`, `database/` 디렉토리 트리 수집
   - 주요 설정 파일 목록 (application.yml, package.json 등)

2. **현재 상태 캡처**
   - 구현 완료된 모듈 목록
   - 진행 중인 Task 목록
   - 최근 변경 파일 (git diff --name-only)

3. **컨텍스트 파일 생성**
   - `.cursor/context/project-state.md` 저장
   - 타임스탬프 포함

## 산출물
- **`.cursor/context/project-state.md`**: 프로젝트 현재 상태 스냅샷

## 체크포인트
- [ ] 프로젝트 구조가 정확히 반영되었는가?
- [ ] 진행 상태가 최신인가?
- [ ] 다음 세션에서 컨텍스트 로드가 가능한가?
