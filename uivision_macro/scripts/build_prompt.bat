





@echo off
setlocal enableextensions

set "SCRIPTDIR=%~dp0"
set "UIMACRO=%SCRIPTDIR%.."
for %%I in ("%UIMACRO%") do set "UIMACRO=%%~fI"

set "PS1=%SCRIPTDIR%build_prompt.ps1"
set "PROMPT=%UIMACRO%\prompt.txt"

rem Use the PS1 if present; otherwise inline PowerShell fallback
if exist "%PS1%" (
  powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS1%"
) else (
  powershell.exe -NoProfile -ExecutionPolicy Bypass ^
    -Command "$rc=Join-Path '%UIMACRO%' 'retrieved_context.txt';" ^
             "$q =Join-Path '%UIMACRO%' 'comment.txt';" ^
             "$p =Join-Path '%UIMACRO%' 'prompt.txt';" ^
             "$ctx=(Test-Path $rc)?(Get-Content $rc -Raw):'';" ^
             "$qry=(Test-Path $q )?(Get-Content $q  -Raw):'';" ^
             "$body = \"### Context`r`n$ctx`r`n### Query`r`n$qry\";" ^
             "Set-Content -NoNewline -Encoding UTF8 $p $body;" ^
             "Get-Content $p -Raw | Set-Clipboard"
)

if errorlevel 1 (
  echo [build_prompt.bat] ERROR
  exit /b 1
)

echo [build_prompt.bat] OK ^> "%PROMPT%" (copied to clipboard)
exit /b 0
