---
description: "UI 스캐폴딩 | Lab 2: Frontend Scaffolding & Component Setup"
---

# /gen-ui

## 개요
Task 분석 산출물을 기반으로 프론트엔드 초기 구조를 자동 생성합니다.
Vue 3 CDN 환경에서 페이지, 컴포넌트, 라우팅을 일괄 구성합니다.

> ⚠️ **목적 분리**: `/gen-ui`는 **파일 스캐폴딩** (빈 껍데기 생성) 전용입니다.
> 실제 UI 로직 구현은 `/dev-fe`에서 수행합니다.
> - `/gen-ui` → 디렉토리 구조 + 빈 템플릿 파일 생성
> - `/dev-fe` → 비즈니스 로직, 이벤트 바인딩, API 연동 구현

## 입력
- /gen-task 산출물 경로 또는 기능명
- 예: "task-입고관리.md" 또는 "입고 관리"

## 워크플로우
1. **초기 파일 구조 생성**
   - Skills: fe-scaffold
   - `frontend/views/{module}/pages/` 디렉토리 생성
   - `frontend/views/{module}/components/` 디렉토리 생성

2. **페이지/컴포넌트 스캐폴딩**
   - Skills: fe-component
   - CRUD 페이지 템플릿 생성 (List/Create/Edit) - `.js` 확장자
   - 재사용 컴포넌트 스켈레톤 (Form, Table, Dialog) - `.js` 확장자
   - 모든 파일은 `const { ... } = Vue;` 전역 변수 방식 사용

3. **라우팅 등록**
   - `frontend/router.js`에 신규 모듈 라우트 추가 (중앙 관리)
   - 각 페이지에 path, component 매핑
   - 동적 import: `() => import('./views/{module}/pages/List.js')`

4. **메뉴 등록**
   - `frontend/sidebar.js`에 모듈 메뉴 추가 (필수)
   - 계층 구조 반영

## 산출물
- **frontend/views/{module}/**
  - pages/
    - List.js (목록 페이지)
    - Create.js (생성 페이지)
    - Edit.js (편집 페이지)
  - components/
    - {Module}Form.js
    - {Module}Table.js
    - {Module}Dialog.js
- **frontend/router.js** (라우트 추가)
- **frontend/sidebar.js** (메뉴 추가)

> 모든 산출물은 **스켈레톤 상태** (placeholder 콘텐츠)로 생성됩니다.
> 실제 구현은 `/dev-fe` 명령어로 수행하세요.

## /gen-ui vs /dev-fe 차이점

| 구분 | /gen-ui (스캐폴딩) | /dev-fe (구현) |
|------|-------------------|---------------|
| **목적** | 파일 구조 생성 | 비즈니스 로직 구현 |
| **산출물** | 빈 템플릿, 디렉토리 | 완성된 페이지, 컴포넌트 |
| **Skills** | fe-scaffold, fe-component | fe-composable-crud, fe-page-crud |
| **실행 시점** | Task 분석 직후 | BE API 완성 후 |
| **의존성** | /gen-task 산출물 | /gen-ui 산출물 + BE API |

## 체크포인트
- [ ] 모든 필수 페이지가 생성되었는가? (List.js, Create.js, Edit.js)
- [ ] 페이지 위치: `views/{module}/pages/` 구조 준수
- [ ] 파일 확장자: `.js` 사용 (`.html` 금지)
- [ ] CDN 라이브러리: `const { ... } = Vue;` 전역 변수 사용
- [ ] 라우트: `frontend/router.js`에 등록되었는가?
- [ ] 메뉴: `frontend/sidebar.js`에 등록되었는가?
- [ ] Element Plus 컴포넌트가 CDN 기반인가?
