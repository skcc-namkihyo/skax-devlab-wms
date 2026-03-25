---
description: "FE-BE 연동 검증 | Lab 6: API Integration Testing"
---

# /integrate

## 개요
프론트엔드와 백엔드의 CRUD 연동을 검증합니다.
API 엔드포인트 확인, Composable 연결, 통합 테스트를 수행합니다.

## 입력
- 모듈명 (예: "입고 관리")

## 워크플로우

### Step 1: API 엔드포인트 확인
- Skills: be-controller
- /api/{module} GET (목록)
- /api/{module}/{id} GET (상세)
- /api/{module} POST (생성)
- /api/{module}/{id} PUT (수정)
- /api/{module}/{id} DELETE (삭제)
- HTTP 상태 코드 검증 (200, 201, 400, 404, 500)

### Step 2: FE Composable 연결
- Skills: fe-composable-util
- useApi() 훅 검증
- 요청 경로 일치 확인
- 응답 데이터 구조 매핑
- 에러 처리 로직 검증

### Step 3: CRUD 통합 테스트
- 목록 조회: API 호출 → 테이블 렌더링
- 생성: 폼 입력 → POST → 목록 새로고침
- 상세: 행 클릭 → GET → 폼 자동 채움
- 수정: 폼 수정 → PUT → 목록 업데이트
- 삭제: 선택 → DELETE → 목록 새로고침

### Step 4: 검증 리포트 생성
- 성공한 엔드포인트
- 실패한 엔드포인트 (에러 메시지)
- 개선 제안

## 산출물
- **integration-{module}-report.md**
  - 테스트 항목 (테이블)
  - 엔드포인트별 결과
  - 스크린샷 or 로그

## 체크포인트
- [ ] 모든 엔드포인트가 응답하는가?
- [ ] 요청/응답 데이터가 일치하는가?
- [ ] 에러 응답이 명확한가?
- [ ] FE 폼이 API와 동기화되는가?
- [ ] 로딩/에러 상태가 UI에 반영되는가?
