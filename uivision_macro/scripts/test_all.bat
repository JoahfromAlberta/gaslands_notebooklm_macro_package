@echo off
setlocal enableextensions

rem Always call sibling scripts via absolute path; no pushd needed.
set "SCRIPTS=%~dp0"

echo === Gaslands NotebookLM loop smoke test ===
echo [test_all] SCRIPTS=%SCRIPTS%

echo.
echo [test_all] 1) retrieve
call "%SCRIPTS%retrieve.bat"
if errorlevel 1 (
  echo [test_all] retrieve FAILED
  goto :fail
)

echo.
echo [test_all] 2) build (prompt.txt + clipboard best-effort)
powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%build_prompt.ps1"
if errorlevel 1 (
  echo [test_all] build FAILED
  goto :fail
)

echo.
echo [test_all] 3) seed clipboard and write last reply
call "%SCRIPTS%write_last_reply.bat"
if errorlevel 1 (
  echo [test_all] write FAILED
  goto :fail
)

echo.
echo [test_all] 4) ingest prompt.txt + last_reply.txt
call "%SCRIPTS%ingest.bat"
if errorlevel 1 (
  echo [test_all] ingest FAILED
  goto :fail
)

echo.
echo [test_all] ingest OK
echo [test_all] ALL GOOD
exit /b 0

:fail
exit /b 1

