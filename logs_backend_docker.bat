@echo off
setlocal

set "ROOT=%~dp0"
cd /d "%ROOT%"

echo [INFO] Streaming SpeakFlow web logs...
docker compose logs -f web
