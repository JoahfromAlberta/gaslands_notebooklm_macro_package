@echo off
REM ---------------------------------------------------------------------------
REM write_last_reply.bat  — writes clipboard text to uivision_macro\last_reply.txt
REM No VBScript. Uses PowerShell with retries. Exits 0 on success, 1 on failure.
REM ---------------------------------------------------------------------------

setlocal enabledelayedexpansion

REM Figure out repo root: scripts\..\.. = project root
set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%\..\..") do set "ROOT=%%~fI"

set "OUT=%ROOT%\uivision_macro\last_reply.txt"

echo [write_last_reply.bat] ROOT=%ROOT%
echo [write_last_reply.bat] OUT = %OUT%

REM Use PowerShell to read clipboard with retries and write UTF-8 file
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass ^
  " $max=12; $ok=$false; for($i=0;$i -lt $max;$i++){ try{ Start-Sleep -Milliseconds 200; $c=Get-Clipboard -Raw; if($null -ne $c -and $c.Length -gt 0){ $c | Set-Content -Encoding UTF8 '%OUT%'; Write-Host '[write_last_reply.bat] Wrote %OUT% (' + $c.Length + ' chars)'; $ok=$true; break } } catch { Start-Sleep -Milliseconds 250 } }; if(-not $ok){ Write-Error 'Clipboard empty or busy after retries'; exit 1 } "

set ERR=%ERRORLEVEL%
if not "%ERR%"=="0" (
  echo [write_last_reply.bat] ERROR: Could not capture clipboard.
  exit /b 1
)

echo [write_last_reply.bat] OK
exit /b 0




