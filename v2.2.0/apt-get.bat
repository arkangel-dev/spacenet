:: apt-get
@echo off

set file=%randrom%
call config.bat
echo checking if update server is up and running...
Ping %updhost% -n 1 -w 1000 >nul
cls
if errorlevel 1 (set internet=offline) else (set internet=online)
	echo server is %internet%...
	echo connecting to %updhost%:%updport%...
		nc %updhost% %updport% >%file%.dat
	echo recived file has been dumped to %file%.dat
	echo [%time%/%date%] file %file%.dat has been downloaded from %updhost%
:eof