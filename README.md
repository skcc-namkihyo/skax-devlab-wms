# WMS 교육 프로젝트 — Cursor 워크플로우

Cursor **Commands**(`/.cursor/commands/*.md`)만 순서대로 실행하면 요구사항 → Task → UI 설계 → DB → 백엔드 → 프론트엔드까지 이어갈 수 있습니다. 

## 기술 스택 (요약)

| 구분 | 스택 |
|------|------|
| 백엔드 | Java 17, Spring Boot 3.5.4, MyBatis 3.x, `Map<String, Object>` (DTO/VO 없음) |
| 보안 | Spring Security + JWT |
| DB | PostgreSQL, 스키마 `wms`, 테이블 접두 `twms_` |
| 프론트 | Vue 3(CDN), Element Plus, Tailwind, Axios — `frontend/` |
| 실행 | Backend: `./gradlew bootRun` / Frontend: Live Server 등 `http://localhost:3000` |

자세한 규칙은 **`.cursor/rules/project.common.mdc`** 및 하위 규칙 파일을 참고합니다.

## 전체 워크플로우

```mermaid
graph LR
    R["/gen-req"] --> T["/gen-task"]
    T --> U["/gen-ui-design"]
    U --> D["/dev-db"]
    D --> B["/dev-be"]
    B --> F["/dev-fe"]
```

- **`/gen-req`**: (선택) RFP·요구사항 정의서 정리  
- **`/gen-task`**: Task 정의서  
- **`/gen-ui-design`**: UI HTML + Mock JSON  
- **`/dev-db`**: DDL·쿼리 (`database/` 등) — **BE 전에 두는 것을 권장**  
- **`/dev-be`**: Mapper XML → Service → Controller  
- **`/dev-fe`**: 페이지·Composable·**API 연동** (Mock → 실제 엔드포인트)

통합 검증은 전용 Command가 없습니다. 필요 시 채팅으로 요청하거나 `/dev-fe` 단계에서 연동을 마칩니다.

---

## 단계별 실행 가이드

각 단계는 Cursor 채팅에서 **슬래시 커맨드**를 입력하고, 해당 `.md`에 적힌 **입력·산출물**을 맞춥니다.

| 순서 | Command | 주요 입력 | 주요 산출물 |
|------|---------|-----------|-------------|
| 1 | `/gen-req` | `docs/01.analysis/01.rfp/*_prd.md` 등 | 요구사항 정의서 |
| 2 | `/gen-task` | 요구사항·기능 범위 | `docs/02.design/01.tasks/*.task.md` |
| 3 | `/gen-ui-design` | Task 파일 | `docs/02.design/02.ui/**` HTML, `common/api/v1/*.json` Mock |
| 4 | `/dev-db` | 엔티티·필드 | `database/schemas/`·`database/scripts/` (Command에 따라 `database/ddl/` 신규 생성 가능) |
| 5 | `/dev-be` | Task, API 표, 테이블명 | `backend/src/main/java/com/execnt/**`, `mapper/*.xml` |
| 6 | `/dev-fe` | Task, UI HTML, Mock | `frontend/views/**`, `composables/**` 등 |

### API 응답 규약

- 형식: `{ "result_code", "result_message", "data" }`  
- 성공: `result_code`가 `I`로 시작  
- 실패: `result_code`가 `E`로 시작  
- `success` 필드는 사용하지 않습니다.

### Rules 빠른 링크

| 용도 | 파일 |
|------|------|
| 공통·Skills 라우팅 | `.cursor/rules/project.common.mdc` |
| 백엔드 | `.cursor/rules/backend.dev.mdc`, `backend.db.naming.mdc`, `backend.db.sql-pattern.mdc`, `postgresql.mdc` |
| 프론트 | `.cursor/rules/frontend.dev.mdc`, `frontend.ui-design.mdc`, `frontend.component.mdc` |
| DB 명명 표준 | `.cursor/rules/db.naming-standard.mdc` |

