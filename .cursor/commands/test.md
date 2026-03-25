---
description: "검증: 테스트 작성 + 실행 | Production: Test Strategy & Execution"
---

# /test

## 개요
기능 테스트와 회귀 테스트를 체계적으로 작성하고 실행합니다.
/impact 분석을 기반으로 테스트 범위를 결정하며, BE(JUnit)와 FE(E2E) 테스트를 분업합니다.

## 입력
- /impact 산출물 (회귀 테스트 범위)
- 또는 모듈명

## 워크플로우

### Step 1: 테스트 범위 결정
- /impact 산출물 로드
- 영향받는 모듈 식별
- 우선순위별 테스트 순서 결정
  - P0: 변경된 기능
  - P1: 연관된 기능 (FK, 공유 로직)
  - P2: 기타 회귀 테스트

### Step 2: BE 테스트 작성 (BE Test Agent③)
- Skills: be-test
- 위치: backend/src/test/java/

**테스트 전략:**
- Unit Test: 각 Service 메서드 (Given-When-Then)
- Integration Test: Mapper + Service (실제 DB)
- Controller Test: HTTP 요청/응답

**예시:**
```java
@Test
void testCreateInbound() {
  // Given: 입고 데이터
  InboundDTO dto = new InboundDTO("CODE-001", 100, 1);

  // When: 저장
  Inbound result = inboundService.create(dto);

  // Then: 검증
  assertThat(result.getId()).isNotNull();
  assertThat(result.getStatus()).isEqualTo("PENDING");
}

@Test
void testCreateInbound_InvalidQuantity() {
  // Given: 음수 수량
  InboundDTO dto = new InboundDTO("CODE-001", -100, 1);

  // When/Then: 예외 발생
  assertThrows(IllegalArgumentException.class,
    () -> inboundService.create(dto));
}
```

### Step 3: FE 테스트 작성 (FE Test Agent⑤)
- Skills: fe-test
- 위치: frontend/test/ 또는 .test.js
- 프레임워크: Cypress 또는 Playwright (E2E)

**테스트 전략:**
- E2E 시나리오: 실제 사용자 흐름
- 폼 검증: 필드 유효성
- API 통합: 백엔드 연동

**예시:**
```javascript
describe('Inbound Management', () => {
  it('should create new inbound', () => {
    cy.visit('/inbound');
    cy.get('button:contains("신규")').click();
    cy.get('input[name="code"]').type('CODE-001');
    cy.get('input[name="quantity"]').type('100');
    cy.get('button:contains("저장")').click();
    cy.get('table tbody').should('contain', 'CODE-001');
  });

  it('should reject invalid quantity', () => {
    cy.visit('/inbound/create');
    cy.get('input[name="quantity"]').type('-100');
    cy.get('button:contains("저장")').click();
    cy.get('.el-message--error').should('exist');
  });
});
```

### Step 4: 테스트 실행 및 분석
- 모든 테스트 실행
- 실패한 테스트 분석
- 커버리지 리포트 생성 (목표: >80%)
- 성능 테스트 (응답시간 확인)

### Step 5: 회귀 테스트
- P1, P2 테스트 실행
- 기존 기능 동작 확인
- 통합 시나리오 테스트

## 산출물
- **backend/src/test/java/{Module}ServiceTest.java**
  - Unit/Integration 테스트
  - 모든 메서드 커버
  - 정상/예외 케이스

- **frontend/test/{module}.e2e.js** or **{module}.cy.js**
  - E2E 시나리오
  - CRUD 테스트
  - 유효성 검사

- **test-report-{date}.md**
  - 테스트 결과 요약
  - 실패 항목 (있으면)
  - 커버리지 통계
  - 회귀 테스트 결과

## 체크포인트
- [ ] 모든 CRUD 기능이 테스트되는가?
- [ ] 경계값(boundary) 테스트가 있는가?
- [ ] 에러 케이스가 테스트되는가?
- [ ] E2E 시나리오가 실제 사용 흐름을 반영하는가?
- [ ] 테스트가 독립적인가? (의존성 없음)
- [ ] 회귀 테스트가 기존 기능을 모두 확인하는가?
- [ ] 커버리지가 80% 이상인가?
- [ ] 성능 요구사항을 만족하는가?

## 주의사항
- DB 테스트는 트랜잭션 롤백으로 격리 (테스트 후 데이터 정리)
- E2E 테스트는 독립 환경에서 실행 (staging/test DB 사용)
- API 모킹 고려 (FE 테스트 속도 향상)
