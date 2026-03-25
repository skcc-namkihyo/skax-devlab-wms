---
description: "UI 설계서 | Task+Mock JSON HTML 설계, 01.tasks 전체 순차 처리 지원 (docs/02.design/02.ui)"
---

# /gen-ui-design

## 개요

Task 정의서를 기반으로 **AI 개발자가 즉시 개발에 사용할 수 있는 구체적이고 실행 가능한 UI 설계서**를 작성한다. **`docs/02.design/01.tasks/`에 있는 모든 `*.task.md`를 순번 순으로 한 건씩 처리**하는 **전체 순차 모드**를 표준 워크플로우로 둔다(단일 Task만 지정된 경우는 예외).

> [!CRITICAL]
> **Role**: Senior UI/UX Designer & Frontend Expert & Web Designer
>
> **Constraint**: 실제 개발 코드 작성이나 개발 작업 수행 금지. **UI 설계서 HTML 파일 작성에만 집중**한다.

본 `/gen-ui-design` 커맨드 문서가 UI 설계서(Mock JSON + HTML) 작성의 **기준**이다. **Mock 기반 화면 설계**에 맞추며, DDL·스키마 SQL 등 **DB 파일 참조는 요구하지 않는다**.

## 입력

- **Task 정의서** (필수): 아래 **실행 모드** 중 하나에 해당하는 입력을 확보한다.
  - **단일 Task 모드**: 사용자가 특정 `*.task.md` 파일을 지정하거나 첨부한 경우 — 그 파일만 대상으로 본문의 1~3단계를 수행한다.
  - **전체 순차 모드**(기본 권장): `docs/02.design/01.tasks/`에 생성된 **모든** `*.task.md`에 대해 **한 파일씩 순서대로** UI 설계서를 생성한다. 별도 지정이 없으면 이 모드를 택한다.

전체 순차 모드에서 Task 파일이 없으면 작업을 중단하고 사용자에게 Task 생성(`docs/02.design/01.tasks/`)을 요청한다.

## 필수 참조 문서

다음 지침 문서들을 **반드시 준수**한다.

- **UI/UX 디자인 시스템**: `.cursor/rules/frontend.ui-design.mdc` — 색상·타이포·Element Plus 테마·스페이싱·레이아웃(§7)·폼(§8)·체크리스트(§10)
- **프론트엔드 개발**: `.cursor/rules/frontend.dev.mdc` — Vue 3 CDN, Element Plus, Tailwind, 디렉터리·코드 스타일
- **컴포넌트·Composable**: `.cursor/rules/frontend.component.mdc` — defineComponent, Element Plus 사용·명명 규칙

> **HTML 설계서의 좌·우 2분할 문서 형식**은 아래 **「UI 설계서 HTML 문서 형식 (좌 UI · 우 명세)」**에 따른다. `frontend.ui-design.mdc`는 앱 UI 스타일 가이드이며, 설계서 HTML의 좌우 패널 구조를 대체하지 않는다.

## Task 목록 수집·정렬 (전체 순차 모드)

`docs/02.design/01.tasks/` **및 그 하위 디렉터리**(있을 경우)에서 `**/*.task.md` 또는 `*.task.md`를 수집한다.

**정렬 규칙**(순차 생성 순서):

1. 파일명 접두 `wms-` 뒤의 **3자리 순번(001~999)을 숫자로 해석**해 **오름차순**으로 정렬한다.  
   - 예: `wms-001.…task.md` → `wms-002.…task.md` → … → `wms-006.…task.md`
2. 순번을 파싱할 수 없는 파일은 **파일 경로·이름의 사전순**을 그 다음 우선순위로 둔다.
3. 동일 Task 세트를 여러 번 돌릴 때는 **이미 `docs/02.design/02.ui/{{ fileName }}/`에 HTML이 있는지** 확인하고, 사용자가 “덮어쓰기/스킵” 중 무엇을 원하는지 확인한다(기본: 기존 파일이 있으면 스킵 또는 diff 검토 후 갱신).

**Epic·하위 Task 관계**: `wms-001` 등 **Epic 개요 Task**는 하위 `wms-002`~ 문서와 화면이 겹칠 수 있다. 중복을 줄이기 위해 **하위 Task에만 있는 화면·API는 해당 하위 Task의 `{{ fileName }}` 폴더에 설계**하고, Epic 문서에는 **목차·통합 대시보드·공통 Mock만** 두는 방식을 허용한다(문서 §0·링크 표에 따름).

