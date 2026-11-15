@echo off
title GK Hemanth Portfolio Server
echo Starting GK Hemanth Portfolio Server on localhost:3000...
powershell -ExecutionPolicy Bypass -File "%~dp0server.ps1" -Port 3000
pause
