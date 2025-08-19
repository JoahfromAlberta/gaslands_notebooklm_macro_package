@echo off
setlocal

rem --- Resolve paths ---
set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%\..") do set "UIMACRO=%%~fI"
for %%I in ("%UIMACRO%\..") do set "PROJECT=%%~fI"
set "RAG=%PROJECT%\rag"

rem --- Prefer venv python if present ---
if exist "%PROJECT%\.venv\Scripts\python.exe" (
  set "PY=%PROJECT%\.venv\Scripts\python.exe"
) else (
  set "PY=python"
)

rem --- Inputs/outputs ---
set "PROMPT=%UIMACRO%\prompt.txt"
set "REPLY=%UIMACRO%\last_reply.txt"
set "LOG=%UIMACRO%\ingest.log"

rem Default NOTEBOOK_ID if not provided
if "%NOTEBOOK_ID%"=="" set "NOTEBOOK_ID=d215e0a5-cc84-4fc1-bd0a-9e0bb7c0d3ad"

echo [ingest] PY      = %PY%
echo [ingest] PROJECT = %PROJECT%
echo [ingest] UIMACRO = %UIMACRO%
echo [ingest] RAG     = %RAG%
echo [ingest] PROMPT  = %PROMPT%
echo [ingest] REPLY   = %REPLY%
echo [ingest] LOG     = %LOG%
echo.

rem --- Guards ---
if not exist "%RAG%\ingest_run.py" (
  echo [ingest] ERROR: Missing "%RAG%\ingest_run.py"
  exit /b 10
)
if not exist "%PROMPT%" (
  echo [ingest] ERROR: Missing "%PROMPT%" (run build_prompt.ps1)
  exit /b 11
)
if not exist "%REPLY%" (
  echo [ingest] ERROR: Missing "%REPLY%" (run write_last_reply.bat)
  exit /b 12
)

rem --- Run (always log) ---
pushd "%RAG%" || (echo [ingest] ERROR: cannot cd to "%RAG%" & exit /b 13)

"%PY%" ingest_run.py --prompt "%PROMPT%" --reply "%REPLY%" --notebook "%NOTEBOOK_ID%" >"%LOG%" 2>&1
set "RC=%ERRORLEVEL%"
popd

echo [ingest] RC=%RC%
if not "%RC%"=="0" (
  echo [ingest] ERROR: Python returned %RC% (see "%LOG%")
  exit /b %RC%
)

for %%F in ("%LOG%") do echo [ingest] wrote "%%~fF" (%%~zF bytes)
echo [ingest] OK (notebook=%NOTEBOOK_ID%)
exit /b 0




