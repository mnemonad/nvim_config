@echo off
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

REM Backup existing Neovim config if it exists (rename the directory)
if exist "%TARGET%" (
    for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value ^| find "="') do set "dt=%%i"
    set "backup=%TARGET%.bak.%dt%"
    echo Backing up %TARGET% to %backup%
    ren "%TARGET%" "%backup%"
)

REM Create the parent directory if it doesn't exist
if not exist "%USERPROFILE%\.config" mkdir "%USERPROFILE%\.config"

REM Create a directory symbolic link for the nvim config
mklink /D "%TARGET%" "%SRC%"
if errorlevel 1 (
    echo Failed to create symbolic link. Run this script as Administrator or enable Developer Mode.
    pause
    exit /b 1
)

echo Neovim config setup complete.
pause

