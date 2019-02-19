@echo off
setlocal enabledelayedexpansion
set Counter=1
for /f %%x in (tmp.txt) do (
  set "Line_!Counter!=%%x"
  set /a Counter+=1
)
set /a NumLines=Counter - 1

for /l %%x in (1,1,%NumLines%) do set %%x=!Line_%%x!
	set lhost=%Line_1%
	set lport=%Line_2%
	set uphost=%Line_3%
	set uport=%Line_4%

call insconfig.bat
:: call installer configation file
if NOT EXIST "%insdir%" MD %insdir%
:: check if installation directory exists
copy 