## 기존 UI 설계서 참고

`docs/02.design/02.ui/`에 기존 HTML·Mock이 있으면 **좌·우 레이아웃·번호 체계·명세 스타일**을 우선 참고한다. 디렉터리가 없으면 생성하고, 아래 문서 형식과 Task 정의서에 맞춰 첫 산출물을 만든다. **전체 순차 모드**에서는 **앞선 Task에서 만든 HTML·Mock 패턴을 다음 Task에 그대로 이어** 일관성을 유지한다.

## UI 설계서 HTML 문서 형식 (좌 UI · 우 명세)

설계서는 **단일 HTML 파일** 안에서 **가로 2분할**로 구성한다. Live Server 등으로 열었을 때 **좌측에서 동작하는 프로토타입**과 **우측에서 개발 근거가 되는 명세**를 동시에 볼 수 있어야 한다.

### 좌측 영역 (UI)

- Task 정의서에 맞는 **실제 화면에 가까운** 배치로 구성한다.
- **Element Plus** 컴포넌트와 프로젝트에서 허용하는 방식(Tailwind·클래스 CSS 등)만 사용한다.
- 목록·폼 등은 `docs/02.design/02.ui/common/api/v1/[resource].json` **Mock JSON**과 연동해 동작을 재현한다(fetch 또는 동등한 로드 방식).
- **인터랙션 가능한 모든 요소**(버튼, 링크, 입력, 셀렉트, 테이블 행 액션, 페이지네이션 등)에 **고유 번호**를 붙인다.  
  - 화면에 보이는 라벨(예: `①`, `②`) 또는 `data-spec-id="1"` 등 **우측 명세와 1:1로 대응** 가능한 방식을 택하고, 한 화면 내에서 번호가 겹치지 않게 한다.

### 우측 영역 (명세)

- **좌측 번호와 동일한 순서·식별**로 블록을 나열한다.
- 각 블록에 최소 다음을 적는다(해당 없으면 생략 가능하나, 생략 이유가 명확해야 한다).
  - **요소 유형·라벨**(버튼/필드/컬럼/영역 등)
  - **동작·기능 설명**(클릭 시, 조회 조건, 권한 가정 등)
  - **입력 검증·표시 규칙**
  - **연동 API 가정**(HTTP 메서드·경로·주요 요청·응답 필드) — Mock JSON과 모순 없게
  - **예외·비고**
- 목록 화면은 **검색 영역 / 테이블 컬럼 / 행 단위 액션 / 상단·하단 툴바** 등으로 나누어 번호와 명세를 쪼갠다.

### 공통·제약

- **`style="..."` 인라인 스타일은 사용하지 않는다.** 스타일은 클래스·외부·인라인 `<style>` 블록 등으로만 부여한다.
- 금지 버튼·비허용 기능·버튼 배치·페이지네이션 레이아웃은 **Task 정의서**와 기존 설계서 패턴을 따른다.
- 상단(선택): 화면명, Task 식별, 메뉴 경로 등 메타 정보를 둘 수 있다.

## 변수 정의

### 근거·참조 파일 (선언 기준)

아래 변수·`{{ fileName }}` 조합은 **단일 원본 파일이 아니라** 다음에 **분산 정의**되어 있다. 충돌 시 **실제 산출물 파일명**이 우선한다.

| 참조 | 내용 |
|------|------|
| `.cursor/skills/task-template/SKILL.md` | Task 정의서 **파일명 규칙** (`{SYSTEM_NAME}-{3digitSeqNum}.{1depth}-{2depth}-{3depth}.task.md`, 3Depth 선택) |
| `.cursor/commands/gen-task.md` | Task 분해·산출 워크플로우 (`/gen-task`; 채번·메뉴명은 위 SKILL·README와 정합) |
| `README.md` | 파이프라인 산출 예: Task `wms-{{3digitSeqNum}}.{{1depthMenuName}}-{{2depthMenuName}}.task.md`, UI `docs/02.design/02.ui/{{fileName}}/` |
| `.cursor/commands/gen-req.md` | 요구사항 정의 진입점 (`/gen-req`); 시스템명·메뉴 메타는 `docs/01.analysis/02.requirements/` 산출물과 맞출 것 |

> **`.cursor/prompts/*.md`는 삭제 대상**이며, 변수·절차는 **Commands·Skills·README·본 문서**만 참조한다.

