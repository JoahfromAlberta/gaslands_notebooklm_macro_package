@echo off
setlocal
echo === Gaslands NotebookLM loop smoke test ===

REM Derive repo root from this script
set "SCRIPTDIR=%~dp0"
for %%I in ("%SCRIPTDIR%\..\..") do set "ROOT=%%~fI"

echo [test_all] ROOT=%ROOT%

echo.
echo [test_all] 1) retrieve
call "%SCRIPTDIR%run_from_root.bat" retrieve || (echo [test_all] retrieve FAILED & exit /b 1)

echo.
echo [test_all] 2) build (prompt.txt + clipboard best-effort)
call "%SCRIPTDIR%run_from_root.bat" build || (echo [test_all] build FAILED & exit /b 1)

echo.
echo [test_all] 3) seed clipboard and write last reply
echo LOCAL_SMOKE_TEST | clip
call "%SCRIPTDIR%run_from_root.bat" write || (echo [test_all] write FAILED & exit /b 1)

echo.
echo [test_all] 4) ingest prompt.txt + last_reply.txt
call "%SCRIPTDIR%run_from_root.bat" ingest || (echo [test_all] ingest FAILED & exit /b 1)

echo.
echo [test_all] verify files:
if not exist "%ROOT%\uivision_macro\prompt.txt"  (echo [test_all] missing prompt.txt & exit /b 1)
if not exist "%ROOT%\uivision_macro\last_reply.txt" (echo [test_all] missing last_reply.txt & exit /b 1)
for %%F in ("%ROOT%\uivision_macro\prompt.txt" "%ROOT%\uivision_macro\last_reply.txt") do (
  for %%A in (%%F) do echo  - %%~nxF (%%~zA bytes)
)

echo.
echo === ALL OK ===
exit /b 0
