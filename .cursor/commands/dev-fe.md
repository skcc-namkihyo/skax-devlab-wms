---
description: "FE 개발 완성 | Lab 3: Frontend Implementation & API Integration"
---

# /dev-fe

## 개요
/gen-ui로 스캐폴딩된 프론트엔드 모듈을 완성합니다.
Composable, 페이지 로직, API 연동을 단계별로 구현합니다.

## 입력
- 모듈명 (예: "입고 관리")
- 또는 스캐폴딩된 디렉토리 경로

## 워크플로우

### Step 1: Composable 생성
- Skills: fe-composable-util, fe-composable-crud
- frontend/composables/use{Module}.js 생성
- useApi() 기반 CRUD 훅 작성
- 상태(state), 메서드(methods), 계산속성(computed) 구조

### Step 2: 페이지 로직 구현
- Skills: fe-page-crud
- `views/{module}/pages/List.js`: 목록 조회, 검색, 필터, 페이징
- `views/{module}/pages/Create.js`: 폼 유효성, 저장 로직
- `views/{module}/pages/Edit.js`: 기존 데이터 로드, 업데이트
- `views/{module}/components/{Module}Dialog.js`: 삭제 확인, 선택 로직

### Step 3: API 연동
- Skills: fe-composable-util
- useApi() 훅으로 백엔드 엔드포인트 호출
- 요청/응답 처리 (로딩, 에러, 토스트)
- 폼 데이터 바인딩

## 산출물
- **frontend/composables/use{Module}.js**
  - useApi() 기반 CRUD 함수
  - 로컬 상태 관리 (ref, reactive)
  - 에러 핸들링

- **frontend/views/{module}/pages/** (모두 완성, `.js` 확장자)
  - List.js: API 호출 + 테이블 렌더링
  - Create.js: 폼 제출 + 저장
  - Edit.js: 데이터 로드 + 수정

- **frontend/views/{module}/components/** (모두 완성, `.js` 확장자)
  - {Module}Form.js: 폼 유효성 로직
  - {Module}Table.js: 테이블 이벤트 핸들러
  - {Module}Dialog.js: 다이얼로그 상태 관리

## 체크포인트
- [ ] Composable이 useApi() 기반으로 작성되었는가?
- [ ] 모든 페이지가 API와 연동되는가?
- [ ] 에러 메시지가 사용자 친화적인가?
- [ ] 로딩 상태가 UI에 반영되는가?
- [ ] 폼 유효성이 검증되는가?
