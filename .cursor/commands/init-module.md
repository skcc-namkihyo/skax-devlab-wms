---
description: "풀스택 초기화 (매크로) | Lab 7: Full-Stack Module Initialization"
---

# /init-module

## 개요
풀스택 CRUD 모듈을 한 번에 초기화합니다.
10개의 Skills를 순차 실행하여 /dev-db → /dev-be → /dev-fe를 자동화합니다.
교육용 매크로 명령어로, 각 단계는 개별 명령어로도 실행 가능합니다.

## 입력
- 모듈명 (예: "입고 관리")
- 엔티티명 (예: "Inbound")
- 필드 목록 (예: "id, code, quantity, warehouse_id, created_at, updated_at")

## 워크플로우

### Phase 1: Database (Step 1-2)
- /dev-db 실행
- Skills: db-ddl
- 산출물: database/ddl/{entity}.sql

### Phase 2: Backend (Step 3-5)
- /dev-be 실행
- Skills: be-sql-select, be-sql-write, be-service-mapper, be-controller, be-map-util
- 산출물:
  - backend/src/main/resources/mapper/{module}Mapper.xml
  - backend/src/main/java/service/{Module}Service.java
  - backend/src/main/java/controller/{Module}Controller.java

### Phase 3: Frontend (Step 6-10)
- /dev-fe 실행 (신규 뷰는 Skill **fe-scaffold**로 스켈레톤을 먼저 두고, 동일 흐름에서 구현 완료)
- Skills: fe-scaffold, fe-component, fe-composable-util, fe-composable-crud, fe-page-crud
- 산출물:
  - frontend/views/{module}/ (전체 구조)
  - frontend/composables/use{Module}.js
  - 모든 페이지 완성

### Phase 4: Integration (Step 11)
- /integrate 실행
- 최종 검증 리포트

## 산출물
모든 계층의 완성된 모듈:
- **database/ddl/{entity}.sql**
- **backend/** (Mapper, Service, Controller)
- **frontend/** (Views, Composables, Pages, Components)
- **integration-{module}-report.md** (검증 리포트)

## 체크포인트
- [ ] 모든 파일이 생성되었는가?
- [ ] 각 계층이 독립적으로 검증되었는가?
- [ ] API 통합이 성공했는가?
- [ ] 프로젝트 구조가 일관성 있는가?
- [ ] 보안 및 성능 요구사항이 만족되었는가?

## 주의사항
- 대규모 모듈은 단계별 명령어 (/dev-db, /dev-be, /dev-fe)를 권장합니다.
- 각 단계마다 검증한 후 다음 단계로 진행하세요.
