@echo off
setlocal enabledelayedexpansion
REM ingest.bat — feed prompt.txt + last_reply.txt into rag\ingest_run.py and log output

REM --- Resolve paths (absolute) ---
set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%..") do set "UIMACRO=%%~fI"
for %%I in ("%UIMACRO%\..") do set "PROJECT=%%~fI"
set "RAG=%PROJECT%\rag"

REM --- Prefer venv python if available ---
if exist "%PROJECT%\.venv\Scripts\python.exe" (
  set "PY=%PROJECT%\.venv\Scripts\python.exe"
) else (
  set "PY=python"
)

REM --- Inputs & log ---
set "PROMPT=%UIMACRO%\prompt.txt"
set "REPLY=%UIMACRO%\last_reply.txt"
set "LOG=%UIMACRO%\ingest.log"

REM --- Notebook ID (allow override by env) ---
if not defined NOTEBOOK_ID set "NOTEBOOK_ID=d215e0a5-cc84-4fc1-bd0a-9e0bb7c0d3ad"

echo [ingest] PY      = %PY%
echo [ingest] PROJECT = %PROJECT%
echo [ingest] UIMACRO = %UIMACRO%
echo [ingest] RAG     = %RAG%
echo [ingest] PROMPT  = %PROMPT%
echo [ingest] REPLY   = %REPLY%
echo [ingest] LOG     = %LOG%

REM --- Guards ---
if not exist "%RAG%\ingest_run.py" (
  echo [ingest] ERROR: Missing "%RAG%\ingest_run.py"
  exit /b 1
)
if not exist "%PROMPT%" (
  echo [ingest] ERROR: Missing "%PROMPT%" (run build first)
  exit /b 1
)
if not exist "%REPLY%" (
  echo [ingest] ERROR: Missing "%REPLY%" (run write first)
  exit /b 1
)

REM --- Run (capture stdout+stderr to LOG) ---
pushd "%PROJECT%"
"%PY%" "%RAG%\ingest_run.py" ^
  --prompt "%PROMPT%" ^
  --reply "%REPLY%" ^
  --notebook "%NOTEBOOK_ID%" ^
  *> "%LOG%"
set "RC=%ERRORLEVEL%"
popd

if not "%RC%"=="0" (
  echo [ingest] ERROR: Python returned %RC% (see "%LOG%")
  exit /b %RC%
)

echo [ingest] OK (see "%LOG%")
exit /b 0







