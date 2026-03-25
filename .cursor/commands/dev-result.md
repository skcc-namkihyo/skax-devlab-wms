---
description: "개발 결과 산출물 정리 | Generate development result documentation"
---

# /dev-result

## 개요
개발 완료된 모듈의 소스코드 파일 목록과 구현 현황을 문서로 정리합니다.
`/dev-be`, `/dev-fe` 실행 후 결과 기록용으로 사용합니다.

## 입력
- 기능명 (예: "입고 관리")
- 계층 옵션: `--be`, `--fe`, `--all` (기본: all)

## 워크플로우

1. **구현 파일 수집**
   - Backend: `backend/src/main/java/` 하위 파일 스캔
   - Frontend: `frontend/views/{module}/` 하위 파일 스캔
   - Database: `database/ddl/` 하위 파일 스캔

2. **파일별 구현 상태 분석**
   - 파일 크기, 라인 수
   - 주요 메서드/함수 목록
   - TODO/FIXME 태그 존재 여부

3. **결과 문서 생성**
   - 파일 목록 테이블 (경로, 라인수, 상태)
   - API 엔드포인트 요약
   - 미구현 항목 목록

## 산출물
- **`docs/03.development/{feature}.dev-result.md`**: 개발 결과 문서
  - 구현 파일 목록
  - API 엔드포인트 매핑
  - 구현율 (%) 산출

## 체크포인트
- [ ] 모든 계층(DB/BE/FE)의 파일이 수집되었는가?
- [ ] 미구현 항목이 명확히 표시되었는가?
- [ ] API 엔드포인트와 프론트엔드 호출이 매핑되었는가?
