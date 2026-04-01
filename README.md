# SpeakFlow P1

온라인 스피치 학습 플랫폼 프로젝트입니다.

## 구조
- `backend/`: Rails 앱 본체
- `docs/`: 기획서, 요구사항, ERD, API 문서

## 권장 실행 방식
Docker Compose 기준으로 맞췄습니다.

## clone 후 실행
1. 저장소 clone
2. Docker Desktop 실행
3. 루트에서 아래 실행
```powershell
docker compose up --build
```
4. 브라우저 접속
- 메인: `http://127.0.0.1:3000`
- 백엔드 테스트: `http://127.0.0.1:3000/api-lab`

## 포함 서비스
- `web`: Rails app
- `db`: PostgreSQL 16

## DB 기본값
- host: `db`
- port: `5432`
- username: `postgres`
- password: `postgres`
- database: `speakflow_app_development`

## api-lab 사용
`/api-lab`에서 아래를 바로 검증할 수 있습니다.
1. 로그인
2. 카테고리 목록/상세 조회
3. 강의 목록/상세 조회
4. 수강 신청
5. 강의 영상 조회
6. 진도 저장
7. 내 강의 / 내 진도 조회

응답은 화면 아래 JSON 패널에 바로 표시됩니다.

## CI 검증
GitHub Actions에서 아래를 자동 검증합니다.
- `docker compose build`
- `docker compose up -d`
- `/up`, `/`, `/api-lab` smoke check

## 중지
```powershell
docker compose down
```

데이터 볼륨까지 지우려면:
```powershell
docker compose down -v
```

## 참고
- 첫 실행은 이미지 빌드와 gem 설치 때문에 시간이 걸릴 수 있습니다.
- 현재 기준 실행 경로는 Docker Compose입니다.
