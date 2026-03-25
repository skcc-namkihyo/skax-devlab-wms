# 🚀 WMS 3-Layer Cursor Architecture - Setup Complete

## Summary
✅ All files created successfully for WMS full-stack development with Cursor education framework.

## 📁 File Structure

### Part 1: Commands (17 files)
Location: `.cursor/commands/`

**교육 Commands (7):**
1. ✅ `gen-task.md` - Lab 1: 요구사항 분석 + Task 분해
2. ✅ `gen-ui.md` - Lab 2: UI 스캐폴딩
3. ✅ `dev-fe.md` - Lab 3: FE 개발 완성
4. ✅ `dev-be.md` - Lab 4: BE 개발 완성
5. ✅ `dev-db.md` - Lab 5: DB 개발 완성
6. ✅ `integrate.md` - Lab 6: FE-BE 연동 검증
7. ✅ `init-module.md` - Lab 7: 풀스택 초기화 (매크로)

**실무 Commands (10):**
8. ✅ `analyze.md` - ①분석: 요구사항 분석
9. ✅ `impact.md` - ①분석: 변경 영향도 (★ 가장 빈번)
10. ✅ `design.md` - ②설계: 설계 문서 + API Spec
11. ✅ `plan.md` - ②설계: 작업 계획
12. ✅ `implement.md` - ③구현: 기존 코드 변경
13. ✅ `scaffold.md` - ③구현: 신규 모듈 초기 구성
14. ✅ `test.md` - ④검증: 테스트 작성 + 실행
15. ✅ `review.md` - ④검증: AI 셀프 코드 리뷰
16. ✅ `pr.md` - ⑤배포: PR 생성
17. ✅ `hotfix.md` - ⑤배포: 긴급 수정 (5분 목표)

### Part 2: AGENTS.md (7 files)

| 위치 | 파일 | 역할 |
|------|------|------|
| Root | `AGENTS.md` | 🤖 WMS 풀스택 AI 개발자 |
| `backend/` | `AGENTS.md` | 🤖 Spring Boot 전문가 (Bottom-Up) |
| `backend/test/` | `AGENTS.md` | 🤖 BE Test Engineer (파괴적 사고) |
| `frontend/` | `AGENTS.md` | 🤖 Vue 3 CDN 전문가 |
| `frontend/test/` | `AGENTS.md` | 🤖 FE Test Engineer (UI 검증) |
| `database/` | `AGENTS.md` | 🤖 PostgreSQL DBA |
| `infra/` | `AGENTS.md` | 🤖 DevOps 엔지니어 |

### Part 3: Hooks (5 scripts)
Location: `.cursor/hooks/`

**Configuration:**
- ✅ `hooks.json` - Hook 이벤트 정의 (5가지)

**Scripts:**
1. ✅ `check-java-style.sh` - Java 코드 스타일 검증
2. ✅ `check-sql-escape.sh` - SQL XML 이스케이프 검증
3. ✅ `check-vue-globals.sh` - Vue CDN 전역 변수 검증
4. ✅ `check-dangerous-sql.sh` - 위험 SQL 차단 (DROP/TRUNCATE)
5. ✅ `check-file-boundary.sh` - 프로젝트 외부 파일 수정 차단

## 🎯 Key Features

### 1. 3-Layer Architecture
```
Frontend (Vue 3 CDN) → Backend (Spring Boot) → Database (PostgreSQL)
         ↓ useApi()         ↓ Mapper XML        ↓ Neon
```

### 2. Workflow Automation
- **교육**: 요구사항 분석 → UI 스캐폴딩 → FE/BE/DB 개발 → 통합 검증
- **실무**: 분석 → 설계 → 구현 → 검증 → 배포 (5단계)

### 3. Quality Gates
- 자동 코드 리뷰 (5대 관점)
- 테스트 전략 (Unit/Integration/E2E)
- 보안 검사 (SQL Injection, XSS, File Boundary)

### 4. Emergency Response
- `/hotfix` - 5분 내 장애 대응
- 사후 처리 (24시간 내 full review)

## 📋 Getting Started

### 1. Project Initialization
```bash
/init-module
Input: 모듈명, 엔티티명, 필드 목록
Output: 풀스택 CRUD 모듈
```

### 2. Existing Code Modification
```bash
/impact → /implement → /test → /pr
분석 → 구현 → 검증 → 배포
```

### 3. Code Review
```bash
/review
5가지 관점: 아키텍처, 보안, 성능, 가독성, 에러처리
심각도: 🔴(높음), 🟡(중간), 🟢(낮음)
```

## ⚙️ Configuration

### Database
- **DBMS**: PostgreSQL (Neon Free Tier)
- **Schema**: wms (고정)
- **Table Prefix**: twms_ (필수)
- **Constraint**: 3GB/month storage

### Frontend
- **Framework**: Vue 3 (CDN)
- **Package Manager**: Element Plus (CDN)
- **Import Policy**: 금지 (window 글로벌만)
- **Build Tool**: 없음 (CDN 기반)

### Backend
- **Framework**: Spring Boot
- **ORM**: MyBatis (Mapper XML)
- **Architecture**: Service → Controller (Bottom-Up)
- **SQL Policy**: CDATA 이스케이프, WHERE 필수

## 🛡️ Safety Guards

### Hooks (자동 검사)
| Event | Check | Action |
|-------|-------|--------|
| afterFileEdit | Java style | Report violations |
| afterFileEdit | SQL escape | Block unsafe XML |
| afterFileEdit | Vue globals | Block imports |
| beforeShellExecution | Dangerous SQL | Block DROP/TRUNCATE |
| preToolUse | File boundary | Block external files |

## 📚 Documentation

### Commands: 30-40 lines each
- 개요, 입력, 워크플로우, 산출물, 체크포인트
- 한글/영어 병기

### AGENTS: 20-30 lines each
- 역할, 아키텍처 원칙, 규칙, 금지사항
- 구체적 코드 예시 포함

### Hooks: Functional scripts
- 문제 감지 및 보고
- Exit codes: 0(pass), 1(fail)

## 🚀 Next Steps

1. **프로젝트 초기화**
   ```bash
   /init-module "입고 관리" "Inbound" "id, code, quantity, ..."
   ```

2. **기존 코드 수정**
   ```bash
   /impact "twms_inbound에 status 추가"
   /implement
   /test
   /pr
   ```

3. **코드 리뷰**
   ```bash
   /review
   ```

4. **긴급 대응**
   ```bash
   /hotfix "API 500 에러"
   ```

## 📞 Contact

- **Root Agent**: WMS 전체 조율
- **BE Agent**: Spring Boot 질문
- **FE Agent**: Vue 3 CDN 질문
- **DB Agent**: PostgreSQL 질문
- **Test Agents**: 테스트 전략

---

**Created**: 2026-03-18  
**Version**: 1.0  
**Status**: ✅ Complete
