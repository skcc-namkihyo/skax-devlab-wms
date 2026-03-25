# 테이블 변경 관리 가이드

## 개요
이 문서는 WMS 창고관리시스템에서 데이터베이스 테이블 변경 시 테이블 정의서(.md 파일) 업데이트 및 변경 이력 관리에 대한 가이드라인을 제공합니다.

## 변경 관리 원칙

### 0. 동기화 순서 원칙 (DDL → 정의서 → README)
- **항상 실제 DDL(스키마) → 테이블 정의서(.md) → README 순으로 모든 변경사항을 동기화해야 함**
- DDL, 정의서, README가 1:1로 일치하지 않으면 실무 혼선 및 오류 발생 가능
- 컬럼 추가/삭제/수정, 제약조건, 인덱스, PK/FK 등 모든 구조/설명/이력/비고가 동일하게 반영되어야 함
- 예시: DDL에서 컬럼 삭제 시, 정의서와 README에서도 해당 컬럼/설명/이력/비고를 반드시 삭제

### 1. 문서 우선 원칙 (Documentation First)
- **DDL 변경 전에 테이블 정의서를 먼저 업데이트**
- 변경 계획을 문서화하고 검토 후 실제 스키마 변경 수행
- 문서와 실제 스키마의 동기화 유지

### 2. 변경 이력 추적
- 모든 변경사항은 반드시 변경 이력에 기록
- 변경 일자, 버전, 작성자, 변경 내용을 명확히 기록
- 변경 사유와 영향도 분석 포함

### 3. 버전 관리
- Semantic Versioning 원칙 적용 (Major.Minor.Patch)
- 호환성 영향도에 따른 버전 번호 부여

### 4. 날짜 형식 규칙
- **날짜 형식**: YYYY-MM-DD (예: 2025-07-07)
- **시간대**: 대한민국 서울 시간 기준 (KST, UTC+9)
- **변경 이력 작성 시**: 현재 날짜를 정확히 반영하여 기록
- **과거 변경사항**: 실제 변경된 날짜를 유지하되, 현재 작업 시에는 현재 날짜 사용

## 테이블 정의서 변경 관리

### 1. 변경 이력 섹션 추가

모든 테이블 정의서에 다음 섹션을 추가해야 합니다:

## [Change History]

| Date       | Version | Author    | Description                           | Impact Level |
|------------|---------|-----------|---------------------------------------|--------------|
| 2025-01-16 | 1.1.0   | 홍길동     | 컬럼 추가: profile_image_url          | Minor        |
| 2024-12-01 | 1.0.0   | 김개발     | 최초 테이블 생성                      | Major        |

### 2. 변경 유형별 업데이트 가이드

#### 📝 **컬럼 추가 (Minor 변경)**

**업데이트 항목:**
- ✅ **Column Definition 테이블**: 새 컬럼 행 추가
- ✅ **Constraints**: 새 제약조건 추가 (있는 경우)
- ✅ **Indexes**: 새 인덱스 추가 (있는 경우)
- ✅ **Business Rules**: 새 컬럼 관련 비즈니스 규칙 추가
- ✅ **Change History**: 변경 이력 기록

**예시:**

## [Column Definition]

| Column Name        | Type         | NOT NULL | PK | FK | Description                    |
|--------------------|--------------|----------|----|----|--------------------------------|
| ...                | ...          | ...      | ...| ...| ...                            |
| profile_image_url  | varchar(500) | N        | N  | N  | 프로필 이미지 URL              | ← 새로 추가

## [Business Rules]
- 기존 규칙들...
- 프로필 이미지 URL은 HTTPS 프로토콜을 권장함 ← 새로 추가

## [Change History]

| Date       | Version | Author | Description                    | Impact Level |
|------------|---------|--------|--------------------------------|--------------|
| 2025-01-16 | 1.1.0   | 홍길동  | 컬럼 추가: profile_image_url   | Minor        |

#### 🔄 **컬럼 수정 (Minor/Major 변경)**

**업데이트 항목:**
- ✅ **Column Definition 테이블**: 해당 컬럼 정보 업데이트
- ✅ **Constraints**: 관련 제약조건 수정
- ✅ **Business Rules**: 변경된 규칙 반영
- ✅ **Change History**: 변경 이력 기록

**예시:**

## [Change History]

| Date       | Version | Author | Description                           | Impact Level |
|------------|---------|--------|---------------------------------------|--------------|
| 2025-01-20 | 1.2.0   | 이개발  | 컬럼 수정: email varchar(100)→(200)  | Minor        |
| 2025-01-16 | 1.1.0   | 홍길동  | 컬럼 추가: profile_image_url          | Minor        |

#### ❌ **컬럼 삭제 (Major 변경)**

**업데이트 항목:**
- ✅ **Column Definition 테이블**: 해당 컬럼 행 제거
- ✅ **Constraints**: 관련 제약조건 제거
- ✅ **Indexes**: 관련 인덱스 제거
- ✅ **Related Tables**: 관련 테이블 관계 업데이트
- ✅ **Change History**: 변경 이력 기록

**예시:**

## [Change History]

| Date       | Version | Author | Description                           | Impact Level |
|------------|---------|--------|---------------------------------------|--------------|
| 2025-02-01 | 2.0.0   | 박개발  | 컬럼 삭제: deprecated_field (사용중단) | Major        |


#### 🔗 **제약조건/인덱스 변경 (Minor 변경)**

**업데이트 항목:**
- ✅ **Constraints**: 제약조건 추가/수정/삭제
- ✅ **Indexes**: 인덱스 추가/수정/삭제
- ✅ **Change History**: 변경 이력 기록

#### 📊 **테이블 목적/기능 변경 (Minor/Major 변경)**

