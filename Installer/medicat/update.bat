@echo off
cd /d "%~dp0"
set "onlineversion=online_version"
set "localversion=medicat_version"
set "name=update"
set "urldir=https://raw.githubusercontent.com/SubvisionKenzo/Medicat-v2/main/version/"
setlocal enabledelayedexpansion
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

for /f "tokens=2 delims=<>" %%A in ('findstr /i "<Version>" %localversion%.xml') do (
    set localVersion=%%A
)

WebClient.exe /download "%urldir%version.txt" "%onlineversion%.txt"

set /p onlineVersion=<%onlineversion%.txt
echo %localVersion% - %onlineVersion%
set "update_file=runtime_%onlineVersion%"

if "%onlineVersion%"=="%localVersion%" (
    del %onlineversion%.txt
    set "url=%urldir%%onlineVersion%.zip"
    echo %onlineversion%
    goto installdir
    exit /b
)
set "url=%urldir%%localVersion%"
:installdir

powershell -NoProfile -ExecutionPolicy Bypass -File "bar.ps1" "%urldir%%onlineVersion%.zip"
7z.exe x bin.zip -otemp
del bin.zip
exit

:offline
7z.exe x localinstall.zip -otemp
exit