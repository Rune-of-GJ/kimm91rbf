# SpeakFlow

스피치 학습 플랫폼 프로젝트입니다.

## 구조

- `backend/`: Rails 애플리케이션
- `docs/`: 설계 문서와 개발 문서

## 가장 쉬운 실행

1. Docker Desktop 실행
2. 루트에서 `start_backend_docker.bat` 실행

접속 주소:

- 메인: `http://127.0.0.1:3000`
- 관리자: `http://127.0.0.1:3000/admin`
- 강사: `http://127.0.0.1:3000/instructor`
- API Lab: `http://127.0.0.1:3000/api-lab`

## 직접 명령으로 실행

```powershell
docker compose up -d --build
```

## 종료

```powershell
docker compose down
```

또는 `stop_backend_docker.bat`

## 로그 확인

```powershell
docker compose logs -f web
```

또는 `logs_backend_docker.bat`
