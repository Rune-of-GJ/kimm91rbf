# SpeakFlow P1

프로젝트를 역할 기준으로 분리했습니다.

## 구조
- `frontend/`: 정적 디자인 시안과 화면 목업
- `backend/`: Rails API 및 서버 렌더링 앱
- `docs/`: 기획/요구사항 문서

## 실행
1. PostgreSQL 실행
2. `cd backend`
3. `bundle install`
4. `bundle exec rails db:create db:migrate db:seed`
5. `bundle exec rails server`

정적 시안은 `frontend/designs/service-design`에서 확인할 수 있습니다.
