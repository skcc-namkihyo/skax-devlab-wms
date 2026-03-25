---
description: "Task 정의서 템플릿 | Task Definition Template with 8-Section Structure & Mermaid Diagrams"
---

# task-template

## 개요

AI 개발자가 즉시 개발을 시작할 수 있는 Task 정의서 템플릿입니다. 8개 섹션 구조와 Mermaid 다이어그램을 포함합니다.

**사용 시점**: `/gen-task` 명령어 실행 시 자동 로드
**출력 경로**: `docs/02.design/01.tasks/{SYSTEM_NAME}-{SEQ}.{menu-path}.task.md`

## 작성 핵심 원칙 (바이브 코딩)

- **구조화**: `1. → 1.1 → 1.1.1` 명확한 계층 구조
- **완결성**: 각 섹션 독립적 이해 가능
- **시각화**: 복잡한 로직은 Mermaid Diagram 필수
- **사용자 중심**: User Story 관점 기술
- **기술 명세**: API/데이터 모델 완전 정의

**철학**: Why → What → How 구조
- **Why**: 비즈니스 목표와 필요성
- **What**: 사용자 스토리와 인수 조건
- **How**: 기술적 가이드라인과 구현 방향

## 파일명 규칙

```
{SYSTEM_NAME}-{3digitSeqNum}.{1depthMenuName}-{2depthMenuName}-{3depthMenuName}.task.md
```

- `{SYSTEM_NAME}`: 시스템명 (소문자, 예: wms)
- `{3digitSeqNum}`: 순번 (001, 002, 003...)
- `{1depthMenuName}`: 1Depth 메뉴 (한국어, 예: 사용자관리)
- `{2depthMenuName}`: 2Depth 메뉴 (한국어, 예: 회원가입인증)
- `{3depthMenuName}`: 3Depth 메뉴 (optional)

## 템플릿 (8-Section)

아래 템플릿을 정확히 준수하여 작성합니다.

### 헤더

```markdown
# [기능명]

**문서 버전**: v1.0
**생성일자**: [YYYY-MM-DD]
**담당자**: [담당자]
**시스템**: {SYSTEM_FULL_NAME}
**메뉴 경로**: [1depth] > [2depth] > [3depth]
```

### Section 1. 개요

```markdown
## 1. 개요
### 1.1 목적
[비즈니스 목표와 필요성]

### 1.2 범위
- [구현 범위와 제외 사항]
```

### Section 2. 사용자 스토리 및 기능 명세

```markdown
## 2. 사용자 스토리 및 기능 명세

### 2.1 요구사항
> ⚠️ 한글이나 특수문자는 큰따옴표(")로 감싸야 오류가 발생하지 않음

\```mermaid
requirementDiagram

    requirement "[요구사항명]" {
        id: "[요구사항ID]"
        text: "[요구사항 설명]"
        risk: [low|medium|high]
        verifymethod: [inspection|test|analysis|demonstration]
    }

    element "[시스템/모듈명]" {
        type: [system|subsystem|component]
        docref: "[문서참조경로]"
    }

    [요구사항명] - satisfies -> [시스템/모듈명]
\```

### 2.2 관련 요구사항 (선택사항)
- [요구사항ID]: [요구사항명](RFP파일경로)

### 2.3 사용자 스토리

**주요 사용자**:
- **[역할1]**: [역할 설명]

**스토리**:
1. **[스토리명]**
   - As a [역할], I want to [작업], so that [목표].

### 2.4 인수 조건
- [ ] [검증 가능한 조건 1]
- [ ] [검증 가능한 조건 2]

### 2.5 기능 워크플로우

\```mermaid
sequenceDiagram
    actor User as 사용자
    participant UI as Frontend
    participant API as Backend API
    participant DB as Database

    User->>UI: [사용자 액션]
    UI->>API: [API 호출]
    API->>DB: [데이터 조회/수정]
    DB-->>API: [결과 반환]
    API-->>UI: [응답 데이터]
    UI-->>User: [화면 표시]
\```
```

### Section 3. 기술 요구사항

