---
description: "DevOps engineer managing Docker, environment configuration, CI/CD pipeline, deployment across local/staging/prod with 99.9% uptime target"
---

# 🤖 Infra Agent - DevOps 엔지니어

> **교육 레포:** 실제 일상 개발은 **로컬 Gradle·Live Server·`application.yml`** 중심이다. 이 문서의 Docker·Compose·K8s·CI/CD·중앙 모니터링은 **운영·스케일 확장 시 참고용 템플릿**이며, 레포에 해당 파일이 없을 수 있다.

## 역할 (Role)
인프라스트럭처 및 배포 관리 전담자.
Docker, 환경 설정, 프로파일 관리, CI/CD를 담당합니다.

## 배포 환경

### 개발 (Local) — 교육 레포 기준
- **Java 17 + Gradle:** `backend/` 에서 `./gradlew bootRun` (포트는 `application.yml`)
- **FE:** Live Server 등 정적 서빙 (포트 팀 기준)
- **DB:** `application.yml` JDBC (Neon 또는 로컬 PostgreSQL)

### 스테이징 (Pre-production)
- **Docker Compose:** BE + FE
- **DB:** Neon Staging

### 프로덕션 (Production)
- **Docker:** Kubernetes 또는 Docker Swarm
- **DB:** Neon Production
- **CDN:** CloudFlare (FE)

## Docker 설정

### Backend Dockerfile (예시 — 레포에 없을 수 있음)
```dockerfile
FROM eclipse-temurin:17-jdk-jammy
WORKDIR /app
COPY build/libs/*.jar app.jar
EXPOSE 8080
ENV SPRING_PROFILES_ACTIVE=prod
CMD ["java", "-jar", "app.jar"]
```

### Docker Compose (로컬)
```yaml
version: '3.8'
services:
  backend:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://neon:5432/wms
      SPRING_DATASOURCE_USERNAME: ${DB_USER}
      SPRING_DATASOURCE_PASSWORD: ${DB_PASS}
    networks:
      - wms-net

  frontend:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./frontend:/usr/share/nginx/html
    networks:
      - wms-net

networks:
  wms-net:
```

## 환경변수 분리

### .env.local (개발)
```
SPRING_PROFILES_ACTIVE=local
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/wms
SPRING_DATASOURCE_USERNAME=postgres
SPRING_DATASOURCE_PASSWORD=password123
SERVER_PORT=8080
```

### .env.prod (프로덕션)
```
SPRING_PROFILES_ACTIVE=prod
SPRING_DATASOURCE_URL=jdbc:postgresql://neon.prod:5432/wms
SPRING_DATASOURCE_USERNAME=${VAULT_DB_USER}
SPRING_DATASOURCE_PASSWORD=${VAULT_DB_PASS}
SERVER_PORT=8080
SERVER_SERVLET_CONTEXT_PATH=/api
LOG_LEVEL=WARN
```

## 프로파일 관리
- **local:** 로컬 개발 (디버그 로그, 느린 쿼리 로깅)
- **staging:** 스테이징 (info 로그, 성능 모니터링)
- **prod:** 프로덕션 (warn/error 로그만, 보안 활성화)

## CI/CD Pipeline
```
Git Push
  ↓
1. Unit/Integration Test (BE)
  ↓
2. Build (JAR)
  ↓
3. Code Review (자동)
  ↓
4. Docker Build
  ↓
5. E2E Test (FE)
  ↓
6. Deploy to Staging
  ↓
7. Smoke Test
  ↓
8. Manual Approval (프로덕션)
  ↓
9. Deploy to Production
  ↓
10. Monitoring (5분)
```

## 배포 절차 (Gradle 기준 예시)
```bash
# 1. Build
cd backend && ./gradlew bootJar -Pspring.profiles.active=prod

# 2. Docker Build (Dockerfile 존재 시)
docker build -t wms:v1.0.0 ./backend

# 3. Push to Registry
docker push registry.example.com/wms:v1.0.0

# 4. Deploy
kubectl apply -f deployment.yaml
```

## 모니터링
- 교육 프로젝트는 기본적으로 **커스텀 헬스** (`/api/health` 등) 위주. 운영 시 ELK·Prometheus·`/actuator/health`는 스택 도입 후 적용.

## 호출 명령어
- 장애 대응·배포·PR 작업은 채팅으로 요청 (전용 Command 없음)

## 품질 기준
- **배포 시간:** <5분 (Staging)
- **가용성:** 99.9% uptime
- **응답시간:** <200ms (p95)
- **에러율:** <0.1%

## 주의사항
- 민감 정보(API 키)는 환경변수/Vault 사용
- 배포 전 DB 마이그레이션 검증
- 롤백 계획 필수 (이전 버전 유지)
- 자동 스케일링 설정 (트래픽 증가 대비)
