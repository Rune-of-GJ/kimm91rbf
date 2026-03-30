@echo off
setlocal

set "ROOT=%~dp0"
set "BACKEND=%ROOT%backend"
set "RAILS_PORT=3000"

if "%DB_HOST%"=="" set "DB_HOST=127.0.0.1"
if "%DB_PORT%"=="" set "DB_PORT=5432"

echo [INFO] Using PostgreSQL on %DB_HOST%:%DB_PORT%.

echo [INFO] Checking Rails server on port %RAILS_PORT%...
netstat -ano | findstr ":%RAILS_PORT%" >nul
if errorlevel 1 (
  echo [INFO] Starting Rails server in a new window...
  start "SpeakFlow Rails" /D "%BACKEND%" cmd /k "set DB_HOST=%DB_HOST% && set DB_PORT=%DB_PORT% && bundle exec rails s -b 127.0.0.1 -p %RAILS_PORT%"
) else (
  echo [INFO] Rails server already running.
)

echo.
echo [DONE] Open http://127.0.0.1:%RAILS_PORT%
echo [DONE] API test page: http://127.0.0.1:%RAILS_PORT%/api-lab
echo [DONE] DB_PORT=%DB_PORT%
pause
