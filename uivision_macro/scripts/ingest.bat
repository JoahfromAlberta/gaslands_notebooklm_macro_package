@echo off
setlocal enabledelayedexpansion

rem ingest.bat — feed prompt.txt + last_reply.txt into rag\ingest_run.py

rem Self (for debugging)
echo [ingest] SELF     = %~f0

rem --- Resolve paths ---
set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%\..") do set "UIMACRO=%%~fI"
for %%I in ("%UIMACRO%\..") do set "PROJECT=%%~fI"
set "RAG=%PROJECT%\rag"

rem Prefer venv python
if exist "%PROJECT%\.venv\Scripts\python.exe" (
  set "PY=%PROJECT%\.venv\Scripts\python.exe"
) else (
  set "PY=python"
)

set "PROMPT=%UIMACRO%\prompt.txt"
set "REPLY=%UIMACRO%\last_reply.txt"
set "LOG=%UIMACRO%\ingest.log"

if not defined NOTEBOOK_ID set "NOTEBOOK_ID=d215e0a5-cc84-4fc1-bd0a-9e0bb7c0d3ad"

echo [ingest] PY      = %PY%
echo [ingest] PROJECT = %PROJECT%
echo [ingest] UIMACRO = %UIMACRO%
echo [ingest] RAG     = %RAG%
echo [ingest] PROMPT  = %PROMPT%
echo [ingest] REPLY   = %REPLY%
echo [ingest] LOG     = %LOG%

rem --- Guards ---
if not exist "%RAG%\ingest_run.py" (
  echo [ingest] ERROR: Missing "%RAG%\ingest_run.py"
  exit /b 1
)
if not exist "%PROMPT%" (
  echo [ingest] ERROR: Missing "%PROMPT%" (run build_prompt.ps1 first)
  exit /b 1
)
if not exist "%REPLY%" (
  echo [ingest] ERROR: Missing "%REPLY%" (run write_last_reply.bat first)
  exit /b 1
)

rem --- Run and log ---
(
  echo ===== %DATE% %TIME% : ingest starting =====
  echo PROMPT="%PROMPT%"
  echo REPLY ="%REPLY%"
  echo NOTEBOOK="%NOTEBOOK_ID%"
  "%PY%" "%RAG%\ingest_run.py" ^
    --prompt "%PROMPT%" ^
    --reply  "%REPLY%" ^
    --notebook "%NOTEBOOK_ID%"
  set "RC=!ERRORLEVEL!"
  echo EXIT_CODE=!RC!
  echo ===== end =====
) > "%LOG%" 2>&1

for /f "usebackq tokens=2 delims==" %%E in ("%LOG%") do set "RC=%%E"
if not defined RC set "RC=1"

if not "%RC%"=="0" (
  echo [ingest] ERROR: Python returned %RC% (see "%LOG%")
  exit /b %RC%
)

echo [ingest] OK (notebook=%NOTEBOOK_ID%)
exit /b 0






