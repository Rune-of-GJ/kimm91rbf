# SpeakFlow P1 배포 가이드

## 개요
SpeakFlow P1은 Ruby on Rails 기반의 온라인 스피치 강의 플랫폼입니다.

## 시스템 요구사항
- Ruby 3.4.0
- Rails 8.1
- PostgreSQL 13+
- Node.js 18+ (자바스크립트 런타임용)

## 설치 절차

### 1. 저장소 클론
```bash
git clone <repository-url>
cd kimm91rbf/backend
```

### 2. Ruby 및 Rails 설치
```bash
# Ruby 설치 (ruby-installer 또는 rbenv 권장)
# Rails 설치
gem install rails
```

### 3. PostgreSQL 설치 및 설정
```bash
# PostgreSQL 설치 후 서비스 실행
# 데이터베이스 생성
createdb speakflow_app_development
createdb speakflow_app_test
```

### 4. 의존성 설치
```bash
bundle install
```

### 5. 환경 설정
```bash
# .env 파일 복사 및 설정
cp .env.example .env
# .env 파일의 DB 설정을 실제 환경에 맞게 수정
```

### 6. 데이터베이스 설정
```bash
# 데이터베이스 생성
rails db:create

# 마이그레이션 실행
rails db:migrate

# 시드 데이터 로드 (샘플 데이터)
rails db:seed
```

### 7. Rails 서버 실행
```bash
rails server
```

서버가 http://localhost:3000 에서 실행됩니다.

## 환경 변수 설명
- `DB_HOST`: PostgreSQL 호스트 (기본: 127.0.0.1)
- `DB_PORT`: PostgreSQL 포트 (기본: 5432)
- `DB_USERNAME`: DB 사용자명
- `DB_PASSWORD`: DB 비밀번호
- `DB_NAME_DEVELOPMENT`: 개발 DB 이름
- `DB_NAME_TEST`: 테스트 DB 이름

## 추가 파일 설명
- `.env`: 환경 변수 설정 파일
- `config/database.yml`: 데이터베이스 연결 설정
- `config/credentials.yml.enc`: Rails 암호화된 인증 정보

## 테스트 실행
```bash
rails test
```

## 문제 해결
- PostgreSQL 연결 오류: .env 파일의 DB 설정 확인
- Ruby 버전 오류: .ruby-version 파일 확인
- 의존성 오류: bundle install 재실행</content>
<parameter name="filePath">c:\Users\kimm9\OneDrive\Documents\Grade 3\GBSW_project_vibe\kimm91rbf\deployment-guide.md