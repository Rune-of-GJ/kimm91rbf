# SpeakFlow P2 UI/UX 설계

## 문서 기준

이 문서는 `2026-05-07` 기준 실제 화면 구조를 정리한다.

중요:

- 현재 존재하는 실제 화면과
- 아직 UI로 노출되지 않은 정책

을 구분해서 적는다.

---

## 프론트엔드 기술

| 기술 | 역할 |
|------|------|
| ERB | 서버 렌더링 |
| Stimulus.js | 선택 연동, 패널 토글, 토스트 등 |
| Vanilla CSS | 디자인 시스템과 페이지 레이아웃 |

---

## 현재 실제 페이지 구조

```text
학생
/
/categories
/courses
/courses/:id
/my-courses
/progress
/login
/membership
/membership/plans
/membership/checkout
/membership/account
/coaching/products
/coaching/request
/coaching/requests

강사
/instructor
/instructor/courses/new
/instructor/courses/:course_id/lectures/new
/instructor/courses/:course_id/lectures/:id/edit
/instructor/coaching/queue
/instructor/coaching/requests/:id

관리자
/admin
/admin/setup
/admin/users
```

---

## 학생 UX

### 멤버십 없음

- 강의 상세에서 멤버십 유도
- `/membership`, `/membership/plans`, `/membership/checkout` 진입 가능
- 첨삭 상품 페이지 진입 가능

### 멤버십 있음

- 멤버십 기준 강의 시청 가능
- `/membership/account`에서 플랜 변경 / 해지 가능
- Coach 포함 크레딧 또는 별도 구매 크레딧으로 첨삭 요청 가능

### 첨삭 흐름

1. 첨삭 상품 페이지 진입
2. 필요 시 첨삭권 구매
3. 첨삭 요청 작성
4. 내 요청 목록에서 상태 확인
5. 강사 완료 후 결과 열람

---

## 강사 UX

- 강사 홈에서 자기 강의 확인
- 강의 등록
- 강의편 추가 / 수정
- 첨삭 대기열 확인
- 첨삭 리뷰 작성과 완료 처리

---

## 관리자 UX

- 최초 관리자 계정 생성
- 관리자 대시보드
- 사용자 목록 확인
- 역할 변경
- 사용자 삭제

---

## 현재 UI에서 이미 반영된 정책

### 1. 강의편 선택은 대상 강의 기반

`/coaching/request`에서 사용자는 먼저 대상 강의를 고른다.

그 다음:

- 선택한 강의에 속한 강의편만 표시된다.
- 강의를 고르기 전에는 강의편 셀렉트가 비활성화된다.

이 동작은 `coaching_request_controller`가 담당한다.

### 2. 첨삭 잔액은 실제 사용 가능 잔액 기준

멤버십 화면과 첨삭 상품 화면의 잔액 표시는 더 이상 단순 원장 합계가 아니라,

- 사용 가능한 `remaining_credits`
- 만료되지 않은 적립 건

을 기준으로 보여준다.

---

## 현재 UI에 아직 없는 정책

## 1. 리허설 잔여 개수 노출

백엔드에는 이제 아래 계산값이 존재한다.

- 이번 달 리허설 사용량
- 현재 플랜 기준 남은 리허설 수

하지만 아직 학생 화면에는 다음 UI가 없다.

- `이번 달 3개 남음`
- `오늘까지 1개 사용`
- `다음 초기화까지 5일`

즉 현재 `/membership/plans`와 관련 화면에서 보이는 리허설 수는

- 플랜 정책값 설명
- 예: `월 4회`, `월 12회`, `무제한`

수준이다.

## 2. 첨삭권 출처 선택 UI

백엔드는 이제 다음 값을 저장할 수 있다.

- `membership_first`
- `purchase_first`
- `oldest_first`

또한 어떤 적립 엔트리에서 실제 차감되었는지도 기록할 수 있다.

하지만 현재 UI에는 아직 없다.

- "구독 포함 크레딧 먼저 사용"
- "별도 구매 크레딧 먼저 사용"
- "이번 요청은 이 크레딧에서 차감"

같은 직접 선택 컴포넌트는 추후 추가 대상이다.

