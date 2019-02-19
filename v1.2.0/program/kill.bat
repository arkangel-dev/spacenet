@echo off
REM Kill given process
SET var=%1
IF "%var%"=="" GOTO HELP
taskkill /f /t /im "%var%"
goto EOF
:HELP
echo.
echo KILL [process_name]
echo Kill processes
echo.
:EOF