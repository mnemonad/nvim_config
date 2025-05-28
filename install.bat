@echo off
setlocal enabledelayedexpansion

REM Check if running as Administrator
net session >nul 2>&1
if not %errorLevel% == 0 (
    echo This script requires Administrator privileges for creating symbolic links.
    echo Please right-click and "Run as administrator" or enable Developer Mode.
    pause
    exit /b 1
)

REM Check if winget is available
where winget >nul 2>&1
if errorlevel 1 (
    echo winget is not installed. Please install winget and try again.
    pause
    exit /b 1
)

echo Updating system packages...
winget upgrade --all --silent

echo Installing required packages...
winget install --id Git.Git -e --silent
winget install --id GitHub.cli -e --silent
winget install --id curl -e --silent
winget install --id wget -e --silent
winget install --id Neovim.Neovim -e --silent

REM Define source and target directories
set "SRC=%cd%\config_src"
set "TARGET=%USERPROFILE%\.config\nvim"

REM Check if source directory exists
if not exist "%SRC%" (
    echo Error: Source directory %SRC% does not exist.
    pause
    exit /b 1
)

REM Backup existing Neovim config if it exists
if exist "%TARGET%" (
    for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value ^| find "="') do set "dt=%%i"
    set "dt=!dt:~0,14!"
    set "backup=%TARGET%.bak.!dt!"
    echo Backing up %TARGET% to !backup!
    ren "%TARGET%" "!backup!"
    if errorlevel 1 (
        echo Failed to backup existing config.
        pause
        exit /b 1
    )
)

REM Create the parent directory if it doesn't exist
if not exist "%USERPROFILE%\.config" mkdir "%USERPROFILE%\.config"

REM Create a directory symbolic link for the nvim config
mklink /D "%TARGET%" "%SRC%"
if errorlevel 1 (
    echo Failed to create symbolic link. Make sure you're running as Administrator.
    pause
    exit /b 1
)

echo Neovim config setup complete.
echo Please restart your terminal to ensure all changes take effect.
pause
