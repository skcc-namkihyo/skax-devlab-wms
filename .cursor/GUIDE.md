# Cursor 3-Layer 실행 가이드

> **대상**: devAX 2-Day Cursor 교육 수강생
> **갱신일**: 2026-03-19
> **구조**: Rules (자동) + Skills (참조) + Commands (실행)

---

## 1. 변경 요약: Prompt → 3-Layer

### Before (Prompt 방식)
```
"@001 실행해줘" → prompts/001.requirements-definition.prompt.md 전체 로드 (149줄)
"@005 실행해줘" → prompts/005.backend-dev.prompt.md 전체 로드 (1,586줄)
```
- 매번 전체 프롬프트를 컨텍스트에 로드 → **토큰 낭비**
- Role 정의 + 규칙 + 코드가 한 파일에 혼합 → **수정 시 사이드이펙트**

### After (3-Layer 방식)
```
"/gen-req" 입력 → Command가 필요한 Skill만 동적 로드 + Rule은 파일 매칭으로 자동 적용
```
- 필요한 것만 로드 → **토큰 효율 5~10배**
- Rule / Skill / Command 분리 → **독립 수정 가능 (SRP)**

---

## 2. 3-Layer 동작 원리

```
┌─────────────────────────────────────────────────────┐
│  Rules (.mdc)                                       │
│  → 파일 패턴 매칭으로 자동 활성화                       │
│  → 교육생이 신경 쓸 필요 없음                           │
│  예: backend/**/*.java 편집 시 backend.dev.mdc 자동 적용│
├─────────────────────────────────────────────────────┤
│  Skills (SKILL.md)                                  │
│  → Command가 필요할 때 동적 참조                       │
│  → 직접 실행하지 않음 (Command가 호출)                  │
│  예: /dev-be 실행 → be-controller Skill 자동 로드      │
├─────────────────────────────────────────────────────┤
│  Commands (.md)                                     │
│  → 교육생이 직접 실행하는 유일한 진입점                   │
│  → "/" + 명령어 이름으로 실행                           │
│  예: /gen-req, /dev-be, /gen-task                    │
└─────────────────────────────────────────────────────┘
```

**핵심**: 교육생은 **Commands만 실행**하면 됩니다. Rules와 Skills는 자동으로 동작합니다.

---

## 3. 실행 매핑표: As-Is → To-Be

### 교육 Lab 순서 (Day 1~2)

| 교육 순서 | As-Is (Prompt) | To-Be (Command) | 설명 |
|-----------|---------------|-----------------|------|
| **Lab 0** | *(수동 설정)* | `/init-module` | 프로젝트 초기화 + Spring Boot 공통모듈 13개 파일 자동 생성 |
| **Lab 1a** | `@001` 요구사항정의서 | `/gen-req` | RFP → 요구사항정의서 (8-Section 템플릿) |
| **Lab 1b** | `@002` Task 정의서 | `/gen-task` | 요구사항 → Task 정의서 (Mermaid 다이어그램 포함) |
| **Lab 2a** | `@003` UI 설계서 | `/gen-ui` | Task → FE 파일 스캐폴딩 (빈 템플릿 생성) |
| **Lab 2b** | `@004` FE 개발 | `/dev-fe` | 스캐폴딩 → 실제 FE 구현 (비즈니스 로직, API 연동) |
| **Lab 3** | `@005` BE 개발 | `/dev-be` | Task + FE결과 → BE API 완전 구현 |
| **Lab 3** | *(005 내 포함)* | `/dev-db` | DB DDL + Mapper XML 생성 |
| **Lab 4** | *(수동)* | `/integrate` | FE ↔ BE 통합 테스트 |

### 유틸리티 Commands

| As-Is (Prompt) | To-Be (Command) | 설명 |
|---------------|-----------------|------|
| `@generate-project-memory` | `/gen-memory` | MCP Memory 지식 그래프 생성 |
| `@summarize-chat-context` | `/save-context` | 세션 컨텍스트 보존 |
| *(없음)* | `/dev-result` | 개발 결과 산출물 정리 |
| *(없음)* | `/check-structure` | 프로젝트 구조/네이밍 검증 |

