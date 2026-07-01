@echo off
cd /d "%~dp0"
set "name=setup"
set "hide=hidden"
if exist %hide%.txt goto execut
echo >> %hide%.txt
cmd /c start /min setup.bat %1
exit
:execut
del %hide%.txt
PowerShell -ExecutionPolicy Bypass -File "%name%.ps1"
exit > nul