**우선순위**: UI 설계서 폴더명 `{{ fileName }}`은 위 표의 이론식보다 **`docs/02.design/01.tasks/`에 있는 대응 Task 정의서 파일명에서 `.task.md`만 뗀 문자열**과 맞추는 것을 권장한다(예: `wms-001.전체-WMS-기존기능개선`). 메뉴 뎁스 3단을 쓰지 않는 Task는 README·실파일처럼 **2단까지만** 쓴다.

### 변수 표

UI 설계서 디렉터리명·문서 메타에 사용:

| 변수 | 설명 |
|------|------|
| `{{ systemName }}` | 시스템 접두(소문자). WMS 교육 프로젝트에서는 보통 `wms` (`task-template`의 `{SYSTEM_NAME}`에 대응) |
| `{{ 1depthMenuName }}` | 1Depth 메뉴명·기능 구간(한국어 등). 실제 Task는 `전체-WMS`처럼 **복합 명**일 수 있음 |
| `{{ 2depthMenuName }}` | 2Depth 또는 기능 요약 구간 |
| `{{ 3depthMenuName }}` | 3Depth(선택). 없으면 파일명·폴더명에서 **생략**하고 끝에 불필요한 `-`를 붙이지 않는다 |
| `{{ 3digitSeqNum }}` | `docs/02.design/01.tasks/` 기존 `.task.md` 패턴을 보고 채번 (001, 002, …) |
| `{{ fileName }}` | **권장**: 대응 Task 파일명에서 `.task.md`만 뗀 문자열. **조합식**(참고): 3Depth 있으면 `{{ systemName }}-{{ 3digitSeqNum }}.{{ 1depthMenuName }}-{{ 2depthMenuName }}-{{ 3depthMenuName }}`, 없으면 마지막 `-{{ 3depthMenuName }}` 없이 `{{ systemName }}-{{ 3digitSeqNum }}.{{ 1depthMenuName }}-{{ 2depthMenuName }}` 까지 |

## 작업 계획 (단계 분할)

### 한 Task당 마이크로 단계 (반복)

각 Task 파일마다 아래 **3단계**를 적용한다(Todo 등으로 **Task별·단계별**로 기록). **각 Task 완료 후** 다음 Task로 넘어가기 전에 사용자 확인을 받는다(자동 일괄 실행 금지). 파일에 기록되지 않는 중간 결과는 최대한 요약해 표시한다.

1. Mock 데이터 생성 및 보완 (해당 Task·화면 요구 기준)  
2. UI 설계서 HTML 작성 (좌 UI · 우 명세 형식 준수)  
3. UI 설계서·해당 Task 정의서 반영 검증  

### 전체 순차 모드 매크로 흐름

1. **목록화**: 위 「Task 목록 수집·정렬」에 따라 처리 순서가 정해진 `*.task.md` 배열을 만든다.  
2. **순차 실행**: 배열의 **첫 번째 Task부터 마지막까지** 위 **한 Task당 마이크로 단계 1→2→3**을 반복한다.  
3. **진행 표시**: 매 반복마다 현재 Task **파일명·`{{ fileName }}`·생성·갱신한 HTML/Mock 목록**을 짧게 보고한다.  
4. **공통 Mock**: `docs/02.design/02.ui/common/api/v1/`는 **Task 간 공유**한다. 동일 리소스명 JSON이 이미 있으면 **필드 병합·확장 시 기존 소비자 HTML과 충돌 없는지** 확인한다.

---

## 1단계: Mock 데이터 생성 및 보완

**목표**: HTML 설계서에서 사용할 Mock 데이터를 **Task 정의서와 화면에 필요한 필드**를 기준으로 준비한다.

**수행 방법**:

1. Task 정의서에서 목록·폼·상세 등에 필요한 데이터 항목·응답 형태 파악  
2. `docs/02.design/02.ui/common/api/v1/[resource].json` Mock 데이터 확인  
   - 있으면 사용, 없으면 생성(Backend API 응답 형식과 동일하게 가정)  
   - 확장자 `.json`, 예: `brand-masters.json`, `users.json`  

**Mock 데이터 구조**: Task 정의서의 API·필드 정의와 `.cursor/rules/frontend.dev.mdc`의 API·JSON 관례를 따른다.

---

## 2단계: UI 설계서 HTML 작성

**목표**: Task 정의서를 기반으로 UI 설계서 HTML을 생성한다.

**저장 위치**: `docs/02.design/02.ui/{{ fileName }}/[파일명].html`  
- 파일명·페이지 분할: 변수 표 `{{ fileName }}` 및 기존 `docs/02.design/02.ui/` 패턴(있을 때)·Task 정의서를 우선한다.

