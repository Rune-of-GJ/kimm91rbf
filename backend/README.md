# SpeakFlow Backend

SpeakFlow의 Rails 백엔드입니다.

## 권장 실행

루트에서 Docker Compose로 실행합니다.

가장 쉬운 방법:

- `../start_backend_docker.bat`

직접 명령:

```powershell
docker compose up -d --build
```

## 접속 경로

- 메인: `/`
- 관리자: `/admin`
- 강사: `/instructor`
- 멤버십: `/membership`
- 첨삭: `/coaching/products`
- API Lab: `/api-lab`
- 헬스체크: `/up`

## 종료

```powershell
docker compose down
```