현재 실제 동작:

- 화면에는 총 잔액만 보인다.
- 서버 기본 우선순위는 `membership_first`다.

---

## 현재 주요 화면

## 1. 멤버십

### `/membership`

- 월정액 구조 소개
- 추천 흐름 안내
- 비교/가입 페이지 진입

### `/membership/plans`

- Lite / Pro / Coach 비교
- 가격
- 강의 시청 범위
- 리허설 정책값
- 포함 첨삭 여부

### `/membership/checkout`

- 선택 플랜 요약
- 가격
- 다음 결제 예정일
- 포함 혜택 요약
- 멤버십 시작 버튼

### `/membership/account`

- 활성 구독 상태
- 다음 결제일
- 월 요금
- 첨삭 잔액
- 플랜 변경
- 멤버십 해지
- 최근 구독 기록
- 최근 첨삭 요청

---

## 2. 첨삭 상품 / 요청

### `/coaching/products`

- 현재 활성 멤버십
- 현재 사용 가능 첨삭 잔액
- 별도 구매 상품 목록
- 구매 버튼

### `/coaching/request`

현재 폼 구성:

1. 요청 제목
2. 대상 강의
3. 대상 강의편
4. 음성 파일명 또는 링크
5. 메모

백엔드에 이미 있으나 아직 UI에 안 나온 것:

- 첨삭권 출처 우선순위 선택

### `/coaching/requests`

- 요청 상태
- 요청 제목
- 대상 강의 / 강의편
- 사용한 첨삭 라벨
- 강사 총평
- 타임코드 코멘트

---

## 3. 강사 첨삭 화면

### `/instructor/coaching/queue`

- 학생명
- 요청 제목
- 요청일
- 첨삭 라벨
- 상태

### `/instructor/coaching/requests/:id`

- 학생명
- 요청 제목
- 대상 강의 / 강의편
- 음성 파일명 또는 링크
- 학생 메모
- 타임코드 코멘트 입력
- 총평 입력
- 완료 처리

현재 한계:

- 자동 배정 UI 없음
- 강사가 전체 요청을 같은 큐에서 보는 구조

---

## 4. 강사 강의 등록 화면

### `/instructor/courses/new`

- 제목
- 설명
- 카테고리
- 수강 신청 마감일
- 강의 시작일
- 강의 종료일
- 썸네일 파일 업로드

기본값:

- 수강 신청 마감일: 오늘 기준 10년 뒤
- 강의 시작일: 오늘
- 강의 종료일: 오늘 기준 10년 뒤

---

## 현재 Stimulus 컨트롤러

| 컨트롤러 | 역할 |
|----------|------|
| `auth_controller` | 로그인 / 회원가입 전환 |
| `shell_controller` | 사용자 패널 / 모바일 메뉴 |
| `flash_controller` | 하단 토스트 자동 닫힘 |
| `lecture_player_controller` | 강의 플레이어 상태 |
| `tabs_controller` | 탭 전환 |
| `coaching_request_controller` | 강의 선택에 따른 강의편 필터링 |

---

## UI 후속 과제

### 우선순위 높음

- 관리자 강의 관리 실제 화면
- 관리자 카테고리 관리 화면
- 첨삭 요청 자동 배정 UX

### 정책을 UI로 올리는 작업

- 리허설 잔여 수 노출
- 첨삭권 출처 우선순위 선택 UI
- 출처별 잔액 분리 표시
- 만료 예정 크레딧 안내

---

## 요약

현재 UI는 다음 수준까지 올라와 있다.

- 학생: 멤버십, 첨삭권 구매, 첨삭 요청, 결과 확인
- 강사: 강의 등록, 강의편 관리, 첨삭 처리
- 관리자: 진입, 계정 생성, 사용자 관리

그리고 이번 피드백 반영으로 중요한 상태가 하나 생겼다.

- 백엔드는 리허설 잔여 수와 첨삭권 출처를 계산/저장할 수 있게 되었고
- UI는 아직 그것을 직접 보여주거나 고르게 하지는 않는다

즉 다음 단계는 화면에 그 정책을 꺼내는 일이다.