**구조**: 위 **「UI 설계서 HTML 문서 형식 (좌 UI · 우 명세)」**를 반드시 따른다. 시각·간격·GNB/LNB 등은 추가로 `.cursor/rules/frontend.ui-design.mdc` §7·§8·§10을 참고한다.

---

## 3단계: UI 설계서 검증 및 보완

**목표**: 작성된 UI 설계서가 모든 요구사항을 충족하는지 검증한다.

**검증 항목**:

1. **지침 준수**: `.cursor/rules/frontend.ui-design.mdc`·`.cursor/rules/frontend.dev.mdc`·`.cursor/rules/frontend.component.mdc`, 기존 UI 설계서와의 일관성  
2. **좌·우 명세**: 좌측 UI와 우측 명세가 **번호로 완전 대응**하고, Task 기능 요구가 누락 없이 반영됨  
3. **데이터·동작**: Mock이 Task·화면 요구와 맞고 `docs/02.design/02.ui/common/api/v1/*.json`에 두며, Element Plus만 사용, Live Server로 열어 동작 가능  
4. **제약**: inline style 미사용, 금지 버튼/기능 없음, 버튼 배치·페이지네이션 layout 규칙 준수  

**보완**: 누락·불일치 발견 시 즉시 수정하고 Task 정의서·기존 패턴에 맞춘다.

---

## 산출물

- `docs/02.design/02.ui/common/api/v1/*.json` (필요 시, **Task 간 공유**)  
- **Task마다** `docs/02.design/02.ui/{{ fileName }}/*.html` — `{{ fileName }}`은 해당 `*.task.md`의 베이스명(확장자 제외)  
- 전체 순차 모드 완료 시: Task 개수만큼의 `{{ fileName }}` 디렉터리(또는 동일 Task 내 복수 HTML)가 누적된다.

## 최종 품질 기준

- **완성도**: Task 정의서 기능 요구가 UI에 완전히 반영됨  
- **일관성**: Element Plus·기존 UI 설계서와 일관  
- **사용성**: **우측 명세만으로도** 구현 판단이 가능한 수준  
- **확장성**: 이후 구현 단계에 맞는 구조  
- **실행 가능성**: VSCode Live Server로 바로 확인 가능  

## 팁

- 막히면 `.cursor/rules/frontend.ui-design.mdc`(디자인 시스템)를 보고, 구현 관점은 `.cursor/rules/frontend.dev.mdc`·`.cursor/rules/frontend.component.mdc`를 병행한다.  
- **좌·우 형식**은 본 문서의 **「UI 설계서 HTML 문서 형식」**과 `docs/02.design/02.ui/` 기존 예시(있을 때)를 맞춘다.  
- 단계 완료마다 검증해 재작업을 줄인다.  
- **전체 순차 모드**에서는 Task 문서 **§0 EPIC 하위 Task 표**·**권장 수행 순서**가 있으면, **파일명 3자리 순번과 모순되지 않는 한** 그 순서를 우선 설명에 반영한다(정렬은 여전히 파일명 순번 기준).  

## 체크포인트

### 단일 Task / 한 번의 반복

- [ ] Task 정의서가 첨부·반영되었는가?  
- [ ] Mock JSON이 Task·화면 필드와 API 응답 형식(가정)에 맞는가?  
- [ ] HTML이 **좌(UI)·우(명세)** 2분할과 번호 대응을 만족하는가?  
- [ ] 지정 경로·`{{ fileName }}` 규칙을 따르는가?  
- [ ] 인라인 스타일 금지 등 제약을 만족하는가?  
- [ ] Live Server로 열어 동작 확인이 가능한가?  

### 전체 순차 모드(폴더 전체)

- [ ] `docs/02.design/01.tasks/`(및 하위)의 모든 `*.task.md`를 **순번 정렬**해 빠짐없이 목록화했는가?  
- [ ] **Task마다** `docs/02.design/02.ui/{{ fileName }}/` 산출이 계획되었는가?  
- [ ] 각 Task 처리 후 다음 Task로 넘어가기 전 **검증·사용자 확인**을 했는가?  
- [ ] 공통 `common/api/v1/*.json` 추가·변경 시 **다른 Task HTML과의 호환**을 확인했는가?  
- [ ] Epic(`wms-001` 등)과 하위 Task 간 **화면 중복**을 정리(스킵·통합·참조)했는가?  
