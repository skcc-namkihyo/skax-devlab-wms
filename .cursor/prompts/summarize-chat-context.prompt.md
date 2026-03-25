# AI Agent Chat Context Preservation

## 🎯 목적
**Context Preservation Agent**로서 현재 개발 세션의 모든 중요한 정보를 체계적으로 분석하고 구조화하여 새로운 세션에서 작업을 원활히 이어갈 수 있도록 지원합니다.

## 🚀 실행 명령
**Variables**: {{outputFilename}} = `.cursor/summarized/chat-{한국어채팅제목}.json`
**Command**: `save context`

## 📋 실행 단계

### 1. 세션 분석
- shrimp task manager 의 task 목록 및 내용
- 최근 수정된 파일 목록 (지난 24시간 이내)
- 적용된 기술 스택 및 라이브러리
- 사용된 코딩 패턴 및 컨벤션
- 주요 아키텍처 결정사항
- 현재 진행 중인 작업 상태
- 해결된 문제들과 적용된 솔루션

### 2. 패턴 인식
- 명명 규칙 패턴 추출
- 코드 구조 패턴 식별
- 에러 처리 방식 분석
- 데이터 흐름 패턴 파악

### 3. 우선순위화
- **Critical**: 작업 중단 시 반드시 기억해야 할 사항
- **Important**: 다음 세션에서 참고해야 할 사항
- **Reference**: 향후 개발에 도움될 참고 사항

### 4. 품질 검증
- [ ] shrimp task manager 의 task 이관 여부
- [ ] 모든 중요 정보 포함 여부
- [ ] 즉시 작업 재개 가능한 충분한 컨텍스트 제공
- [ ] 기술적 결정사항 명확한 문서화
- [ ] 현재 작업 상태의 정확한 반영
- [ ] 잠재적 문제점과 해결책 포함

### 5. 파일 관리
- {{outputFilename}} 파일을 프로젝트 루트에 생성/업데이트
- `.gitignore` 파일에 {{outputFilename}} 추가 (로컬 전용)
- 기존 파일이 있는 경우 백업 후 병합

## 📊 출력 구조 (JSON)

```json
{
  "session_info": {
    "timestamp": "YYYY-MM-DD HH:MM:SS",
    "session_id": "unique_identifier",
    "duration": "estimated_hours"
  },
  "tech_stack": {
    "framework": "detected_framework",
    "language": "primary_language",
    "libraries": ["lib1", "lib2"],
    "tools": ["tool1", "tool2"]
  },
  "current_state": {
    "completed_tasks": ["task1", "task2"],
    "in_progress": {
      "task": "current_task_description",
      "progress": "percentage_or_status",
      "next_steps": ["step1", "step2"]
    },
    "blocked_items": [
      {
        "issue": "description",
        "blocker": "what's_blocking",
        "suggested_solution": "potential_fix"
      }
    ]
  },
  "established_patterns": {
    "naming_conventions": ["pattern1", "pattern2"],
    "code_structure": ["structure1", "structure2"],
    "architecture_decisions": ["decision1", "decision2"]
  },
  "next_session_guide": {
    "immediate_priorities": ["priority1", "priority2"],
    "context_to_remember": ["context1", "context2"],
    "files_to_review": ["file1", "file2"],
    "cautions": ["warning1", "warning2"]
  }
}
```

## ⚠️ 예외 처리
- **파일 접근 불가**: 임시 메모리 저장 후 수동 저장 안내
- **정보 부족**: 추가 정보 요청 후 재실행
- **분석 실패**: 가능한 정보만으로 부분 컨텍스트 생성

## 📝 사용 예시
```
User: @Files & Folders -> 이 프롬프트 파일 선택 후 `save context`
Agent: [Step 1~5] 순차 실행... ✓
       파일이 성공적으로 생성되었습니다.
       새로운 채팅 세션에서 파일 내용을 붙여넣고 작업을 이어가세요.
```

## ✅ 성공 기준
- 새로운 세션에서 컨텍스트 파일만으로 즉시 개발 재개 가능
- 기술적 결정사항과 진행상황의 명확한 전달
- 코딩 패턴과 컨벤션의 일관된 유지
- 잠재적 문제점과 해결책의 사전 공유

> [!IMPORTANT]
> 이 프롬프트는 shrimp task manager와 연계하여 `New Chat`으로 새창을 열어도 이전 진행상황이 완벽히 공유될 수 있도록 설계되었습니다. {{outputFilename}} 파일은 Git 관리 대상에서 제외되고 로컬에서만 관리됩니다.
