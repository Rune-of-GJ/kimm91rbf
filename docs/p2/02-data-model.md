# SpeakFlow P2 데이터 모델

## 변경 요약

P2에서는 기존 학습 테이블 위에 다음 4개 축이 추가되었다.

1. 역할 분리
2. 월정액 멤버십
3. 첨삭 상품과 크레딧
4. 첨삭 요청과 강사 피드백

또한 `2026-05-07` 기준으로, 사용자 피드백을 반영해 아래 구조가 추가되었다.

- `rehearsal_submissions`
- `coaching_credit_usages`
- `coaching_credit_entries.remaining_credits`
- `feedback_requests.credit_source_preference`
- `feedback_requests.applied_credit_entry_id`

이 변경으로 "월 리허설 한도는 몇 개가 남았는가", "첨삭권은 어떤 출처에서 차감되었는가"를 데이터 구조 차원에서 추적할 수 있게 되었다.

---

## 현재 테이블 구성

| 영역 | 테이블 |
|------|--------|
| 기본 학습 | `users`, `categories`, `courses`, `lectures`, `enrollments`, `progresses` |
| 멤버십 | `membership_plans`, `subscriptions` |
| 첨삭 상품 | `coaching_products`, `coaching_purchases`, `coaching_credit_entries`, `coaching_credit_usages` |
| 첨삭 요청 | `feedback_requests` |
| 리허설 사용량 | `rehearsal_submissions` |

---

## 핵심 관계

```text
users
 ├─ has_many subscriptions
 ├─ has_many coaching_purchases
 ├─ has_many coaching_credit_entries
 ├─ has_many coaching_credit_usages
 ├─ has_many feedback_requests
 ├─ has_many rehearsal_submissions
 └─ has_many instructed_courses

membership_plans
 └─ has_many subscriptions

coaching_products
 └─ has_many coaching_purchases

coaching_credit_entries
 └─ has_many coaching_credit_usages

feedback_requests
 ├─ belongs_to user
 ├─ belongs_to course (optional)
 ├─ belongs_to lecture (optional)
 ├─ belongs_to instructor (optional)
 └─ belongs_to applied_credit_entry (optional)
```

---

## 주요 테이블

### users

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | PK | |
| email | string, unique | 로그인 이메일 |
| password_digest | string | `has_secure_password` |
| name | string | 사용자 이름 |
| role | string | `student / instructor / admin` |
| created_at | datetime | |
| updated_at | datetime | |

비고:

- 인증은 현재 세션 기반이다.
- `role`은 문자열 enum으로 관리한다.

### courses

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | PK | |
| category_id | FK | 카테고리 |
| instructor_id | FK -> users.id | 강사 계정 |
| instructor_name | string | 표시용 강사명 |
| title | string | 강의명 |
| description | text | 강의 설명 |
| start_date | date | 시작일 |
| end_date | date | 종료일 |
| enrollment_deadline | date | 수강 신청 마감일 |
| thumbnail_url | string | 업로드 파일 경로 |
| max_access_days | integer | 과거 설계 잔존 컬럼, 현재 미사용 |

비고:

- 현재 정책은 "결제 후 기간제 소장"이 아니라 "활성 멤버십 기반 학습"에 가깝다.

### membership_plans

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | PK | |
| name | string | Lite / Pro / Coach |
| slug | string, unique | 내부 식별자 |
| tagline | string | 소개 문구 |
| monthly_price | integer | 월 요금 |
| monthly_rehearsal_limit | integer | 월 리허설 제출 한도 정책값 |
| monthly_coaching_credits | integer | 월 포함 첨삭 크레딧 |
| active | boolean | 노출 여부 |
| featured | boolean | 추천 플랜 여부 |
| position | integer | 정렬 순서 |

중요:

- `monthly_rehearsal_limit`는 더 이상 단순 설명값만이 아니다.
- 실제 사용량 계산은 `rehearsal_submissions`를 기준으로 할 수 있다.
- 다만 아직 UI에는 "이번 달 몇 개 남음"이 노출되지 않는다.

### subscriptions

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | PK | |
| user_id | FK | 구독 사용자 |
| membership_plan_id | FK | 플랜 |
| status | string | `active / replaced / canceled` |
| started_at | datetime | 시작 시각 |
| current_period_end | datetime | 현재 기간 종료 |
| canceled_at | datetime | 해지 시각 |

### coaching_products

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | PK | |
| name | string | 상품명 |
| slug | string, unique | 내부 식별자 |
| tagline | string | 상품 설명 |
| price | integer | 가격 |
| credits_amount | integer | 지급 첨삭 크레딧 수 |
| active | boolean | 노출 여부 |
| position | integer | 정렬 순서 |

