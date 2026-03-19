# API 엔드포인트 (P1)

## 인증

- POST /api/auth/signup
  - 설명: 이메일/비밀번호로 회원가입
  - 요청: { email, password, name }
  - 응답: 201 Created, 사용자 정보(민감정보 제외)

- POST /api/auth/login
  - 설명: 로그인
  - 요청: { email, password }
  - 응답: 200 OK
    - 본문 예시: { "access_token": "...", "refresh_token": "...", "token_type": "Bearer", "expires_in": 3600 }

- POST /api/auth/refresh
  - 설명: 리프레시 토큰으로 액세스 토큰 재발급
  - 요청: { refresh_token }
  - 응답: 200 OK, 새 `access_token` 및 `expires_in`

- POST /api/auth/logout
  - 설명: 로그아웃(세션 만료 또는 토큰 폐기)

## 카테고리

- GET /api/categories
  - 설명: 전체 카테고리 목록 조회
  - 응답: [{ id, name, description }]

- GET /api/categories/{id}
  - 설명: 특정 카테고리 상세(예: 포함된 코스 수)

## 강의 (Courses)

- GET /api/courses
  - 설명: 전체 또는 필터(예: category_id)로 강의 목록 조회
  - 응답 항목: { id, title, description, instructor_id, thumbnail_url, category_id }

- GET /api/courses/{id}
  - 설명: 강의 상세 조회
  - 응답: { id, title, description, instructor_id, thumbnail_url, curriculum(lectures), availability: { start_date?, end_date? } }

## 수강 (Enrollments)

- POST /api/courses/{id}/enroll
  - 설명: 현재 사용자로 강의 수강 등록
  - 요청: (인증 필요)
  - 응답: 201 Created, Enrollment 정보

- GET /api/users/me/courses
  - 설명: 현재 사용자의 수강 중인 강의 목록

## 강의 영상 / 강의(lectures)

- GET /api/courses/{id}/lectures
  - 설명: 특정 코스의 강의 목록 조회

- GET /api/lectures/{id}
  - 설명: 특정 강의(lecture) 상세

## 진도 (Progress)

- POST /api/lectures/{id}/progress
  - 설명: 사용자가 해당 강의를 시청했음을 기록
  - 요청: { watched: true }
  - 응답: 200 OK, 저장된 진도 데이터

- GET /api/users/me/progress
  - 설명: 현재 사용자의 진도 목록

## 예외 및 응답 표준(권장)

- 성공: 200 / 201 (리소스 생성)
- 클라이언트 오류: 400 (잘못된 요청), 401 (인증 필요), 403 (권한 없음), 404 (미발견)
- 서버 오류: 500
