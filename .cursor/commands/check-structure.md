---
description: "프로젝트 구조 검증 | Validate project structure against conventions"
---

# /check-structure

## 개요
프로젝트의 파일 구조, 네이밍 컨벤션, 필수 파일 존재 여부를 검증합니다.
신규 모듈 추가 후 또는 코드 리뷰 전에 실행합니다.

## 입력
- 없음 (전체 프로젝트 스캔) 또는 모듈명 지정

## 워크플로우

1. **디렉토리 구조 검증**
   - `backend/src/main/java/` 필수 패키지 존재 확인
   - `frontend/views/` 모듈별 디렉토리 확인
   - `database/ddl/` DDL 파일 존재 확인

2. **네이밍 컨벤션 검증**
   - Backend: PascalCase 클래스명, camelCase 메서드명
   - Frontend: PascalCase 컴포넌트, camelCase 함수
   - Database: snake_case 테이블/컬럼, `twms_` 접두사
   - Mapper XML: `{module}Mapper.xml` 형식

3. **필수 파일 검증**
   - Controller ↔ Service ↔ Mapper XML 3-Layer 일치
   - Frontend pages/ ↔ components/ 매칭
   - DDL ↔ Mapper XML 테이블명 일치

4. **검증 리포트 생성**

## 산출물
- 콘솔 출력: PASS/FAIL 항목별 결과
- **`docs/04.review/structure-check-{date}.md`** (선택)

## 체크포인트
- [ ] 모든 모듈이 3-Layer 구조를 갖추고 있는가?
- [ ] 네이밍 컨벤션 위반이 없는가?
- [ ] 필수 파일 누락이 없는가?
- [ ] FE-BE API 경로가 일치하는가?
