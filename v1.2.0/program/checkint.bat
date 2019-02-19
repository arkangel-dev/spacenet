set rnd=%random%
Ping www.google.nl -n 1 -w 1000
cls
if errorlevel 1 (set internet=Offline) else (set internet=Online)
if "%internet%"=="Offline" goto ERROR
GOTO EOF
:ERROR
set rnd2=%random%
echo X=msgbox("Failed to download packages. Please check your internet connectivity.",0+46,"Failed")>>%temp%\%rnd2%.vbs
start %temp%\%rnd2%.vbs
ping localhost -n 5 >nul
del %temp%\%rnd2%.vbs
goto END
:EOF
set rnd2=%random%
echo X=msgbox("Finished All Packages have been downloaded.",0+46,"Success")>>%temp%\%rnd2%.vbs
start %temp%\%rnd2%.vbs
ping localhost -n 5 >nul
del %temp%\%rnd2%.vbs
:END