# ERD (Entity Relationship Diagram) - 개요 및 테이블 정의

## 엔터티 목록 및 필드

### Users

- id (PK)
- email (unique)
- password_digest
- name
- role (string) - 기본값: student
- created_at
- updated_at

### Categories

- id (PK)
- name
- description
- created_at
- updated_at

### Courses

- id (PK)
- title
- description
- category_id (FK -> Categories.id)
- instructor_name
- thumbnail_url
- created_at
- updated_at

### Lectures

- id (PK)
- course_id (FK -> Courses.id)
- title
- video_url
- order_no (int)
- duration (seconds 또는 hh:mm:ss)
- created_at
- updated_at

### Enrollments

- id (PK)
- user_id (FK -> Users.id)
- course_id (FK -> Courses.id)
- created_at

### Progress

- id (PK)
- user_id (FK -> Users.id)
- lecture_id (FK -> Lectures.id)
- watched (boolean)
- watched_at (timestamp)

## 관계 구조

- Category 1:N Course
- Course 1:N Lecture
- User N:M Course via Enrollments
- User 1:N Progress

## 예시 카테고리

- 발표 스피치
- 면접 스피치
- 커뮤니케이션
- 설득 화법
- 보이스 트레이닝
