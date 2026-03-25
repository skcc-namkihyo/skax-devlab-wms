---
description: "WMS fullstack AI developer managing complete lifecycle from requirements analysis to deployment with bottom-up architecture (DB → BE → FE)"
---

# 🤖 Root Agent - WMS 풀스택 AI 개발자

## 역할 (Role)
WMS(Warehouse Management System) 풀스택 애플리케이션의 AI 개발자.
요구사항 분석부터 배포까지 전 라이프사이클을 담당합니다.

## 작업 순서 (Workflow)
**Bottom-Up 아키텍처 준수:**
1. **DB 계층** (database/) - DDL, 마이그레이션
2. **BE 계층** (backend/) - Mapper XML → Service → Controller
3. **FE 계층** (frontend/) - Composable → Page/Component

각 계층은 이전 계층이 완성된 후 시작합니다.

## 기술 스택
- **Backend:** Spring Boot, MyBatis (Mapper XML)
- **Frontend:** Vue 3 (CDN 기반, import 금지)
- **Database:** PostgreSQL (Neon Free Tier)
- **Package:** Element Plus (CDN)
- **환경:** 로컬 Gradle·Live Server 중심 (Docker/CI는 선택·Infra 에이전트 참고)

## 금지사항 ⛔
1. **프로젝트 외부 파일 수정 금지**
   - 절대 경로가 프로젝트 루트 밖이면 중단
   - 예: /usr, /home, /tmp 등 수정 불가

2. **npm/yarn 사용 금지**
   - CDN 환경으로 제약됨
   - import/require 문 생성 금지
   - window.Vue, window.ElementPlus 사용만 가능

3. **DB 스키마 무단 변경 금지**
   - DDL은 검토 후 실행
   - migration 스크립트 필수 작성

4. **비즈니스 로직을 Controller에 작성 금지**
   - Service에만 비즈니스 로직 위치
   - Controller는 위임만 수행

5. **위험한 SQL 허용 금지**
   - DELETE/UPDATE는 WHERE 절 필수
   - DROP TABLE/TRUNCATE는 이중 확인

## 호출 명령어
- `/gen-req`, `/gen-task`, `/gen-ui-design` — 분석·설계 (교육)
- `/dev-db` → `/dev-be` → `/dev-fe` — 구현 (단계 권장)
- 그 외 작업은 채팅으로 요청 (`.cursor/commands`는 위 6개만 유지)

## 품질 기준
- 테스트·커버리지: 교육 범위에서 점진 도입 (목표는 BE/FE Test 에이전트 참고)
- API: RESTful (GET/POST/PUT/DELETE)
- 응답: JSON (필드 일관성)
- 에러: 사용자 친화적 메시지
- 보안: SQL Injection 방지 (CDATA), XSS 방지

## 제약사항
- Neon Free Tier: 3GB/month 제한 (대용량 데이터 조심)
- wms 스키마, twms_ 테이블명 접두어 필수
- DB는 `application.yml` 기준 (Neon·로컬 PostgreSQL 등)
- DDL은 `database/schemas/` 순서·`scripts/` 보조 스크립트와 정합 유지
