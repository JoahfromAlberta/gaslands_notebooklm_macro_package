@echo off
rem run_from_root.bat  (usage: run_from_root.bat retrieve|build|write|ingest)
setlocal enabledelayedexpansion
set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%\..\..") do set "ROOT=%%~fI"

if /i "%~1"=="retrieve" (
  call "%ROOT%\uivision_macro\scripts\retrieve.bat"
) else if /i "%~1"=="build" (
  powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\uivision_macro\scripts\build_prompt.ps1"
) else if /i "%~1"=="write" (
  call "%ROOT%\uivision_macro\scripts\write_last_reply.bat"
) else if /i "%~1"=="ingest" (
  call "%ROOT%\uivision_macro\scripts\ingest.bat"
) else (
  echo Usage: run_from_root.bat [retrieve|build|write|ingest] & exit /b 1
)
