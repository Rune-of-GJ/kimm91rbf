@echo off
setlocal

set "ROOT=%~dp0"
cd /d "%ROOT%"

echo [INFO] Stopping SpeakFlow Docker services...
docker compose down
if errorlevel 1 (
  echo [ERROR] Failed to stop Docker Compose services.
  pause
  exit /b 1
)

echo [DONE] SpeakFlow Docker services stopped.
pause