```markdown
## 3. 기술 요구사항

### 3.1 시스템 아키텍처

\```mermaid
C4Context
    title [기능명] 시스템 컨텍스트

    Person(user, "[사용자 역할]", "[사용자 설명]")

    System_Boundary(frontend, "Frontend") {
        Container(ui, "[Vue Component]", "Vue 3", "[컴포넌트 설명]")
    }

    System_Boundary(backend, "Backend") {
        Container(api, "[Controller]", "Spring Boot", "[API 설명]")
        Container(service, "[Service]", "Java", "[비즈니스 로직]")
        ContainerDb(db, "[Database]", "PostgreSQL", "[데이터 저장]")
    }

    Rel(user, ui, "[사용자 동작]")
    Rel(ui, api, "[HTTP 요청]", "REST API")
    Rel(api, service, "[비즈니스 로직 호출]")
    Rel(service, db, "[데이터 처리]", "MyBatis")
\```

### 3.2 데이터 모델

> **DB Schema**:
> - 우선순위 1: `database/schemas/*.sql` 기존 테이블 최대 활용
> - 우선순위 2: 신규 테이블 필요시 해당 도메인 기존 파일에 추가

\```mermaid
erDiagram
    [TABLE_NAME_1] {
        [DATA_TYPE] [COLUMN_NAME_1] PK "[컬럼 설명]"
        [DATA_TYPE] [COLUMN_NAME_2] "[컬럼 설명]"
    }

    [TABLE_NAME_2] {
        [DATA_TYPE] [COLUMN_NAME_1] PK "[컬럼 설명]"
        [DATA_TYPE] [COLUMN_NAME_2] FK "[컬럼 설명]"
    }

    [TABLE_NAME_1] ||--o{ [TABLE_NAME_2] : "[관계 설명]"
\```

### 3.3 API 설계

> ⚠️ DTO/VO 사용 금지. 모든 계층에서 `Map<String, Object>` 사용.
> Response Body: `{result_code, result_message, data}` 형식만 사용.

| Method | URL | Description | Request Body | Response Body |
|--------|-----|-------------|--------------|---------------|
| `GET` | `/api/[resource]` | 목록 조회 | - | Map (result_code, result_message, data) |
| `GET` | `/api/[resource]/{id}` | 상세 조회 | - | Map (result_code, result_message, data) |
| `POST` | `/api/[resource]` | 신규 등록 | Map | Map (result_code, result_message) |
| `PUT` | `/api/[resource]/{id}` | 수정 | Map | Map (result_code, result_message) |
| `DELETE` | `/api/[resource]/{id}` | 삭제 | - | Map (result_code, result_message) |

### 3.4 비즈니스 규칙

#### 3.4.1 데이터 유효성 검증
- **[필드명]**: [검증 규칙]

#### 3.4.2 권한 및 보안
- **접근 권한**: [권한 레벨]

#### 3.4.3 예외 처리 및 에러 핸들링
- **예외 1**: [상황] → "[에러 메시지]" (오류코드: E0000)
```

### Section 4. 개발 계획

```markdown
## 4. 개발 계획

### 4.1 전제조건
- 요구사항 및 데이터 모델 확정
- 변경 발생시 담당자 협의 후 진행

### 4.2 개발 단계

#### Step 1: 프론트엔드 개발
> ⚠️ plan_task tool 사용 — 6단계 분할

**구현 내용** (상세코드 작성 금지):
- **[기능]**: [설명]
  - 컴포넌트: `[Component].js`
  - 주요 메서드: `[method1]()`, `[method2]()`

**파일 구조**:
\```
frontend/
├── views/[menu-name]/
│   ├── [Feature]List.js
│   ├── [Feature]Edit.js
│   └── [Feature]Detail.js
├── components/[custom]/
└── api/v1/[menu-name].json  # Mock 데이터
\```

#### Step 2: 백엔드 개발
> ⚠️ plan_task tool 사용 — 4단계 분할

**구현 내용**:
- **Controller**: `[Resource]Controller.java`
- **Service**: `[Resource]Service.java`
- **Mapper**: `[Resource]Mapper.java` + `[Resource]Mapper.xml`

> DTO/VO 사용 금지. `Map<String, Object>` 사용.

### 4.3 테스트 전략
- **수동 테스트**: 브라우저 기능 검증
- **API 테스트**: Swagger UI (`http://localhost:8080/swagger-ui.html`)
```

### Section 5. 검증 체크리스트

```markdown
## 5. 검증 체크리스트

### 5.1 Task 정의서 완성도
- [ ] 헤더: 버전, 담당자, 생성일자, 메뉴 경로 완비
- [ ] 사용자 스토리: "As a... I want to... so that..." 형식 준수
- [ ] 인수 조건: 체크리스트 형태 검증 가능 조건 나열
- [ ] 다이어그램: Requirement/Sequence/C4/ERD 포함 및 문법 오류 없음
- [ ] API 명세: 테이블 형식 엔드포인트 정보 완전 정의
- [ ] 개발 단계: 프론트엔드 → 백엔드 순서 명확 정의

### 5.2 요구사항 반영 확인
- [ ] 모든 기능 요구사항 반영
- [ ] 비즈니스 규칙 및 정책 누락 없음
- [ ] 예외 처리 시나리오 완전 정의
- [ ] 데이터 모델 요구사항 반영
```

## 사용 가이드

1. `/gen-task` 실행 시 이 Skill이 자동 로드됨
2. 사용자에게 시스템명(`{SYSTEM_NAME}`)과 시스템 전체명(`{SYSTEM_FULL_NAME}`) 질의
3. 요구사항 문서를 기반으로 1단계(데이터 모델 파악) → 2단계(Task 작성) → 3단계(검증) 순서로 진행
4. 모든 Mermaid 다이어그램은 문법 오류 없이 렌더링 가능해야 함

## 체크리스트

- [ ] 8개 섹션이 모두 포함되었는가?
- [ ] Mermaid 다이어그램이 4종(Requirement, Sequence, C4, ERD) 포함되었는가?
- [ ] API 설계가 Map<String, Object> 기반인가?
- [ ] 파일명 규칙이 준수되었는가?
- [ ] Why → What → How 구조가 반영되었는가?
