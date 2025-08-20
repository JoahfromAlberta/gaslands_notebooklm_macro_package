@echo off
setlocal enableextensions enabledelayedexpansion

REM --- Resolve paths ---
set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%\..") do set "UIMACRO=%%~fI"
for %%I in ("%UIMACRO%\..") do set "PROJECT=%%~fI"
set "RAG=%PROJECT%\rag"

REM --- Prefer venv Python if available ---
if exist "%PROJECT%\.venv\Scripts\python.exe" (
  set "PY=%PROJECT%\.venv\Scripts\python.exe"
) else (
  set "PY=python"
)

REM --- Inputs / outputs ---
set "PROMPT=%UIMACRO%\prompt.txt"
set "REPLY=%UIMACRO%\last_reply.txt"
set "LOG=%UIMACRO%\ingest.log"

REM Notebook ID (env NOTEBOOK_ID wins; else default)
if "%NOTEBOOK_ID%"=="" set "NOTEBOOK_ID=d215e0a5-cc84-4fc1-bd0a-9e0bb7c0d3ad"

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
  exit /b 2
)
if not exist "%PROMPT%" (
  echo [ingest] ERROR: Missing "%PROMPT%" (run build_prompt first)
  exit /b 2
)
if not exist "%REPLY%" (
  echo [ingest] ERROR: Missing "%REPLY%" (run write_last_reply first)
  exit /b 2
)

REM --- Run and log (stdout+stderr) ---
pushd "%PROJECT%" >nul
"%PY%" "%RAG%\ingest_run.py" ^
  --prompt "%PROMPT%" ^
  --reply "%REPLY%" ^
  --notebook "%NOTEBOOK_ID%" ^
  --status "local" >>"%LOG%" 2>&1
set "RC=%ERRORLEVEL%"
popd >nul

if not "%RC%"=="0" (
  echo [ingest] ERROR: Python returned %RC% (see %LOG%)
  exit /b %RC%
)

echo [ingest] OK (notebook=%NOTEBOOK_ID%)
exit /b 0








