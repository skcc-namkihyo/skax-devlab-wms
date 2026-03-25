---
description: "설계: 작업 계획 + Task 분해 | Production: Project Planning & Task Breakdown"
---

# /plan

## 개요
설계 산출물을 기반으로 구체적인 작업 계획을 수립합니다.
Task 분해, 의존성 그래프, 일정 계획을 생성합니다.

## 입력
- /design 또는 /analyze 산출물
- 프로젝트 제약 (리소스, 일정)

## 워크플로우

### Step 1: Task 분해 (WBS)
- DB 계층: DDL, 인덱스, 초기 데이터
- BE 계층: Mapper → Service → Controller
- FE 계층: Composable → Page → Component

**예시:**
```
입고 관리
├── DB (2일)
│   ├── twms_inbound DDL
│   ├── twms_inbound_item DDL
│   └── 인덱스 생성
├── BE (3일)
│   ├── InboundMapper XML
│   ├── InboundService 구현
│   └── InboundController 구현
└── FE (3일)
    ├── useInbound Composable
    ├── InboundList, Form, Dialog
    └── 라우팅 등록
```

### Step 2: 의존성 그래프
- 선행 작업 (Predecessor)
- 병렬 처리 가능 부분
- 임계 경로 (Critical Path)

**예시:**
```
DDL → Mapper → Service → Controller ↘
                              ↘
                              ↘ FE Composable → Pages
```

### Step 3: 일정 계획
- 각 Task 예상 시간 (T-shirt: XS/S/M/L/XL)
- 우선순위 (P0/P1/P2)
- 마일스톤 정의

### Step 4: 리스크 분석
- 기술적 리스크 (새로운 라이브러리, 복잡한 쿼리)
- 의존성 리스크 (외부 API 변경)
- 리소스 리스크 (인원 부족)
- 완화 전략

### Step 5: 문서화
- plan-{feature}.md 생성

## 산출물
- **plan-{feature}.md**
  - WBS 트리
  - Task 테이블 (Task ID, 설명, 예상시간, 우선순위)
  - 의존성 다이어그램 (Mermaid)
  - 임계 경로 표시
  - 마일스톤 타임라인
  - 리스크 레지스터

## 체크포인트
- [ ] 모든 Task가 SMART한가? (Specific, Measurable, Achievable, Relevant, Time-bound)
- [ ] 의존성이 정확한가?
- [ ] 임계 경로가 명확한가?
- [ ] 각 Task의 담당자가 명시되었는가?
- [ ] 리스크 완화 계획이 있는가?
- [ ] 총 일정이 현실적인가?

## 주의사항
- Bottom-Up 의존성: DB → BE → FE
- FE와 BE 설계는 병렬 수행 가능
- DDL 변경은 Mapper/Service 모두 영향 (우선 순위 높음)
