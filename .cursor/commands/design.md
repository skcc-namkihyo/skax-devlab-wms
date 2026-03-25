---
description: "설계: 설계 문서 + 인터페이스 정의 | Production: System Design & API Specification"
---

# /design

## 개요
기능 요구사항을 기반으로 상세 설계 문서를 작성합니다.
아키텍처 결정, API 스펙, 시퀀스 다이어그램을 생성합니다.

## 입력
- /analyze 산출물 (analysis-{feature}.md)
- 또는 기능명 + 요구사항

## 워크플로우

### Step 1: 아키텍처 결정
- 엔티티 설계 (ER 다이어그램)
- 계층별 책임 정의 (DB/BE/FE)
- 데이터 흐름도 (Data Flow Diagram)
- 예외 처리 전략

### Step 2: API 스펙 정의
- 엔드포인트 설계 (RESTful)
  - HTTP 메서드 (GET, POST, PUT, DELETE)
  - URL 경로 규칙 (/api/{module}/{resource})
  - 요청/응답 스키마 (JSON)
- 에러 응답 정의 (4xx, 5xx)
- 페이징, 필터링 규칙

**예시:**
```
GET /api/inbound
요청: ?page=1&size=10&status=PENDING
응답:
{
  "data": [...],
  "total": 100,
  "page": 1,
  "pageSize": 10
}

POST /api/inbound
요청: { code, quantity, warehouseId }
응답: { id, code, quantity, status, createdAt }
에러: 400 (Invalid input), 409 (Conflict)
```

### Step 3: 시퀀스 다이어그램
- 주요 사용 사례 (Use Case)
  - 조회 시퀀스 (FE → BE → DB → FE)
  - 생성 시퀀스 (폼 검증 → API → DB → 목록 새로고침)
  - 수정/삭제 시퀀스
- Mermaid 또는 PlantUML 다이어그램

### Step 4: 인터페이스 정의
- DB 스키마 (테이블, 컬럼, FK)
- Service 인터페이스 (메서드 시그니처)
- FE Composable 인터페이스 (함수, 반환값)

### Step 5: 문서화
- design-{feature}.md 생성

## 산출물
- **design-{feature}.md**
  - 요구사항 요약
  - ER 다이어그램 (Mermaid)
  - API 스펙 (OpenAPI 3.0 or 테이블)
  - 시퀀스 다이어그램 (Mermaid)
  - 에러 응답 매트릭스
  - 제약조건 및 가정

## 체크포인트
- [ ] ER 다이어그램이 정규화되었는가?
- [ ] API 엔드포인트가 RESTful한가?
- [ ] 요청/응답 스키마가 명확한가?
- [ ] 시퀀스 다이어그램이 예외 처리를 포함하는가?
- [ ] 에러 응답이 정의되었는가?
- [ ] 계층 간 인터페이스가 명확한가?