### 실무 확장 Commands (교육 범위 외)

| Command | 설명 | 사용 시점 |
|---------|------|----------|
| `/analyze` | 코드 분석 | 기존 코드 파악 시 |
| `/impact` | 변경 영향도 분석 | 수정 전 리스크 확인 |
| `/design` | 설계 문서 생성 | 아키텍처 설계 시 |
| `/plan` | 실행 계획 수립 | 복잡한 작업 전 |
| `/implement` | 구현 실행 | 설계 → 코드 변환 |
| `/scaffold` | 모듈 스캐폴딩 | 새 모듈 추가 시 |
| `/test` | 테스트 실행 | 구현 완료 후 |
| `/review` | 코드 리뷰 | PR 전 품질 확인 |
| `/pr` | Pull Request 생성 | 코드 리뷰 후 |
| `/hotfix` | 긴급 수정 | 운영 이슈 대응 |

---

## 4. 실행 방법

### Step 1: Cursor Chat 열기
```
Ctrl + L  (또는 Cmd + L)
```

### Step 2: Command 입력
```
/gen-req
```
> 슬래시(/) + 명령어 이름을 입력하면 자동완성 목록이 나타납니다.

### Step 3: 입력 요구사항 확인
각 Command는 실행 시 필요한 입력을 안내합니다:
```
예시 (/gen-req 실행 시):
→ "RFP 문서 경로 또는 요구사항을 입력해주세요"
→ docs/01.analysis/01.rfp/wms-rfp.md 경로 지정
```

### Step 4: 산출물 확인
각 Command 실행 후 생성되는 파일 위치:

| Command | 산출물 경로 |
|---------|-----------|
| `/gen-req` | `docs/01.analysis/02.requirements/{시스템명}-{seq}.{메뉴경로}.md` |
| `/gen-task` | `docs/02.design/01.task/task-{기능명}.md` |
| `/gen-ui` | `frontend/views/{module}/` (디렉토리 + 스켈레톤 파일) |
| `/dev-fe` | `frontend/views/{module}/` (완성된 페이지/컴포넌트) |
| `/dev-be` | `backend/src/main/java/{package}/` (Controller/Service/Mapper) |
| `/dev-db` | `database/ddl/` (DDL 파일) |
| `/init-module` | `backend/src/main/java/{package}/common/`, `config/`, `auth/` |

---

## 5. 교육 Day 1-2 Quick Reference

### Day 1: 분석 → 설계

```
① /init-module          ← 프로젝트 초기 설정 (최초 1회)
② /gen-req              ← RFP → 요구사항정의서
③ /gen-task             ← 요구사항 → Task 정의서
④ /gen-ui               ← Task → FE 스캐폴딩
```

### Day 2: 구현 → 통합

```
⑤ /dev-be               ← BE API 구현 (공통모듈 자동 확인)
⑥ /dev-db               ← DB DDL + Mapper
⑦ /dev-fe               ← FE 실제 구현 (API 연동)
⑧ /integrate            ← FE ↔ BE 통합 확인
⑨ /dev-result           ← 결과 산출물 정리
```

---

## 6. FAQ

### Q: "예전처럼 @001 실행해줘" 하면 안 되나요?
**A**: prompts/ 폴더가 `_archive/`로 이동되어 더 이상 `@` 참조가 동작하지 않습니다.
대신 `/gen-req`처럼 Command 이름으로 실행하세요.

### Q: Rule은 어떻게 적용되나요?
**A**: 자동입니다. 예를 들어 `.java` 파일을 편집하면 `backend.dev.mdc` Rule이 자동 활성화되어
네이밍 컨벤션, 코딩 표준 등이 AI에게 자동 주입됩니다. 별도 조작 불필요.

