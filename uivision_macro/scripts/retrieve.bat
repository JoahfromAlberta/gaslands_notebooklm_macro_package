@echo off
setlocal

set "SCRIPTDIR=%~dp0"
set "UIMACRO=%SCRIPTDIR%.."
for %%I in ("%UIMACRO%") do set "UIMACRO=%%~fI"
set "PROJECT=%UIMACRO%\.."
for %%I in ("%PROJECT%") do set "PROJECT=%%~fI"
set "RAG=%PROJECT%\rag"
set "OUT=%UIMACRO%\retrieved_context.txt"

REM Pick python from venv if present
if exist "%PROJECT%\.venv\Scripts\python.exe" (
  set "PY=%PROJECT%\.venv\Scripts\python.exe"
) else (
  set "PY=python"
)

echo [retrieve.bat] PROJECT=%PROJECT%
echo [retrieve.bat] UIMACRO=%UIMACRO%
echo [retrieve.bat] RAG    =%RAG%
echo [retrieve.bat] OUT    =%OUT%

REM Guards
if not exist "%RAG%\retrieve.py" (
  echo [retrieve.bat] ERROR: Missing "%RAG%\retrieve.py"
  exit /b 1
)

REM --- Run actual Python script ---
"%PY%" "%RAG%\retrieve.py" ^
  --query-file "%UIMACRO%\comment.txt" ^
  --out "%OUT%" ^
  --k 5 > "%UIMACRO%\retrieve.log" 2>&1

set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
  echo [retrieve.bat] ERROR: Python returned %RC% (see %UIMACRO%\retrieve.log)
  exit /b %RC%
)

if not exist "%OUT%" (
  echo [retrieve.bat] ERROR: Expected output not written: "%OUT%"
  exit /b 1
)

echo [retrieve.bat] OK -> "%OUT%"
exit /b 0

















