@echo off
REM Constantly Kill Chrome Process
:loop
ping localhost -n 2 >nul
tasklist /fi "imagename eq chrome.exe" |find ":" > nul
if errorlevel 1 taskkill /f /im "chrome.exe"
goto loop