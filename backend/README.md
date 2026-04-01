# SpeakFlow P1 Backend

온라인 스피치 강의 플랫폼 P1(MVP) Rails 앱입니다.

## 포함 기능
- 회원가입 / 로그인 / 로그아웃 / 세션 갱신
- 카테고리 조회
- 강의 목록/상세 조회
- 수강 신청
- 강의 영상 목록/상세 조회
- 강의 시청 진도 저장
- 내 강의 목록 / 내 진도 조회
- 백엔드 테스트 페이지: `/api-lab`

## 권장 실행
루트에서 Docker Compose 사용:
```powershell
docker compose up --build
```

## 접속
- 메인 페이지: `/`
- 백엔드 테스트 페이지: `/api-lab`
- 헬스체크: `/up`

## api-lab 검증 순서
1. 로그인
2. 카테고리 목록
3. 강의 목록
4. 수강 신청
5. 강의 영상 상세
6. 진도 저장
7. 내 강의
8. 내 진도

## 주요 엔드포인트
- `POST /api/auth/signup`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`
- `GET /api/categories`
- `GET /api/categories/:id`
- `GET /api/courses`
- `GET /api/courses/:id`
- `POST /api/courses/:id/enroll`
- `GET /api/courses/:course_id/lectures`
- `GET /api/lectures/:id`
- `POST /api/lectures/:id/progress`
- `GET /api/users/me/courses`
- `GET /api/users/me/progress`

## Docker 실행 기준
- Rails app: `web`
- PostgreSQL: `db`
- DB 접속 정보는 `docker-compose.yml` 기준으로 고정
- GitHub Actions가 `docker compose build/up`과 `/api-lab` 접근까지 smoke 검증
