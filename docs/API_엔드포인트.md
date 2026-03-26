# API 엔드포인트 (P1)

현재 문서는 `backend` 구현 기준으로 작성한다.
인증 방식은 JWT가 아니라 세션 기반이며, 프론트는 쿠키 세션을 유지하는 방식으로 연동한다.

## 인증

### POST /api/auth/signup
- 설명: 이메일/비밀번호로 회원가입
- 요청 본문:
```json
{ "email": "user@example.com", "password": "password123", "name": "홍길동" }
```
- 성공 응답: `201 Created`
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "role": "student",
    "created_at": "2026-03-26T00:00:00.000Z"
  }
}
```
- 실패 응답: `422 Unprocessable Entity`

### POST /api/auth/login
- 설명: 로그인
- 요청 본문:
```json
{ "email": "user@example.com", "password": "password123" }
```
- 성공 응답: `200 OK`
```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "role": "student",
    "created_at": "2026-03-26T00:00:00.000Z"
  },
  "token_type": "Session",
  "expires_in": 3600
}
```
- 실패 응답: `401 Unauthorized`
```json
{ "error": "Invalid email or password" }
```

### POST /api/auth/refresh
- 설명: 현재 로그인 세션 기준 사용자 정보 갱신
- 성공 응답: `200 OK`
- 실패 응답: `401 Unauthorized`

### POST /api/auth/logout
- 설명: 로그아웃
- 성공 응답: `204 No Content`

## 카테고리

### GET /api/categories
- 설명: 전체 카테고리 목록 조회
- 성공 응답: `200 OK`
```json
[
  { "id": 1, "name": "발표 스피치", "description": "발표 훈련" }
]
```

### GET /api/categories/:id
- 설명: 특정 카테고리 상세 조회
- 성공 응답: `200 OK`
```json
{ "id": 1, "name": "발표 스피치", "description": "발표 훈련", "courses_count": 3 }
```

## 강의

### GET /api/courses
- 설명: 전체 또는 `category_id` 필터로 강의 목록 조회
- 쿼리 파라미터:
  - `category_id` optional
- 성공 응답: `200 OK`
```json
[
  {
    "id": 1,
    "title": "스토리텔링 프레젠테이션",
    "description": "청중을 설득하는 발표 스토리 구성법",
    "instructor_id": 2,
    "instructor_name": "기본 강사",
    "thumbnail_url": "https://...",
    "category_id": 1,
    "category_name": "발표 스피치",
    "lectures_count": 3,
    "enrolled": false
  }
]
```

### GET /api/courses/:id
- 설명: 강의 상세 조회
- 성공 응답: `200 OK`
```json
{
  "id": 1,
  "title": "스토리텔링 프레젠테이션",
  "description": "청중을 설득하는 발표 스토리 구성법",
  "instructor_id": 2,
  "instructor_name": "기본 강사",
  "thumbnail_url": "https://...",
  "category_id": 1,
  "category_name": "발표 스피치",
  "lectures_count": 3,
  "enrolled": false,
  "curriculum": [
    {
      "id": 1,
      "title": "청중 분석과 목표 설정",
      "video_url": "https://www.youtube.com/watch?v=...",
      "order_no": 1,
      "duration": 600
    }
  ],
  "availability": {
    "start_date": null,
    "end_date": null,
    "enrollment_deadline": null,
    "max_access_days": null,
    "available": true,
    "enrollment_open": true
  }
}
```
- 실패 응답: `404 Not Found`

### POST /api/courses/:id/enroll
- 설명: 현재 사용자 기준 강의 수강 신청
- 인증: 필요
- 성공 응답:
  - 신규 신청: `201 Created`
  - 기존 신청 존재: `200 OK`
```json
{
  "id": 10,
  "user_id": 1,
  "course_id": 1,
  "created_at": "2026-03-26T00:00:00.000Z"
}
```
- 실패 응답:
  - `401 Unauthorized`
  - `422 Unprocessable Entity` (`Course is closed for enrollment`)

## 강의 영상

### GET /api/courses/:course_id/lectures
- 설명: 특정 코스의 강의 목록 조회
- 성공 응답: `200 OK`
```json
[
  {
    "id": 1,
    "course_id": 1,
    "title": "청중 분석과 목표 설정",
    "video_url": "https://www.youtube.com/watch?v=...",
    "order_no": 1,
    "duration": 600,
    "watched": false
  }
]
```

### GET /api/lectures/:id
- 설명: 특정 강의 상세 조회
- 성공 응답: `200 OK`
```json
{
  "id": 1,
  "course_id": 1,
  "title": "청중 분석과 목표 설정",
  "video_url": "https://www.youtube.com/watch?v=...",
  "order_no": 1,
  "duration": 600,
  "watched": false
}
```

## 진도

### POST /api/lectures/:id/progress
- 설명: 특정 강의 시청 여부 저장
- 인증: 필요
- 요청 본문:
```json
{ "watched": true }
```
- 성공 응답: `200 OK`
```json
{
  "id": 1,
  "user_id": 1,
  "lecture_id": 1,
  "watched": true,
  "watched_at": "2026-03-26T00:00:00.000Z"
}
```
- 실패 응답:
  - `400 Bad Request` (`watched` 누락)
  - `401 Unauthorized`
  - `403 Forbidden` (`Enrollment required`)

### GET /api/users/me/courses
- 설명: 현재 사용자의 수강 강의 목록 조회
- 인증: 필요
- 성공 응답: `200 OK`
```json
[
  {
    "id": 1,
    "title": "스토리텔링 프레젠테이션",
    "description": "청중을 설득하는 발표 스토리 구성법",
    "category_id": 1,
    "instructor_name": "기본 강사",
    "thumbnail_url": "https://...",
    "total_lectures": 3,
    "watched_lectures": 1,
    "progress_rate": 33
  }
]
```

### GET /api/users/me/progress
- 설명: 현재 사용자의 코스별/강의별 진도 조회
- 인증: 필요
- 성공 응답: `200 OK`
```json
[
  {
    "course_id": 1,
    "course_title": "스토리텔링 프레젠테이션",
    "total_lectures": 3,
    "watched_lectures": 1,
    "progress_rate": 33,
    "lectures": [
      {
        "lecture_id": 1,
        "lecture_title": "청중 분석과 목표 설정",
        "order_no": 1,
        "watched": true,
        "watched_at": "2026-03-26T00:00:00.000Z"
      }
    ]
  }
]
```

## 공통 오류 응답

- `400 Bad Request`: 필수 파라미터 누락
- `401 Unauthorized`: 인증 필요
- `403 Forbidden`: 수강 권한 없음
- `404 Not Found`: 리소스 없음
- `422 Unprocessable Entity`: 유효성 검증 실패

예시:
```json
{ "error": "Authentication required" }
```
또는
```json
{ "errors": ["Email has already been taken"] }
```
