---
description: "구현: 신규 모듈 초기 구성 | Production: New Module Scaffolding with Integration"
---

# /scaffold

## 개요
신규 모듈의 풀스택 초기 구조를 생성하고 기존 코드와 통합합니다.
/init-module의 실무 확장으로, 라우팅, 메뉴, 공통모듈 통합을 포함합니다.

## 입력
- 모듈명 (예: "입고 관리")
- 엔티티명 (예: "Inbound")
- 필드 목록
- 메뉴 위치 (예: "수입 관리 > 입고")

## 워크플로우

### Step 1: 모듈 정의
- 모듈 ID, 경로 (snake_case)
- 메뉴 계층 정의
- 권한 설정 (선택)

### Step 2: 풀스택 생성
- /init-module 실행
- 모든 DB/BE/FE 파일 생성

### Step 3: 기존 코드와 통합

#### 3a: 라우팅 통합 (FE)
- `frontend/router.js` 업데이트 (중앙 라우팅 파일)
- routes 배열에 신규 모듈 라우트 추가

**예시:**
```javascript
// frontend/router.js
routes: [
  // ... 기존 라우트
  { path: '/inbound/list', component: () => import('./views/inbound/pages/List.js'), meta: { title: '입고 관리' } },
  { path: '/inbound/create', component: () => import('./views/inbound/pages/Create.js') },
  { path: '/inbound/edit/:id?', component: () => import('./views/inbound/pages/Edit.js') }
]
```

#### 3b: 메뉴 통합 (FE)
- `frontend/sidebar.js` 업데이트 (신규 모듈 메뉴 필수 등록)
- 메뉴 항목 추가 (계층 구조)

**예시:**
```javascript
{
  label: '수입 관리',
  icon: 'el-icon-download',
  children: [
    { label: '입고 관리', path: '/inbound' }
  ]
}
```

#### 3c: 공통모듈 통합 (BE/FE)
- 기존 인증/권한 설정 확인
- 로깅, 에러 처리 표준 적용
- 공통 DTO 재사용

#### 3d: 데이터베이스 스키마 반영
- database/ddl/init.sql에 신규 테이블 추가
- 또는 별도 migration 스크립트 생성

### Step 4: 통합 검증
- /integrate 실행
- 라우팅 동작 확인
- 메뉴 클릭 검증
- API 호출 검증

## 산출물
- **All files from /init-module**
- **신규 생성 파일:**
  - `frontend/views/{module}/pages/List.js`
  - `frontend/views/{module}/pages/Create.js`
  - `frontend/views/{module}/pages/Edit.js`
  - `frontend/views/{module}/components/{Module}Form.js`
- **Updated files:**
  - `frontend/router.js` (라우트 추가)
  - `frontend/sidebar.js` (메뉴 추가)
  - `database/init.sql` (스키마)

- **Scaffold Report:**
  - scaffold-{module}-{date}.md
    - 생성된 파일 목록
    - 통합 확인 항목
    - 추가 설정 필요 사항

## 체크포인트
- [ ] 모든 풀스택 파일이 생성되었는가?
- [ ] 라우팅이 등록되었는가?
- [ ] 메뉴가 표시되는가?
- [ ] API 엔드포인트가 응답하는가?
- [ ] CRUD 기본 기능이 동작하는가?
- [ ] 기존 메뉴/라우팅이 깨지지 않았는가?
- [ ] 에러 메시지가 일관성 있는가?

## 주의사항
- 메뉴 순서는 sidebar.js에서 정의 순서 = 표시 순서
- 라우팅 path는 프로젝트 전체에서 unique해야 함
- 테이블명은 twms_ 접두어 필수 (데이터베이스 정책)
- 기존 API와 경로 충돌 확인 필수
