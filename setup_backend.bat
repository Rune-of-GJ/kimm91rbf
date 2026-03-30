@echo off
setlocal

set "ROOT=%~dp0"
set "BACKEND=%ROOT%backend"

if "%DB_HOST%"=="" set "DB_HOST=127.0.0.1"
if "%DB_PORT%"=="" set "DB_PORT=5432"

echo [INFO] Using PostgreSQL on %DB_HOST%:%DB_PORT%.

echo [INFO] Installing gems if needed...
cd /d "%BACKEND%"
bundle check >nul 2>&1
if errorlevel 1 bundle install
if errorlevel 1 (
  echo [ERROR] bundle install failed.
  pause
  exit /b 1
)

echo [INFO] Preparing database...
set "DB_HOST=%DB_HOST%"
set "DB_PORT=%DB_PORT%"
bundle exec rails db:prepare
if errorlevel 1 (
  echo [ERROR] Database prepare failed.
  echo [HINT] Check PostgreSQL service, username, password, and DB_PORT.
  pause
  exit /b 1
)

echo [INFO] Seeding database...
bundle exec rails db:seed
if errorlevel 1 (
  echo [ERROR] Database seed failed.
  pause
  exit /b 1
)

echo.
echo [DONE] Setup completed.
echo [DONE] DB_HOST=%DB_HOST%
echo [DONE] DB_PORT=%DB_PORT%
pause
