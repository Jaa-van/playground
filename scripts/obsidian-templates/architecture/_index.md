# 아키텍처 문서

> 시스템 구조 및 설계 결정을 기록합니다.

## 문서 목록

| 문서 | 설명 |
|------|------|
| [[platground/architecture/overview\|전체 시스템 구조]] | 레이어별 역할과 전체 흐름 |
| [[platground/architecture/backend-layers\|Backend 계층 패턴]] | API / Service / Repository 패턴 |
| [[platground/architecture/frontend-structure\|Frontend 컴포넌트 구조]] | 페이지 / 컴포넌트 / 훅 구성 |

## 시스템 개요

```
Browser
   │ HTTP :80
   ▼
nginx (Reverse Proxy)
   ├── /api/* → backend:8000  (FastAPI)
   └── /*     → frontend:3000 (React SPA)
                   │
                   ▼
               SQLite
           /app/data/app.db
```

---
> 출처: `docs/architecture/` in git repo