UI 설계 시 추가로 **`.cursor/commands/gen-ui-design.md`** 절차를 따릅니다.

---

## 프로젝트·패키지 구조 (현행)

### 저장소 최상위

```
skax-devlab-wms/
├── .cursor/
│   ├── commands/          # 슬래시 커맨드 6종
│   ├── rules/             # *.mdc
│   ├── skills/            # SKILL.md
│   └── GUIDE.md
├── backend/               # Gradle (`group`: com.carfix)
├── frontend/              # Vue 3 CDN
├── database/
│   ├── schemas/           # 번호 순 공식 DDL·함수·권한 등
│   ├── scripts/           # 보조 DDL·시드·쉘
│   └── docs/guides/       # DB 설계·운영 가이드
└── docs/
    ├── 01.analysis/
    └── 02.design/
        ├── 01.tasks/
        └── 02.ui/         # 에픽별 HTML, common/api/v1 Mock JSON
```

### 백엔드 Java (`com.execnt`)

Gradle **아티팩트 그룹**은 `com.carfix`이고, **소스 루트 패키지**는 `com.execnt`입니다.

```
com.execnt
├── WmsApplication.java
├── auth
│   ├── filter      # JwtAuthenticationFilter
│   └── util          # JwtUtil
├── config            # SecurityConfig, SwaggerConfig, MessageSourceConfig
├── common
│   ├── controller    # HealthController, DbHealthController
│   ├── exception     # BizException, GlobalExceptionHandler
│   ├── openapi       # OpenApiExamples (Swagger 예시)
│   └── utils         # ResponseUtil
└── wms
    ├── controller    # REST API (인증·배치·이력·화면접속 등)
    ├── service
    └── mapper          # MyBatis Mapper 인터페이스
```

**리소스** (`backend/src/main/resources/`)

| 경로 | 용도 |
|------|------|
| `application.yml` | JDBC, MyBatis, JWT 등 설정 |
| `mapper/*.xml` | MyBatis SQL (인터페이스 네임스페이스와 동일 계층명 권장) |
| `messages/messages.properties` | 메시지 소스 |

### 프론트엔드 (`frontend/`)

| 경로 | 용도 |
|------|------|
| `index.html`, `app.js`, `router.js`, `sidebar.js`, `store.js`, `api.js` | 앱 진입·라우팅·상태·API 베이스 |
| `composables/` | `useApi`, `useAuth`, `useLogs` 등 |
| `components/layout/` | `AppLayout`, `SidebarMenu` |
| `views/Home.js`, `views/auth/Login.js` | 홈·로그인 |
| `views/logs/pages/` | 목록·등록·수정 페이지 (`List`, `Create`, `Edit`) |
| `views/logs/components/` | `LogsTable`, `LogsForm`, `LogsDialog` |

신규 화면은 보통 `views/{도메인}/pages/`·`components/`를 추가하고 `router.js`·`sidebar.js`에 등록합니다.

---

## 로컬 실행

**Backend**

```bash
cd backend
./gradlew bootRun
```

**Frontend**: VS Code Live Server 등으로 `frontend/index.html` 제공 (포트는 팀 기준, 예: 3000).

**DB**: `backend/src/main/resources/application.yml`의 JDBC URL·계정을 환경에 맞게 수정합니다. 스키마는 `database/schemas/README.md` 순서를 참고해 적용합니다.

---

## Command 원문

- [gen-req](.cursor/commands/gen-req.md) · [gen-task](.cursor/commands/gen-task.md) · [gen-ui-design](.cursor/commands/gen-ui-design.md)  
- [dev-db](.cursor/commands/dev-db.md) · [dev-be](.cursor/commands/dev-be.md) · [dev-fe](.cursor/commands/dev-fe.md)

## 참고: 빌드·기동 스크립트

**백엔드** (JDK 17, 저장소 루트 기준)

