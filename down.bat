@echo off

set /p choice="The volumes will be deleted. Are you sure you want to proceed? (y/n) "
if /i "%choice%"=="y" (
  where docker-compose >nul 2>&1
  if %errorlevel%==0 (
    set "prepend=docker-compose"
  ) else (
    set "prepend=docker compose"
  )

  %prepend% down -v
) else if /i "%choice%"=="n" (
  echo Execution cancelled.
) else (
  echo Invalid choice.
)
