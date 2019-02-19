:: intsh
@echo off
call config.bat

:loop
	set /p "mode="
	if "%mode%"=="all" goto all
	if "%mode%"=="int" goto int
goto loop

:all
	set /p "comm="
	%comm%
goto all

:int   
	echo.
	type art.grp
	echo.
	echo.
	echo [%time%] Interactive shell activated...
	echo [%time%] Loading...
	echo [%time%] Welcome...
	:int_sub
		set /p "comm=$ "
		%comm%
	goto int_sub
goto int
