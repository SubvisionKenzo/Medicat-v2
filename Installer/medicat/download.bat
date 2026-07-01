@echo off
cd /d "%~dp0"
set "onlineversion=online_version"
set "localversion=medicat_version"
set "name=update"
set "urldir=https://raw.githubusercontent.com/SubvisionKenzo/Medicat-v2/main/version/"
set "urlapp=https://drive.google.com/"
setlocal enabledelayedexpansion
title Checking Ping + admin privilége
echo set USB LETTER TO %1
echo set USB NAME TO %2

if /I "%1"=="C" (
    echo.
    echo [ERREUR] Impossible d'installer Medicat sur le disque C:
    echo Cela pourrait detruire Windows. Veuillez choisir une cle USB.
    echo [ERROR] Unable to install Medicat on drive C:
    echo This could destroy Windows. Please choose a USB key.
    pause
    exit
)

net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs" %1 %2
    exit /b
)
title 1/3 Downloading MedicatUSB v2
:: curl --version >nul 2>&1
WebClient.exe /exists %urldir%version.txt
set result=%errorlevel%
if %result%==0 (
    goto :continue
) else (
    powershell -ExecutionPolicy Bypass -File errorserver.ps1 "%urldir%"
    exit
)
:continue

start update.bat

timeout 15

WebClient.exe /exists "%urlapp%"
if errorlevel 1 (
    :quitsetup
    powershell -NoProfile -ExecutionPolicy Bypass -File "error.ps1" "Google Drive service error"
)
powershell -NoProfile -ExecutionPolicy Bypass -File "download.ps1"
timeout 1 > nul
set /p onlineVersion=<online_version.txt

set "source=%USERPROFILE%\Downloads\%onlineVersion%.zip"
set "destination=%cd%"

if exist "%source%" (
    move "%source%" "%destination%"
    echo Succesfull moved.
) else (
    echo error !
)

title 2/3 Formating
Ventoy2Disk.exe VTOYCLI /I /Drive:%1:
timeout 5
LABEL %1: %2
title 3/3 Installing Medicat
7z.exe x %onlineVersion%.zip -o"%1:\"
del %onlineVersion%.zip
exit

:offline
7z.exe x localinstall.zip -otemp
cd "localbin"
start setup.bat
exit

:cleaningup
exit