### Q: Skill은 직접 실행할 수 있나요?
**A**: 아닙니다. Skill은 Command 실행 시 자동으로 참조됩니다.
예: `/dev-be` 실행 → `be-controller`, `be-service-mapper` Skill 자동 로드.

### Q: 하나의 Command가 끝나면 다음은 자동 실행되나요?
**A**: 아닙니다. 각 Command는 독립 실행입니다.
산출물을 확인한 후 다음 Command를 수동으로 입력하세요.

### Q: 이전 프롬프트에 있던 상세 코드는 어디로 갔나요?
**A**: Skills로 분산되었습니다:

| 이전 위치 | 현재 위치 |
|----------|----------|
| 005 프롬프트 내 공통모듈 ~800줄 | `skills/be-common-module/SKILL.md` |
| 002 프롬프트 내 Task 템플릿 | `skills/task-template/SKILL.md` |
| 004 프롬프트 내 에러 핸들러 | `skills/fe-component/SKILL.md` |
| 004 프롬프트 내 API 응답 패턴 | `skills/fe-composable-crud/SKILL.md` |
| 005 프롬프트 내 Swagger 가이드 | `skills/be-controller/SKILL.md` |

### Q: 전체 자산 구조를 보고 싶어요
```
.cursor/
├── rules/          ← 10개 (자동 적용)
│   ├── project.common.mdc
│   ├── project.init.mdc
│   ├── backend.dev.mdc
│   ├── backend.db.naming.mdc
│   ├── backend.db.sql-pattern.mdc
│   ├── postgresql.mdc
│   ├── frontend.dev.mdc
│   ├── frontend.ui-design.mdc
│   ├── frontend.component.mdc
│   └── db.naming-standard.mdc
├── skills/         ← 14개 (Command가 참조)
│   ├── be-common-module/
│   ├── be-controller/
│   ├── be-map-util/
│   ├── be-service-mapper/
│   ├── be-sql-select/
│   ├── be-sql-write/
│   ├── db-advanced-sql/
│   ├── db-ddl/
│   ├── fe-component/
│   ├── fe-composable-crud/
│   ├── fe-composable-util/
│   ├── fe-page-crud/
│   ├── fe-scaffold/
│   └── task-template/
├── commands/       ← 22개 (직접 실행)
│   ├── gen-req.md        ← Lab 1a
│   ├── gen-task.md       ← Lab 1b
│   ├── gen-ui.md         ← Lab 2a
│   ├── dev-fe.md         ← Lab 2b
│   ├── dev-be.md         ← Lab 3
│   ├── dev-db.md         ← Lab 3
│   ├── integrate.md      ← Lab 4
│   ├── init-module.md    ← Lab 0
│   ├── dev-result.md     ← 유틸
│   ├── save-context.md   ← 유틸
│   ├── gen-memory.md     ← 유틸
│   ├── check-structure.md← 유틸
│   ├── analyze.md        ← 실무
│   ├── impact.md         ← 실무
│   ├── design.md         ← 실무
│   ├── plan.md           ← 실무
│   ├── implement.md      ← 실무
│   ├── scaffold.md       ← 실무
│   ├── test.md           ← 실무
│   ├── review.md         ← 실무
│   ├── pr.md             ← 실무
│   └── hotfix.md         ← 실무
├── agents/         ← 7개 서브에이전트 (Cursor 공식 포맷)
│   ├── root.md           ← Root Agent (오케스트레이터)
│   ├── backend.md        ← BE Agent (Spring Boot)
│   ├── backend-test.md   ← BE Test Agent (파괴적 검증)
│   ├── frontend.md       ← FE Agent (Vue 3 CDN)
│   ├── frontend-test.md  ← FE Test Agent (UI 검증)
│   ├── db.md             ← DB Agent (PostgreSQL)
│   └── infra.md          ← Infra Agent (DevOps)
├── GUIDE.md        ← 이 파일
```
