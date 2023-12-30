@echo off

rem By Q3aN 231229
set ver=v01

echo.
echo =====================================================
echo  Welcome to BuildSort %ver%, sorting now:
echo.

call :Sort_Cmd "Token.h" "Token_s.h"
call :Sort_Cmd "Token.mak" "Token_s.mak"
call :Sort_Custom "SetupDefaults.i" "SetupDefaults_s.i"

echo.
echo =====================================================
echo.

pause
exit


:: Use CMD command to sort file line by name
:: %~1: file input
:: %~2: file output
:Sort_Cmd
setLocal enableDelayedExpansion
if not exist %~1 (
    exit /b 0
)
echo.
echo  -- Sorting: %~1
echo.
sort %~1 > %~2
endLocal
exit /b 0


:: Use custom command to sort file and remove unwanted string
:: %~1: file input
:: %~2: file output
:Sort_Custom
setLocal enableDelayedExpansion
if not exist %~1 (
    exit /b 0
)
if exist %~2 (
    del %~2
)
echo.
echo  -- Sorting: %~1
echo.
for /f "usebackq delims=" %%a in (`findstr /c:"." %~1 ^| findstr /v "#line"`) do (
    echo.%%a >>%~2
)
for %%a in (
    "((((get-content %~2) " 
    "-replace 'STRING_TOKEN\(.......', '') "
    "-replace 'STRING_TOKEN \(.......', '') "
    "-replace 'questionid = .....', 'questionid = ') "
    "-replace 'key = .....', 'key = ' "
    "| set-content %~2"
) do set Cmd_Exc=!Cmd_Exc!%%~a
powershell -command "%Cmd_Exc%"
endLocal
exit /b 0
