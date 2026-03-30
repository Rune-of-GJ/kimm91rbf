# Frontend App

실제 프론트 앱 구조입니다.

## 실행
1. Rails backend 실행
2. 새 터미널에서 아래 실행

```powershell
cd D:\3thgrade\pj\frontend\app
node server.mjs
```

기본 주소:
- `http://127.0.0.1:4173`

## 구조
- `assets/`: 공통 스타일
- `src/api/`: 백엔드 API 호출 모듈
- `src/components/`: 공통 레이아웃/렌더링
- `src/pages/`: 페이지별 로직
- `*.html`: 실제 페이지 엔트리
- `server.mjs`: 정적 파일 서버 + `/api` 프록시

## 주의
- 프론트는 현재 `backend` API 응답 필드만 사용합니다.
- DB/API에 없는 값은 화면에 추가하지 않습니다.
