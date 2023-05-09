@echo off
setlocal

rem decide what program to use
where docker-compose >nul 2>&1
if %errorlevel% equ 0 (
  set "prepend=docker-compose"
) else (
  set "prepend=docker compose"
)

%prepend% stop
