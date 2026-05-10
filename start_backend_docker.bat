@echo off
setlocal

set "ROOT=%~dp0"
cd /d "%ROOT%"

echo [INFO] Checking Docker daemon...
docker info >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Docker Desktop is not running or Docker daemon is unavailable.
  echo [HINT] Start Docker Desktop first, then run this file again.
  pause
  exit /b 1
)

echo [INFO] Starting SpeakFlow with Docker Compose...
docker compose up -d --build
if errorlevel 1 (
  echo [ERROR] Failed to start Docker Compose services.
  pause
  exit /b 1
)

echo.
echo [DONE] SpeakFlow is starting in the background.
echo [DONE] Main page: http://127.0.0.1:3000
echo [DONE] Admin page: http://127.0.0.1:3000/admin
echo [DONE] Instructor page: http://127.0.0.1:3000/instructor
echo [DONE] API Lab: http://127.0.0.1:3000/api-lab
echo.
echo [TIP] To view logs, run logs_backend_docker.bat
echo [TIP] To stop everything, run stop_backend_docker.bat
pause
