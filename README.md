# SpeakFlow P1

온라인 스피치 강의 플랫폼 P1(MVP) Rails 프로젝트입니다.

## 포함 기능 (백엔드 API)
- 회원가입 / 로그인 / 로그아웃 / 세션 갱신
- 카테고리 조회
- 강의 목록/상세 조회
- 수강 신청
- 강의 목록(코스별) / 강의 상세 조회
- 강의 시청 진도 저장
- 내 강의 목록 / 내 진도 조회

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

## 로컬 실행
1. PostgreSQL 실행
2. `bundle install`
3. `bundle exec rails db:create db:migrate db:seed`
4. `bundle exec rails server`

루트 페이지: `/`
헬스체크: `/up`
