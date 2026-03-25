---
description: "배포: PR 생성 + 변경 요약 | Production: Pull Request & Code Submission"
---

# /pr

## 개요
코드 변경사항을 PR(Pull Request) 형식으로 정리하여 팀 리뷰를 위해 제출합니다.
git log, diff, 리뷰 코멘트를 종합하여 완벽한 PR을 생성합니다.

## 입력
- 기능명 또는 변경 사항 요약
- 선택: 리뷰어 목록

## 워크플로우

### Step 1: Commit 메시지 수집
- git log 조회
  ```
  git log main..HEAD --oneline
  ```
- 모든 커밋 메시지 추출
- 의미 있는 변경사항으로 그룹화

### Step 2: Diff 수집
- 파일별 diff 통계 추출
  ```
  git diff main...HEAD --stat
  ```
- 주요 변경 라인 식별

### Step 3: PR 제목 작성
- 형식: `[Type] 기능명 - 간단한 설명`
- Type: feat, fix, refactor, docs
- 예: `feat: 입고 관리 기능 추가 - CRUD API 및 UI 구현`

### Step 4: PR 본문 작성
PR 템플릿:
```markdown
## Why (왜?)
이 PR이 필요한 비즈니스 이유?

## What (무엇을?)
기술적 변경사항 요약

## How (어떻게?)
구현 방식, 주요 로직

## Impact (영향도)
- 영향받는 모듈
- API 변경 여부
- DB 마이그레이션 필요?

## Testing (테스트)
- [ ] Unit 테스트 작성
- [ ] E2E 테스트 완료
- [ ] 회귀 테스트 통과
- 테스트 커버리지: XX%

## Screenshots / Logs (증거)
- 변경 전/후 UI 스크린샷
- API 응답 로그
- 성능 벤치마크 (필요시)

## Checklist (확인)
- [ ] /review 리뷰 완료 (🔴 이슈 0)
- [ ] 커밋 메시지가 명확한가?
- [ ] 코드 스타일이 일관성 있는가?
- [ ] 보안 이슈가 없는가?
- [ ] 관련 문서가 업데이트되었는가?
- [ ] Breaking change가 없는가?

## Reviewers (리뷰어)
- @backend-lead (DB/BE 리뷰)
- @frontend-lead (FE 리뷰)
- @qa-engineer (테스트 리뷰)
```

### Step 5: 리뷰어 자동 제안
- git blame 분석
- 관련 파일을 자주 수정한 개발자 식별
- 각 계층별 전담자 추천

**예시:**
- DB 변경: @dba-engineer
- BE 변경: @backend-lead
- FE 변경: @frontend-lead

### Step 6: PR 생성
- GitHub/GitLab CLI 사용
- 브랜치: feature/{feature-name}에서 main으로
- Draft PR vs Ready for Review (선택)

## 산출물
- **PR 페이지**
  - PR ID (예: #123)
  - 제목, 설명
  - Commit 목록
  - Files Changed
  - CI/CD 결과

- **PR 요약 문서**
  - pr-{feature}-{date}.md
    - PR 링크
    - 주요 변경사항
    - 리뷰어 목록
    - 예상 리뷰 기간

## 체크포인트
- [ ] PR 제목이 명확한가?
- [ ] PR 본문의 Why/What/How가 설명되었는가?
- [ ] 테스트 결과가 첨부되었는가?
- [ ] 리뷰어가 적절히 선택되었는가?
- [ ] Draft PR인가? (조기 피드백 받기)
- [ ] Commit 메시지가 명확한가?
- [ ] 불필요한 파일이 포함되지 않았는가?

## 주의사항
- PR 제목은 60자 이내
- Commit 당 1가지 변경만 (원칙)
- node_modules, 빌드 파일 제외 (.gitignore)
- Merge Conflict 해결 (사전에 main 동기화)
- Code Review 피드백 수렴까지 Merge 금지
