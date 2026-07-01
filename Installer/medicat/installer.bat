@echo off
cd /d "%~dp0"
setlocal EnableDelayedExpansion
:: Medicat v2 SAFE installer !

:: Chemin de base
set "BASEDIR=%~dp0"

:: 1) Lire le titre depuis title.txt
for /f "tokens=1,2 delims==" %%A in ('type "%BASEDIR%title.txt"') do (
    if /I "%%A"=="TITLE" set "APP_TITLE=%%B"
)

if not defined APP_TITLE set "APP_TITLE=MediCat v2 SAFE Installer"

title %APP_TITLE%

:: 2) Vérifier si on est en admin
net session >nul 2>&1
if errorlevel 1 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

echo [OK] Admin.

:: 3) Vérifier la connexion Internet (ping simple)
echo [INFO] Checking Internet Connection...
ping 1.1.1.1 -n 1 -w 1000 >nul
if errorlevel 1 (
    :: Appel de error.ps1 avec un message
    F "%BASEDIR%error.ps1" "Internet (code 01)."
    exit /b
)

echo [OK] Internet.

:: 4) Lancer la sélection de langue (lang.ps1)
PowerShell -ExecutionPolicy Bypass -File "%BASEDIR%lang.ps1" "%APP_TITLE%"

:: On suppose que lang.ps1 écrit la langue choisie dans selected_lang.txt
if not exist "%BASEDIR%selected_lang.txt" (
    exit /b
)

set "LANG_CODE="
for /f "usebackq delims=" %%L in ("%BASEDIR%selected_lang.txt") do set "LANG_CODE=%%L"

if not defined LANG_CODE (
    echo Lang not defined
    exit /b
)

:: 5) Lancer le setup avec la langue en argument
start setup.bat
exit /b