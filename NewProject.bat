@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0NewProject.ps1" %*
exit /b %ERRORLEVEL%
