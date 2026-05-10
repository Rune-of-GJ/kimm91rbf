# SpeakFlow P2 API / 서버 인터페이스 설계

## 문서 기준

이 문서는 `2026-05-07` 기준 실제 구현 상태를 바탕으로 정리한다.

중요:

- 현재 인증은 JWT가 아니라 세션 기반이다.
- 현재 서비스의 주요 진입은 웹 라우트다.
- `/api/*`는 일부 인증 응답용으로만 존재하며, 핵심 기능은 HTML 라우트에서 처리된다.

---

## 인증

### 현재 구현

| Method | Path | 설명 |
|--------|------|------|
| POST | `/api/v1/auth/signup` | 회원가입 |
| POST | `/api/v1/auth/login` | 로그인 |
| POST | `/api/v1/auth/refresh` | 현재 세션 상태 반환 |
| POST | `/api/v1/auth/logout` | 로그아웃 |

### 특이점

- 로그인 성공 시 실질적인 인증 주체는 `session[:user_id]`다.
- `refresh`는 JWT 재발급 API가 아니라 현재 세션 정보 응답에 가깝다.

---

## 실제 웹 라우트

### 학생

| Method | Path | 설명 |
|--------|------|------|
| GET | `/membership` | 멤버십 소개 |
| GET | `/membership/plans` | 요금제 비교 |
| GET | `/membership/checkout` | 가입 결제 화면 |
| GET | `/membership/account` | 내 멤버십 |
| POST | `/membership/subscribe` | 멤버십 시작 / 플랜 변경 |
| PATCH | `/membership/cancel` | 멤버십 해지 |
| GET | `/coaching/products` | 첨삭 상품 목록 |
| POST | `/coaching/purchases` | 첨삭 상품 구매 |
| GET | `/coaching/request` | 첨삭 요청 작성 |
| POST | `/coaching/request` | 첨삭 요청 생성 |
| GET | `/coaching/requests` | 내 첨삭 요청 목록 |

### 강사

| Method | Path | 설명 |
|--------|------|------|
| GET | `/instructor` | 강사 홈 |
| GET | `/instructor/courses/new` | 강의 등록 |
| POST | `/instructor/courses` | 강의 생성 |
| GET | `/instructor/courses/:course_id/lectures/new` | 강의편 추가 |
| POST | `/instructor/courses/:course_id/lectures` | 강의편 생성 |
| GET | `/instructor/courses/:course_id/lectures/:id/edit` | 강의편 수정 |
| PATCH | `/instructor/courses/:course_id/lectures/:id` | 강의편 저장 |
| GET | `/instructor/coaching/queue` | 첨삭 대기열 |
| GET | `/instructor/coaching/requests/:id` | 첨삭 리뷰 |
| PATCH | `/instructor/coaching/requests/:id` | 첨삭 완료 |

### 관리자

| Method | Path | 설명 |
|--------|------|------|
| GET | `/admin` | 관리자 대시보드 |
| GET | `/admin/setup` | 최초 관리자 계정 생성 |
| POST | `/admin/setup` | 최초 관리자 계정 생성 |
| GET | `/admin/users` | 사용자 관리 |
| PATCH | `/admin/users/:id` | 역할 변경 |
| DELETE | `/admin/users/:id` | 사용자 삭제 |

---

## 현재 서버 동작

## 1. 멤버십 구독

### `POST /membership/subscribe`

동작:

1. 선택한 `MembershipPlan` 조회
2. 기존 활성 구독을 `replaced` 처리
3. 새 `Subscription` 생성
4. 플랜 포함 첨삭 크레딧이 있으면 `coaching_credit_entries`에 적립
5. 적립 시 `remaining_credits`도 같은 수치로 세팅

현재 상태:

- 실제 PG 연동은 아직 없음
- 상태 반영 중심의 서버 동작

### `PATCH /membership/cancel`

동작:

1. 현재 활성 구독 조회
2. `canceled` 상태로 변경
3. 종료 시각을 현재 시각으로 갱신

---

## 2. 첨삭 상품 구매

### `POST /coaching/purchases`

동작:

1. `CoachingProduct` 조회
2. `coaching_purchases` 생성
3. `coaching_credit_entries`에 양수 적립
4. `remaining_credits`에 실제 잔량 저장

