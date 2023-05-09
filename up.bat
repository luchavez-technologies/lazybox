@echo off
setlocal

set "shell="

if "%~1"=="" (
  set /p input="Please enter PHP container (default: php): "

  if "%input%"=="" (
    set "input=php"
  )
  
  set "shell=%input%"
) else (
  set "input=%*"
  set "shell=%1"
)

rem make sure shell variable starts with php
echo %shell% | findstr /r /c:"^php" >nul || set "shell=php"

rem decide what program to use
where docker-compose >nul 2>&1
if %errorlevel% equ 0 (
  set "prepend=docker-compose"
) else (
  set "prepend=docker compose"
)

%prepend% up php httpd bind %input% -d
%prepend% exec --user devilbox %shell% /bin/sh -c "cd /shared/httpd; exec bash -l"
