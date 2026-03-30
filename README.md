# SpeakFlow P1

온라인 스피치 학습 플랫폼 프로젝트입니다.

## 구조
- `backend/`: Rails 앱 본체
- `frontend/`: 디자인 시안 보관용 폴더
- `docs/`: 기획서, 요구사항, ERD, API 문서

## 요구 환경
- Ruby 3.4.x
- Bundler 2.6.x
- PostgreSQL

## clone 후 실행
1. 저장소 clone
2. PostgreSQL 실행
3. 루트에서 `setup_backend.bat` 실행
4. 루트에서 `start_backend.bat` 실행

접속 주소:
- 메인: `http://127.0.0.1:3000`
- 백엔드 테스트: `http://127.0.0.1:3000/api-lab`

## DB 기본값
- `DB_HOST=127.0.0.1`
- `DB_PORT=5432`
- 필요하면 실행 전에 환경변수로 덮어쓸 수 있습니다. 예시는 `backend/.env.example` 참고.

예시:
```powershell
$env:DB_PORT='55432'
.\setup_backend.bat
.\start_backend.bat
```

## 수동 실행
```powershell
cd backend
bundle install
bundle exec rails db:prepare db:seed
bundle exec rails s -b 127.0.0.1 -p 3000
```
