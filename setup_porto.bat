@echo off
setlocal enabledelayedexpansion

:: Get the directory where the script is located
set "SCRIPT_DIR=%~dp0"

echo ------------------------------------------------
echo Starting PORTO ^& Leo Environment Setup (Windows)
echo ------------------------------------------------

:: 1. Chocolatey Installation
where choco >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [1/6] Chocolatey not found. Attempting to install...
    powershell -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
    if %ERRORLEVEL% neq 0 (
        echo Error: Failed to install Chocolatey. Please run this script as Administrator.
        exit /b 1
    )
) else (
    echo [1/6] Chocolatey is already installed.
)

:: 2. System Dependencies via Choco
echo [2/6] Installing dependencies via Chocolatey...
choco install git erlang rustup-init openssl -y

:: 3. Rust Environment Setup
echo [3/6] Initializing Rust environment...
where cargo >nul 2>nul
if %ERRORLEVEL% neq 0 (
    rustup-init.exe -y
    set "PATH=%PATH%;%USERPROFILE%\.cargo\bin"
)

:: 4. Erlang Build Tooling (Rebar3)
echo [4/6] Setting up Rebar3...
:: Verify if rebar3 exists AND if it actually works (checks for BEAM compatibility)
rebar3 --version >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Rebar3 not found or incompatible. Bootstrapping from source for OTP compatibility...
    
    :: Remove existing broken version if it exists
    if exist "%USERPROFILE%\.local\bin\rebar3" del /f /q "%USERPROFILE%\.local\bin\rebar3"
    if exist "%USERPROFILE%\.local\bin\rebar3.cmd" del /f /q "%USERPROFILE%\.local\bin\rebar3.cmd"
    
    if not exist "%USERPROFILE%\.local\bin" mkdir "%USERPROFILE%\.local\bin"
    
    set "TMP_REBAR=%TEMP%\rebar3_build"
    if exist "!TMP_REBAR!" rd /s /q "!TMP_REBAR!"
    mkdir "!TMP_REBAR!"
    
    pushd "!TMP_REBAR!"
    git clone --depth 1 https://github.com/erlang/rebar3.git
    cd rebar3
    escript bootstrap
    move rebar3 "%USERPROFILE%\.local\bin\rebar3"
    popd
    rd /s /q "!TMP_REBAR!"

    :: Create rebar3.cmd wrapper
    echo @echo off > "%USERPROFILE%\.local\bin\rebar3.cmd"
    echo escript "%%~dp0rebar3" %%* >> "%USERPROFILE%\.local\bin\rebar3.cmd"
    set "PATH=%PATH%;%USERPROFILE%\.local\bin"
) else (
    echo Rebar3 is already installed and compatible.
)

:: 5. Leo CLI Installation
echo [5/6] Installing Leo CLI from source...
set "LEO_DIR=%SCRIPT_DIR%..\leo"

if not exist "%LEO_DIR%" (
    set "LEO_DIR=%USERPROFILE%\leo"
)

if exist "%LEO_DIR%" (
    echo Found Leo at: %LEO_DIR%
    pushd "%LEO_DIR%"
    cargo install --path crates/leo
    popd
) else (
    echo Error: Leo source directory not found at %LEO_DIR%
    exit /b 1
)

:: 6. PORTO Compilation
echo [6/6] Compiling PORTO core...
pushd "%SCRIPT_DIR%core"
rebar3 compile
popd

echo ------------------------------------------------
echo Setup Complete!
echo Please restart your terminal or run: refreshenv
echo ------------------------------------------------
pause
