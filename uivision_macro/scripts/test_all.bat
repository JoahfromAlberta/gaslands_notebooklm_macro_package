@echo off
setlocal enableextensions

REM Make ROOT = repo root
for %%I in ("%~dp0\..") do set "ROOT=%%~fI"
pushd "%ROOT%" >nul

echo === Gaslands NotebookLM loop smoke test ===
echo [test_all] ROOT=%CD%

echo.
echo [test_all] 1) retrieve
call uivision_macro\scripts\retrieve.bat
if errorlevel 1 (
  echo [test_all] retrieve FAILED
  goto :fail
)

echo.
echo [test_all] 2) build (prompt.txt + clipboard best-effort)
powershell -NoProfile -ExecutionPolicy Bypass -File uivision_macro\scripts\build_prompt.ps1
if errorlevel 1 (
  echo [test_all] build FAILED
  goto :fail
)

echo.
echo [test_all] 3) seed clipboard and write last reply
call uivision_macro\scripts\write_last_reply.bat
if errorlevel 1 (
  echo [test_all] write FAILED
  goto :fail
)

echo.
echo [test_all] 4) ingest prompt.txt + last_reply.txt
call uivision_macro\scripts\ingest.bat
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo [test_all] ingest FAILED (RC=%RC%)
  powershell -NoProfile -Command "if (Test-Path '.\uivision_macro\ingest.log'){ Get-Content -Tail 60 .\uivision_macro\ingest.log }"
  goto :fail
) else (
  echo [test_all] ingest OK
)

echo.
echo [test_all] ALL GOOD
popd >nul
echo [ingest] OK (notebook=%NOTEBOOK_ID%)>>"%LOG%"
echo [ingest] DONE %DATE% %TIME%>>"%LOG%"
exit /b 0

:fail
popd >nul
exit /b 1
