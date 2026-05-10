# SpeakFlow P2 — 기술 스택 및 아키텍처

## 기술 스택

### 프론트엔드

| 기술 | 역할 |
|------|------|
| ERB | 서버 사이드 렌더링 |
| Stimulus | 가벼운 상호작용 제어 |
| Importmap | JS 번들러 없이 컨트롤러 로드 |
| Vanilla CSS | 디자인 시스템 및 화면 스타일 |

### 백엔드

| 기술 | 역할 |
|------|------|
| Ruby on Rails 8.1 | MVC + JSON API |
| PostgreSQL | 메인 DB |
| Active Record | 모델/관계/검증 |
| BCrypt (`has_secure_password`) | 비밀번호 해싱 |
| Session | 현재 인증 상태 유지 |

### 파일/미디어

| 기술 | 역할 |
|------|------|
| Local file upload | 강의 썸네일 업로드 |
| YouTube URL | 강의편 영상 참조 |

---

## 실제 프로젝트 구조

```text
backend/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── pages_controller.rb
│   │   ├── memberships_controller.rb
│   │   ├── coaching_controller.rb
│   │   ├── admin/
│   │   │   ├── base_controller.rb
│   │   │   ├── dashboard_controller.rb
│   │   │   ├── setup_controller.rb
│   │   │   └── users_controller.rb
│   │   ├── instructor/
│   │   │   ├── base_controller.rb
│   │   │   ├── courses_controller.rb
│   │   │   ├── coaching_controller.rb
│   │   │   └── courses/
│   │   │       └── lectures_controller.rb
│   │   └── api/v1/
│   │       ├── auth_controller.rb
│   │       ├── categories_controller.rb
│   │       ├── courses_controller.rb
│   │       ├── lectures_controller.rb
│   │       └── users_controller.rb
│   │
│   ├── models/
│   │   ├── user.rb
│   │   ├── course.rb
│   │   ├── lecture.rb
│   │   ├── category.rb
│   │   ├── enrollment.rb
│   │   ├── progress.rb
│   │   ├── membership_plan.rb
│   │   ├── subscription.rb
│   │   ├── coaching_product.rb
│   │   ├── coaching_purchase.rb
│   │   ├── coaching_credit_entry.rb
│   │   └── feedback_request.rb
│   │
│   ├── views/
│   │   ├── layouts/
│   │   ├── pages/
│   │   ├── memberships/
│   │   ├── coaching/
│   │   ├── admin/
│   │   ├── instructor/
│   │   └── preview/
│   │
│   ├── javascript/controllers/
│   │   ├── auth_controller.js
│   │   ├── shell_controller.js
│   │   ├── flash_controller.js
│   │   ├── lecture_player_controller.js
│   │   ├── tabs_controller.js
│   │   └── coaching_request_controller.js
│   │
│   └── assets/stylesheets/application.css
│
├── config/routes.rb
└── db/migrate/
```

---

## 현재 아키텍처 개념도

```text
Browser
 ├─ Public student pages
 ├─ Admin pages
 ├─ Instructor pages
 ├─ Membership pages
 ├─ Coaching pages
 └─ Preview pages
        │
        ▼
Rails controllers
 ├─ PagesController
 ├─ MembershipsController
 ├─ CoachingController
 ├─ Admin::*
 ├─ Instructor::*
 └─ Api::V1::*
        │
        ▼
Active Record models
 ├─ learning domain
 ├─ subscription domain
 └─ coaching domain
        │
        ▼
PostgreSQL
```

---

## 인증/권한 구조

### 웹 화면

- `session[:user_id]` 기반 로그인 상태 유지
- `ApplicationController#current_user`
- 관리자/강사 전용 화면은 `before_action`으로 차단

### 역할 가드

- `Admin::BaseController`
  - 관리자 계정 존재 여부 확인
  - 관리자 외 접근 시 `/admin/access-denied`
- `Instructor::BaseController`
  - 강사 외 접근 시 `/instructor/access-denied`

### API

- `/api/v1/auth/signup`
- `/api/v1/auth/login`
- `/api/v1/auth/refresh`
- `/api/v1/auth/logout`

현재 API `refresh`는 JWT 재발급이 아니라 **세션 상태 확인/연장용 응답**에 가깝다.

---

## 실제 주요 라우팅 구조

### Public / Student

```ruby
root "pages#dashboard"
get "courses"
get "courses/:id"
get "my-courses"
get "progress"

get "membership"
get "membership/plans"
get "membership/checkout"
get "membership/account"
post "membership/subscribe"
patch "membership/cancel"

get "coaching/products"
post "coaching/purchases"
get "coaching/request"
post "coaching/request"
get "coaching/requests"
```

### Admin

```ruby
namespace :admin do
  root "dashboard#show"
  get "dashboard"
  get "setup"
  post "setup"
  get "access-denied"
  resources :users, only: [:index, :update, :destroy]
end
```

### Instructor

```ruby
namespace :instructor do
  root "courses#index"
  get "access-denied"
  get "coaching/queue"
  get "coaching/requests/:id"
  patch "coaching/requests/:id"

  resources :courses, only: [:index, :new, :create] do
    resources :lectures, only: [:new, :create, :edit, :update], module: :courses
  end
end
```

### Preview

preview는 실제 페이지를 덮어쓰기 전에 구조를 검토하기 위한 별도 네임스페이스로 유지한다.

```ruby
namespace :preview do
  namespace :admin
  namespace :student
  namespace :instructor
end
```

---

## 현재 설계 특징

### 1. 실제 페이지 + preview 페이지 병행

- 본 적용 전에는 preview에서 먼저 검토
- 승인 후 실제 페이지에 반영
- 문구/줄바꿈 등은 실제 페이지에서 함부로 변경하지 않음

### 2. 구독/첨삭 도메인을 분리

- 멤버십은 `subscriptions`
- 첨삭 상품 구매는 `coaching_purchases`
- 실제 차감 기록은 `coaching_credit_entries`
- 요청 자체는 `feedback_requests`

### 3. 스피치 서비스다운 구조

- 강의 소비만 있는 구조가 아니라
- `강의 → 리허설 → 첨삭 요청 → 강사 피드백`
  흐름까지 플랫폼 안에 포함

---

## 현재 한계

- 실제 PG 결제 미연동
- 관리자 강의/카테고리 관리 화면 미완성
- 강사 첨삭 배정 정책 미정
- 첨삭 음성 파일은 아직 실파일 저장이 아니라 참조 문자열 기반
