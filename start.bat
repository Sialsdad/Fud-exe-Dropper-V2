@echo off
cd /d %~dp0
powershell.exe -ExecutionPolicy Bypass -File .\builder.ps1
exit