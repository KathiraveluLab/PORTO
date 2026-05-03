@echo off
setlocal enabledelayedexpansion

:: Get the directory where the script is located
set "SCRIPT_DIR=%~dp0"

echo ------------------------------------------------
echo PORTO Cleanup ^& Reset Utility (Windows)
echo ------------------------------------------------
echo This script will PERMANENTLY DELETE:
echo 1. Erlang build artifacts (core\_build)
echo 2. Local orchestration state (core\data)
echo 3. Leo circuit build artifacts (build\ and outputs\)
echo 4. Benchmark kernel binaries (circuits\heavy_workload.exe)
echo.

set /p confirm="Are you sure you want to proceed? (y/N): "
if /i "%confirm%" neq "y" (
    echo Cleanup cancelled.
    exit /b 0
)

echo.
echo [1/5] Cleaning Erlang build artifacts...
if exist "%SCRIPT_DIR%core\_build" rd /s /q "%SCRIPT_DIR%core\_build"

echo [2/5] Resetting local orchestration state (Mnesia)...
if exist "%SCRIPT_DIR%core\data" rd /s /q "%SCRIPT_DIR%core\data"

echo [3/5] Cleaning Leo circuit artifacts...
:: Recursively find and remove all 'build' and 'outputs' folders inside 'circuits' paths
for /d /r "%SCRIPT_DIR%" %%d in (build outputs) do (
    echo "%%d" | findstr /i "circuits" >nul
    if !errorlevel! equ 0 (
        if exist "%%d" (
            echo Deleting "%%d"
            rd /s /q "%%d"
        )
    )
)

echo [4/5] Removing benchmark kernel binaries...
if exist "%SCRIPT_DIR%circuits\heavy_workload.exe" del /f /q "%SCRIPT_DIR%circuits\heavy_workload.exe"

echo [5/5] Performing ASCII-Safety Scan...
powershell -Command "$bad = Get-ChildItem -Recurse -File -Path '%SCRIPT_DIR%core', '%SCRIPT_DIR%circuits', '%SCRIPT_DIR%examples' | Select-String -Pattern '—'; if ($bad) { Write-Host 'WARNING: Non-ASCII characters (em-dashes) detected!' -ForegroundColor Yellow; $bad | Format-List Filename, LineNumber, Line; } else { Write-Host 'ASCII-Safety Scan: Pass (No em-dashes found).' -ForegroundColor Green }"

echo.
echo ------------------------------------------------
echo Cleanup Complete!
echo You can now run setup_porto.bat or rebar3 compile for a fresh start.
echo ------------------------------------------------
pause
