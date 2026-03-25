---
description: "구현: 기존 코드 변경 구현 | Production: Code Changes & Modifications"
---

# /implement

## 개요
기존 코드베이스를 변경하여 새로운 기능을 구현합니다.
/impact 분석을 기반으로 DB → BE → FE 순서로 진행합니다.
각 변경점은 개별 승인을 받습니다 (🔴 파일럿 기능).

## 입력
- /impact 산출물 (impact-{feature}-{date}.md)
- 또는 변경 사항 설명

## 워크플로우

### Step 1: 변경 계획 확인
- /impact 산출물 로드
- 영향받는 파일 목록 검토
- 각 계층별 변경점 정리
- 🔴 **개별 승인 요청**: 사용자에게 각 변경점 확인 후 진행

### Step 2: DB 계층 변경
- DDL: 테이블 구조 변경 (ALTER TABLE)
- 마이그레이션 스크립트 생성 (선택)
- 데이터 마이그레이션 (기존 데이터 유지)

### Step 3: BE 계층 변경 (순차)
- **Step 3a: Mapper XML 수정**
  - SELECT 쿼리 업데이트 (새로운 컬럼 포함)
  - INSERT 쿼리 업데이트
  - UPDATE 쿼리 업데이트
  - CDATA 이스케이프 검증

- **Step 3b: Service 수정**
  - 메서드 시그니처 변경 (필요시)
  - 비즈니스 로직 추가/수정
  - 유효성 검사 로직 추가

- **Step 3c: Controller 수정**
  - 요청/응답 DTO 업데이트
  - 엔드포인트 추가 (필요시)
  - HTTP 상태 코드 검토

### Step 4: FE 계층 변경 (순차)
- **Step 4a: Composable 수정**
  - useApi() 훅 업데이트
  - 새로운 필드 처리

- **Step 4b: Page/Component 수정**
  - 폼 필드 추가
  - 테이블 컬럼 추가
  - 유효성 규칙 추가

- **Step 4c: 라우팅 등록** (신규 페이지만)
  - main.js 업데이트

### Step 5: 변경 요약
- git diff 수집
- 변경 사항 문서화
- 시각화 (전후 비교)

## 산출물
- **변경된 파일들**
  - backend/**/*.java
  - backend/**/mapper/**/*.xml
  - frontend/**/*.js
  - frontend/**/*.html
  - database/ddl/**/*.sql

- **변경 요약 리포트**
  - implement-{feature}-summary.md
  - git diff (선택)

## 체크포인트
- [ ] DB 변경이 모두 반영되었는가?
- [ ] Mapper XML이 새로운 필드를 포함하는가?
- [ ] Service 비즈니스 로직이 정확한가?
- [ ] Controller가 Service를 위임하는가?
- [ ] FE Composable이 API와 일치하는가?
- [ ] 폼 유효성이 구현되었는가?
- [ ] 에러 처리가 모든 계층에 있는가?
- [ ] 기존 기능이 깨지지 않았는가? (회귀)

## 주의사항
- 기존 코드 수정 전에 백업 추천 (git commit)
- 각 계층 변경 후 즉시 테스트 추천
- DELETE/TRUNCATE 변경은 특히 주의 (데이터 손실 위험)
