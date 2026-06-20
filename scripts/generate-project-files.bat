@echo off
cd /d "%~dp0.."
call cmake -S . -B build -G "Visual Studio 17 2022"
