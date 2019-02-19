@echo off
REM Make vbs message
set msgd=%1
set title=%2
set rnd=%random%
IF "%msgd%"=="" GOTO HELP
echo x=msgbox(%msgd%,0+6,%title%) >>%rnd%.vbs
start %rnd%.vbs
ping localhost -n 3 >nul
del %rnd%.vbs
GOTO EOF
:HELP
echo.
echo TOAST [message] [title]
echo Make a vbs based message
echo.
:EOF