### coaching_purchases

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | PK | |
| user_id | FK | 구매 사용자 |
| coaching_product_id | FK | 구매 상품 |
| status | string | `completed / refunded` |
| paid_amount | integer | 결제 금액 |
| credits_amount | integer | 지급 크레딧 수 |

### coaching_credit_entries

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | PK | |
| user_id | FK | 사용자 |
| source_type | polymorphic | `Subscription / CoachingPurchase / FeedbackRequest` 등 |
| source_id | polymorphic | 출처 ID |
| credits_amount | integer | 원장 기준 +적립 / -차감 |
| remaining_credits | integer | 실제로 아직 쓸 수 있는 잔량 |
| label | string | 표시 문구 |
| expires_at | datetime | 만료 시각, 현재는 미사용 |

중요:

- `credits_amount`는 원장 기록이다.
- `remaining_credits`는 실제 사용 가능한 잔량이다.
- 따라서 앞으로는 단순 `sum(:credits_amount)`가 아니라 `remaining_credits` 기준으로 계산한다.
- `source_type / source_id`는 출처 추적용 구조로 적합하며, Rails에서 구현 가능한 방식이다.
- 다만 이 필드만으로 우선순위가 자동 해결되지는 않는다. 우선순위는 서비스 로직이 담당한다.

### coaching_credit_usages

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | PK | |
| user_id | FK | 사용자 |
| feedback_request_id | FK | 어떤 첨삭 요청에서 썼는지 |
| coaching_credit_entry_id | FK | 어떤 적립 엔트리에서 차감했는지 |
| credits_amount | integer | 차감량 |

이 테이블은 "이번 요청이 구독 크레딧을 썼는지, 별도 구매 크레딧을 썼는지"를 정확히 기록한다.

### feedback_requests

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | PK | |
| user_id | FK | 요청한 학생 |
| instructor_id | FK -> users.id | 처리한 강사 |
| course_id | FK, nullable | 대상 강의 |
| lecture_id | FK, nullable | 대상 강의편 |
| title | string | 요청 제목 |
| note | text | 학생 메모 |
| audio_reference | string | 파일명 또는 링크 |
| status | string | `queued / reviewing / completed` |
| used_credits | integer | 사용 크레딧 수 |
| credit_label | string | 표시 문구 |
| credit_source_preference | string | `membership_first / purchase_first / oldest_first` |
| applied_credit_entry_id | FK -> coaching_credit_entries.id | 대표 차감 출처 |
| response_summary | text | 강사 총평 |
| response_timecodes | text | 타임코드 코멘트 |
| reviewed_at | datetime | 검토 완료 시각 |

중요:

- 이제 요청 단위로 "어떤 우선순위로 차감하려고 했는가"를 저장한다.
- 현재 실제 UI는 아직 출처 선택을 노출하지 않지만, 백엔드 기본값은 `membership_first`다.

### rehearsal_submissions

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | PK | |
| user_id | FK | 제출한 사용자 |
| subscription_id | FK, nullable | 당시 활성 구독 |
| course_id | FK, nullable | 대상 강의 |
| lecture_id | FK, nullable | 대상 강의편 |
| submitted_at | datetime | 제출 시각 |
| source_label | string | 생성 경로 표기 |
| note | text | 메모 |

이 테이블은 리허설 사용량 집계용이다.

예:

- 이번 달 제출 수
- 멤버십 플랜 기준 잔여 제출 수
- 강의/강의편별 리허설 기록

---

## 현재 동작과 현재 한계

### 이미 가능한 것

- `User#current_month_rehearsal_usage`
- `User#remaining_rehearsal_count`
- 첨삭 요청 생성 시 `membership_first` 기준 우선 차감
- 어떤 적립 엔트리에서 차감했는지 `coaching_credit_usages`에 기록

### 아직 남아 있는 것

- 사용자가 첨삭권 출처를 직접 고르는 UI
- 만료 임박 크레딧 우선 차감 정책
- 여러 개의 출처를 조합하는 복잡한 차감 UX
- 리허설 사용량을 학생 화면에 노출하는 UI

---

## 요약

이번 데이터 모델 업데이트로 피드백에서 지적한 세 가지가 모두 구조적으로 대응 가능해졌다.

1. `monthly_rehearsal_limit`
   - 이제 실제 사용량과 잔여 수를 계산할 수 있다.
2. 첨삭권 출처 선택/우선순위
   - `credit_source_preference`, `remaining_credits`, `coaching_credit_usages`로 대응 가능하다.
3. `source_type polymorphic`
   - 구현 가능한 구조이며, 현재는 출처 추적과 우선순위 로직의 입력 데이터 역할을 한다.
