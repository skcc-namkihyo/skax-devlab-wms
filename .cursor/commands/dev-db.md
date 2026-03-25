---
description: "DB 개발 완성 | Lab 5: Database Schema & Queries"
---

# /dev-db

## 개요
데이터베이스 스키마와 기본 쿼리를 설계합니다.
PostgreSQL Neon Free Tier에서 wms 스키마, twms_ 접두어로 관리됩니다.

## 입력
- 엔티티명 (예: "Inbound", "Outbound")
- 필드 목록 (예: "id, code, quantity, warehouse_id")

## 워크플로우

### Step 1: DDL (Data Definition Language)
- Skills: db-ddl
- database/ddl/{entity}.sql 생성
- 테이블명: twms_{entity_lower} (예: twms_inbound)
- 스키마: wms
- 필드: id(PK), business 필드, 타임스탬프(created_at, updated_at)
- 제약조건: NOT NULL, UNIQUE, FOREIGN KEY
- 인덱스: 조회 성능을 위한 복합 인덱스

### Step 2: 기본 DML (Data Manipulation Language)
- Skills: be-sql-select, be-sql-write
- SELECT: 목록, 상세, 검색
- INSERT: 단건, 배치
- UPDATE: 조건부 업데이트
- DELETE: 안전한 삭제 (WHERE 필수)

### Step 3: 고급 SQL (Optional)
- Skills: db-advanced-sql
- JOIN, GROUP BY, HAVING
- 윈도우 함수, CTE (Common Table Expression)
- 성능 최적화 (EXPLAIN ANALYZE)

## 산출물
- **database/ddl/{entity}.sql**
  - CREATE TABLE 문
  - 인덱스 정의
  - 주석

- **backend/src/main/resources/mapper/{module}Mapper.xml**
  - SELECT, INSERT, UPDATE, DELETE 쿼리

## 체크포인트
- [ ] 테이블명이 twms_ 접두어를 사용하는가?
- [ ] 스키마가 wms인가?
- [ ] PK, FK가 명확한가?
- [ ] 타임스탬프 필드가 있는가?
- [ ] SQL이 CDATA로 안전하게 이스케이프되었는가?
- [ ] WHERE 절이 필수 쿼리(UPDATE, DELETE)에 있는가?
