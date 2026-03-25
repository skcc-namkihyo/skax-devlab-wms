---
description: "BE 개발 완성 | Lab 4: Backend Implementation (Bottom-Up)"
---

# /dev-be

## 개요
백엔드 모듈을 완성합니다. 아키텍처: Mapper XML → Service → Controller (Bottom-Up).
비즈니스 로직은 Service에만 위치하며, Controller는 위임만 수행합니다.

## 입력
- 기능명 (예: "입고 관리")
- DB 테이블명 (예: "twms_inbound")
- 엔티티명 (자동 생성: "Inbound")

## 워크플로우

### Step 0: 공통 모듈 확인 (최초 1회)
- Skills: **be-common-module**
- 공통 모듈(config/, common/, auth/) 존재 여부 확인
- 없는 경우 be-common-module Skill을 실행하여 13개 파일 생성
- 있는 경우 이 단계 Skip

### Step 1: Mapper XML 작성
- Skills: be-sql-select, be-sql-write, be-map-util
- backend/src/main/resources/mapper/{module}Mapper.xml
- SELECT: 목록 조회, 상세 조회 (WHERE 절 포함)
- INSERT: 단건, 배치 입력
- UPDATE: 조건부 업데이트
- DELETE: 안전한 삭제 (WHERE 필수)
- 모든 < > & 는 CDATA로 이스케이프

### Step 2: Service 구현
- Skills: be-service-mapper
- backend/src/main/java/service/{Module}Service.java
- @Service 어노테이션
- 의존성: Mapper 주입 (@Autowired)
- 메서드: findAll(), findById(), create(), update(), delete()
- 모든 비즈니스 로직을 여기에 작성 (검증, 계산, 트랜잭션)

### Step 3: Controller 구현
- Skills: be-controller
- backend/src/main/java/controller/{Module}Controller.java
- @RestController, @RequestMapping("/api/{module}")
- Service 메서드 위임만 수행
- 요청/응답 DTO 처리
- HTTP 상태 코드 반환 (200, 201, 400, 404, 500)

## 산출물
- **backend/src/main/resources/mapper/{module}Mapper.xml**
- **backend/src/main/java/service/{Module}Service.java**
- **backend/src/main/java/controller/{Module}Controller.java**
- **backend/src/main/java/model/{Module}.java** (엔티티, 선택사항)

## 체크포인트
- [ ] Mapper XML에 모든 CRUD 쿼리가 있는가?
- [ ] SQL이 안전한가? (DELETE/UPDATE는 WHERE 필수)
- [ ] 비즈니스 로직이 Service에만 있는가?
- [ ] Controller가 Service 위임만 하는가?
- [ ] API 엔드포인트가 RESTful한가?
- [ ] 에러 처리가 있는가?