**업데이트 항목:**
- ✅ **Table Purpose**: 목적 업데이트
- ✅ **Main Functions**: 주요 기능 업데이트
- ✅ **Use Cases**: 사용 사례 업데이트
- ✅ **Business Rules**: 비즈니스 규칙 업데이트
- ✅ **Change History**: 변경 이력 기록

## 버전 관리 규칙

### 버전 번호 체계 (Semantic Versioning)

**Major.Minor.Patch (예: 1.2.3)**

#### Major 변경 (x.0.0)
- **호환성을 깨는 변경**
- 컬럼 삭제
- 데이터 타입 변경 (호환되지 않는)
- 제약조건 강화 (기존 데이터에 영향)
- 테이블 삭제 또는 이름 변경

#### Minor 변경 (x.y.0)
- **하위 호환 가능한 기능 추가**
- 컬럼 추가
- 인덱스 추가
- 제약조건 완화
- 새로운 기능 추가

#### Patch 변경 (x.y.z)
- **버그 수정 및 문서 개선**
- 설명(Description) 수정
- 오타 수정
- 코멘트 개선
- 비즈니스 규칙 명확화

### 영향도 레벨

| Impact Level | 설명                           | 예시                        |
|--------------|--------------------------------|-----------------------------|
| **Critical** | 시스템 중단 가능성             | 필수 컬럼 삭제              |
| **Major**    | 기존 기능에 큰 영향            | 데이터 타입 변경            |
| **Minor**    | 기존 기능에 최소 영향          | 컬럼 추가, 인덱스 추가      |
| **Patch**    | 기능에 영향 없음               | 문서 수정, 코멘트 개선      |

## 변경 프로세스

### 0. 동기화 순서 실무 표준
1. **DDL(스키마) 변경**: 실제 DB 구조를 먼저 변경
2. **테이블 정의서(.md) 동기화**: DDL과 1:1로 맞춰 컬럼/제약조건/이력 등 수정
3. **README 동기화**: 테이블/컬럼/비고/이력 등 설명을 정의서와 동일하게 반영
4. **최종 검증**: DDL, 정의서, README가 완전히 일치하는지 확인

> ⚠️ 실무에서는 DDL, 정의서, README가 불일치할 경우 반드시 동기화 후 배포/적용해야 하며, 일부만 변경 시 혼선 및 장애의 원인이 됨

### 1. 계획 단계
1. **변경 요구사항 분석**
2. **영향도 분석** (관련 테이블, 애플리케이션 코드 확인)
3. **버전 번호 결정**
4. **변경 계획서 작성**

### 2. 문서화 단계
1. **테이블 정의서 업데이트**
2. **변경 이력 추가**
3. **관련 README.md 업데이트**
4. **문서 검토 및 승인**

### 3. 구현 단계
1. **DDL 스크립트 작성**
2. **개발 환경에서 테스트**
3. **스테이징 환경 적용**
4. **운영 환경 적용**

### 4. 검증 단계
1. **스키마 일치성 확인**
2. **애플리케이션 동작 확인**
3. **문서 최종 업데이트**

## 자동화 도구 (향후 개발 예정)

# 실제 구현은 향후 개발 예정

### 변경 요구사항
`ats.resource_info` 테이블에 `profile_image_url` 컬럼 추가

### 1. 변경 계획
- **버전**: 1.0.0 → 1.1.0 (Minor 변경)
- **영향도**: Minor (기존 기능에 영향 없음)
- **작업자**: 홍길동

### 2. 테이블 정의서 업데이트


## [Column Definition]

| Column Name        | Type         | NOT NULL | PK | FK | Description                    |
|--------------------|--------------|----------|----|----|--------------------------------|
| resource_id        | serial4      | Y        | Y  | N  | 인력 ID                        |
| employee_number    | varchar(50)  | Y        | N  | N  | 사원번호                       |
| name               | varchar(100) | Y        | N  | N  | 이름                           |
| email              | varchar(100) | Y        | N  | N  | 이메일                         |
| profile_image_url  | varchar(500) | N        | N  | N  | 프로필 이미지 URL              |
| created_at         | timestamp    | Y        | N  | N  | 생성일시                       |
| updated_at         | timestamp    | Y        | N  | N  | 수정일시                       |
| created_by         | varchar(50)  | Y        | N  | N  | 생성자                         |
| updated_by         | varchar(50)  | Y        | N  | N  | 수정자                         |

## [Business Rules]
- 사원번호(employee_number)는 중복 불가
- 이메일(email)은 유효한 형식이어야 함
- 프로필 이미지 URL은 HTTPS 프로토콜을 권장함

## [Change History]

| Date       | Version | Author | Description                    | Impact Level |
|------------|---------|--------|--------------------------------|--------------|
| 2025-01-16 | 1.1.0   | 홍길동  | 컬럼 추가: profile_image_url   | Minor        |
| 2024-12-01 | 1.0.0   | 김개발  | 최초 테이블 생성               | Major        |


### 3. DDL 스크립트

```sql
-- 컬럼 추가
ALTER TABLE ats.resource_info 
ADD COLUMN profile_image_url VARCHAR(500);

-- 컬럼 코멘트 추가
COMMENT ON COLUMN ats.resource_info.profile_image_url IS '프로필 이미지 URL';
```

## 참고 자료
- [PostgreSQL 오브젝트 설계 가이드](./postgresql_object_guide.md)
- [테이블 정의서 템플릿](./table_definition_template.md)
- [테이블 정의서 목록](../table_definitions/README.md)

---

> 이 가이드를 따라 체계적인 테이블 변경 관리를 통해 데이터베이스 스키마의 일관성과 추적 가능성을 유지하세요. 