현재 상태:

- 실제 결제 연동은 아직 없음
- 구매 성공 시 DB 상태 반영까지는 실제 동작

---

## 3. 첨삭 요청 생성

### `POST /coaching/request`

동작:

1. 현재 사용자의 사용 가능 첨삭 잔액 확인
2. `credit_source_preference` 결정
   - 현재 기본값: `membership_first`
3. `CoachingCreditAllocator`가 차감 가능한 적립 엔트리 선택
4. `feedback_requests` 생성
5. 선택된 적립 엔트리의 `remaining_credits` 차감
6. `coaching_credit_usages`에 어떤 적립 엔트리를 썼는지 기록
7. 원장 추적용 음수 `coaching_credit_entries` 추가

### 현재 우선순위 정책

지원:

- `membership_first`
- `purchase_first`
- `oldest_first`

현재 실제 UI:

- 사용자가 이 값을 화면에서 직접 고르지는 않음
- 백엔드 기본 동작은 `membership_first`

---

## 4. 강사 첨삭 완료

### `PATCH /instructor/coaching/requests/:id`

동작:

1. 타임코드 코멘트 입력
2. 총평 입력
3. `instructor_id` 저장
4. 상태를 `completed`로 변경
5. `reviewed_at` 기록

---

## 리허설 사용량 관련 서버 준비 상태

현재 추가된 구조:

- `rehearsal_submissions`
- `User#current_month_rehearsal_usage`
- `User#remaining_rehearsal_count`

의미:

- `membership_plans.monthly_rehearsal_limit`는 더 이상 문구용 숫자만이 아니다.
- 실제 제출 기록이 쌓이면 남은 개수를 계산할 수 있다.

현재 한계:

- 아직 리허설 제출 기능 자체가 없어서 `rehearsal_submissions`를 생성하는 실제 라우트는 없다.
- 따라서 이 값은 데이터 모델과 계산 메서드까지 준비된 상태다.

---

## 첨삭 크레딧 출처 추적

### 왜 `source_type / source_id`만으로 부족했는가

기존에는:

- 적립과 차감 원장 기록은 남길 수 있었지만
- "정확히 어떤 적립 건에서 차감했는가"를 저장하지 못했다.

### 지금 추가된 보강 구조

- `coaching_credit_entries.remaining_credits`
- `feedback_requests.credit_source_preference`
- `feedback_requests.applied_credit_entry_id`
- `coaching_credit_usages`

이제 가능한 것:

- 어떤 적립 건의 잔액이 얼마 남았는지 추적
- 요청별 대표 차감 출처 저장
- 요청별 실제 차감 내역 저장
- 이후 UI에서 출처 선택을 붙일 기반 확보

---

## 이후 확장안

### 리허설

후속 API 예시:

| Method | Path | 설명 |
|--------|------|------|
| POST | `/api/v1/rehearsals` | 리허설 제출 생성 |
| GET | `/api/v1/rehearsals` | 내 제출 목록 |
| GET | `/api/v1/membership/usage` | 이번 달 사용량 / 잔여 수 |

### 첨삭권 출처 선택

후속 API 예시:

| Method | Path | 설명 |
|--------|------|------|
| GET | `/api/v1/coaching/credits` | 출처별 잔액 조회 |
| POST | `/api/v1/coaching/request` | 출처 우선순위 포함 요청 생성 |

예시 payload:

```json
{
  "title": "면접 자기소개 리허설",
  "course_id": 12,
  "lecture_id": 33,
  "audio_reference": "intro-01.m4a",
  "credit_source_preference": "purchase_first"
}
```

---

## 요약

현재 P2 서버 구조는 다음 수준까지 실제 동작한다.

- 세션 기반 인증
- 관리자 / 강사 / 학생 역할 분리
- 멤버십 구독 / 해지 / 변경
- 첨삭 상품 구매
- 첨삭 요청 생성 / 강사 완료 처리
- 첨삭권 출처 추적용 DB 구조

또한 피드백에서 지적된 두 부분도 이제 서버 기준으로 대응 가능해졌다.

1. 리허설 한도는 실제 잔여 수 계산이 가능하다.
2. 첨삭권은 출처별 잔량과 우선순위를 저장할 수 있다.