```bash
cd backend
./gradlew build          # 컴파일·테스트·JAR 생성
./gradlew bootRun        # 개발 기동 (기본 http://localhost:8080)
```

**프론트엔드** (`frontend/index.html`을 정적 서버로 제공; API는 위 백엔드 8080과 맞출 것)

```bash
cd frontend
# VS Code/Cursor: Live Server로 index.html 열기 (포트 3000 또는 5500 — SecurityConfig CORS 허용)
# 또는 터미널:
python3 -m http.server 3000
# 브라우저: http://localhost:3000
```


> 교육 실습에 사용하는 **Azure Database for PostgreSQL** DB 접속 정보.
> 

> ⚠️ 전원 동일 DB 계정 사용. 개인별 스키마 분리 없음.
> 

---

## 공통 접속 정보

| 항목 | 값 |
| --- | --- |
| Host | `skax-dev-db1.postgres.database.azure.com` |
| Port | `5432` |
| Database | `postgres` |
| SSL | **required** (Azure 기본 정책) |

---

## DB 계정 정보

| 구분 | User | Password | 용도 |
| --- | --- | --- | --- |
| 🖥️ 서버용 | `tms_developer` | `TmsDeveloper@2026` | application.yml (Backend 연동) |
| 👤 개인용 | `dba01` | `SKax2025!` | DBeaver / psql (DDL+DML) |

---

## Connection String

| 용도 | Connection String |
| --- | --- |
| 서버용 (application.yml) | `jdbc:postgresql://skax-dev-db1.postgres.database.azure.com:5432/postgres` |
| 서버용 (일반) | `postgresql://tms_developer:TmsDeveloper@2026@skax-dev-db1.postgres.database.azure.com:5432/postgres?sslmode=require` |
| 개인용 (DBeaver) | `postgresql://dba01:SKax2025!@skax-dev-db1.postgres.database.azure.com:5432/postgres?sslmode=require` |

---

## application.yml 설정

```yaml
spring:
  datasource:
    driver-class-name: org.postgresql.Driver
    url: jdbc:postgresql://skax-dev-db1.postgres.database.azure.com:5432/postgres
    username: tms_developer
    password: TmsDeveloper@2026
```

---

## DBeaver 설정 순서

1. DBeaver 실행 → **Database** → **New Database Connection**
2. **PostgreSQL** 선택 → Next
3. 접속 정보 입력:

| 필드 | 값 |
| --- | --- |
| Host | `skax-dev-db1.postgres.database.azure.com` |
| Port | `5432` |
| Database | `postgres` |
| Username | `dba01` |
| Password | `SKax2025!` |
1. **SSL** 탭 → ✅ **Use SSL** 체크, SSL Mode: `require`
2. **Test Connection** 클릭 → **Connected** 확인
3. **Finish**

---

## 접속 확인 테스트 쿼리

### 1. 데이터베이스 접속 확인

```sql
SELECT current_database(), current_user, version();
-- 기대 결과: postgres / dba01 / PostgreSQL 버전 정보
```

### 2. 스키마 목록 확인

```sql
SELECT schema_name FROM information_schema.schemata 
WHERE schema_name NOT IN ('pg_catalog', 'information_schema')
ORDER BY schema_name;
```

### 3. 테이블 목록 확인

```sql
SELECT table_schema, table_name FROM information_schema.tables 
WHERE table_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY table_schema, table_name;
```

---

## 주의사항

- ⚠️ **전원 동일 DB 공유** — 다른 교육생의 데이터를 삭제/변경하지 않도록 주의
- ⚠️ **DDL 작업 시** `dba01` 계정 사용 권장
- ⚠️ **Azure SSL 필수** — DB 연결이 안 되면 SSL 설정(`sslmode=require`)을 재확인
- ⚠️ **방화벽** — 사내 네트워크에서 Azure 5432 포트 접근이 차단될 수 있음 → 네트워크 담당자 확인
- 
**갱신**: 2026-03-27
