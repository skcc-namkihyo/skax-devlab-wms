---
description: "MCP Memory 지식 그래프 생성 | Generate knowledge graph entities for MCP Memory"
---

# /gen-memory

## 개요
프로젝트 구조와 도메인 정보를 MCP Memory 지식 그래프로 변환합니다.
Rules의 `project.init.mdc`에 정의된 Entity/Relation 타입을 기반으로 생성합니다.

## 입력
- 프로젝트 변수 (project.init.mdc 참조)
- 또는: 기존 프로젝트 파일 자동 스캔

## 워크플로우

1. **프로젝트 변수 수집**
   - PROJECT_NAME, BASE_PACKAGE, DB_PREFIX 등 9개 변수
   - Rules: project.init.mdc 참조

2. **Entity 생성**
   - Project Entity: 프로젝트 메타 정보
   - Module Entity: 각 도메인 모듈 (입고, 출고, 재고 등)
   - API Entity: REST 엔드포인트 목록
   - Table Entity: DB 테이블 목록

3. **Relation 생성**
   - Project → has_module → Module
   - Module → has_api → API
   - Module → has_table → Table
   - API → uses_table → Table

4. **MCP Memory 호출**
   - `create_entities` / `create_relations` API 실행
   - 결과 검증

## 산출물
- MCP Memory에 지식 그래프 저장 (파일 산출물 없음)
- 콘솔에 생성된 Entity/Relation 요약 출력

## 체크포인트
- [ ] 모든 프로젝트 변수가 수집되었는가?
- [ ] Entity 타입이 project.init.mdc 정의와 일치하는가?
- [ ] Relation이 모듈 간 의존성을 정확히 반영하는가?
- [ ] MCP Memory API 호출이 성공했는가?
