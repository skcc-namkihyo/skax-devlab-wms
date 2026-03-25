---
description: "FE 개발 완성 | Lab 3: Frontend Implementation & API Integration"
---

# /dev-fe

## 개요
프론트엔드 모듈을 **Vue 3 CDN 앱**(`frontend/views/{module}/`의 `.js` 페이지·컴포넌트) 기준으로 완성합니다.  
Composable, 페이지 로직, API 연동을 단계별로 구현합니다.

구현 시 **반드시** 아래 설계 산출물을 함께 읽고, 화면·API·메시지 정책을 맞춘다.

### FE 스캐폴딩 전제 (신규 모듈)

| 경우 | 설명 |
|------|------|
| **권장(교육·표준)** | Skill **`fe-scaffold`**(및 필요 시 `fe-component`)로 `frontend/views/{module}/`·List/Create/Edit·컴포넌트 스켈레톤·`router.js`·`sidebar.js`를 갖춘 뒤, 이 커맨드로 내용을 채운다. |
| **생략 가능** | 위와 **동등한** `frontend/views/{module}/pages/*.js`, `components/*.js`와 라우트·메뉴가 이미 있으면 스캐폴딩 단계 없이 구현만 진행하면 된다. |
| **참고** | `docs/02.design/02.ui/`의 HTML 설계서는 **별도 산출물**이다. `/gen-ui-design`(HTML·Mock)은 **설계**, 본 커맨드는 **앱 코드** 구현이다. UI 설계서·Task를 함께 본다. |

스켈레톤이 없으면 **직접 동등한 구조를 만들거나** `fe-scaffold`를 적용한 뒤 진행하는 것이 사실상 전제다.

## 입력

### 필수 참조(설계 산출물)

- **Task 정의서**: `docs/02.design/01.tasks/*.task.md` — 해당 기능의 REQ, API 표, FE Task 분해, 인수 조건, 에러 코드(E2001/E4001 등) 정의
- **UI 설계서**: `docs/02.design/02.ui/{{ fileName }}/*.html` — 좌(UI 프로토타입)·우(명세) 및 `docs/02.design/02.ui/common/api/v1/*.json` Mock 형식

`{{ fileName }}`은 대응 Task 파일명에서 `.task.md`를 뗀 문자열과 맞춘다(`.cursor/commands/gen-ui-design.md` 변수 정의 참고).

### 실행 시 입력

- 모듈명 (예: "입고 관리")
- 또는 스캐폴딩된 디렉토리 경로 (`frontend/views/{module}/`)

## 워크플로우

### Step 0: 설계 정합 (선행)

- Task 정의서에서 구현 범위·API URL·응답 `{ result_code, result_message, data }` 규칙 확인
- UI 설계서 HTML에서 레이아웃·컴포넌트(Element Plus)·인터랙션·우측 명세와 동일 동작을 목표로 함
- Mock JSON 필드명을 API 연동 시 그대로 사용할지, BE 확정 후 매핑할지 구분해 둠
- 신규 모듈이면 **`fe-scaffold` Skill**로 `views/{module}/`·라우트·사이드바가 갖춰졌는지 확인(없으면 먼저 생성)

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
- [ ] 대응 `docs/02.design/01.tasks/*.task.md`의 API·인수 조건·에러 코드가 반영되었는가?
- [ ] `docs/02.design/02.ui/`의 해당 HTML·Mock과 화면·데이터 형태가 정합하는가?
- [ ] Composable이 useApi() 기반으로 작성되었는가?
- [ ] 모든 페이지가 API와 연동되는가?
- [ ] 에러 메시지가 사용자 친화적인가?
- [ ] 로딩 상태가 UI에 반영되는가?
- [ ] 폼 유효성이 검증되는가?
