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

## 처음 세팅
루트에서 실행:
```powershell
.\setup_backend.bat
```

이 스크립트는 아래를 처리합니다.
- `bundle install`
- `rails db:prepare`
- `rails db:seed`

## 서버 실행
루트에서 실행:
```powershell
.\start_backend.bat
```

접속:
- 루트 페이지: `/`
- 백엔드 테스트 페이지: `/api-lab`
- 헬스체크: `/up`

## DB 설정
- 기본값: `DB_HOST=127.0.0.1`, `DB_PORT=5432`
- 필요하면 `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD` 환경변수로 덮어쓸 수 있음. 예시는 `backend/.env.example` 참고

예시:
```powershell
$env:DB_PORT='55432'
.\setup_backend.bat
.\start_backend.bat
```
