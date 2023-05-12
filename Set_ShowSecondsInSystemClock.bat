@echo off

rem Presented by Q3aN.
rem 2023.03.24

if "[%1]" == "[49127c4b-02dc-482e-ac4f-ec4d659b7547]" goto :START_PROCESS
REG QUERY HKU\S-1-5-19\Environment >NUL 2>&1 && goto :START_PROCESS

set command="""%~f0""" 49127c4b-02dc-482e-ac4f-ec4d659b7547
SETLOCAL ENABLEDELAYEDEXPANSION
set "command=!command:'=''!"

powershell -NoProfile Start-Process -FilePath '%COMSPEC%' ^
-ArgumentList '/c """!command!"""' -Verb RunAs 2>NUL

IF %ERRORLEVEL% GTR 0 (
    echo =====================================================
    echo This script needs to be executed as an administrator.
    echo =====================================================
    echo.
    pause
)

SETLOCAL DISABLEDELAYEDEXPANSION
goto :EOF

:START_PROCESS
set isConfiged=0
for /f "tokens=3" %%I in ('reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^| find "ShowSecondsInSystemClock"') do (
    if "%%I"=="0x1" set isConfiged=1
)

:QueryUser
echo.
echo =====================================================
if %isConfiged% EQU 1 ( echo  ShowSecondsInSystemClock is now: 1 )
if %isConfiged% EQU 0 ( echo  ShowSecondsInSystemClock is now: 0 )
echo.
set /p choice=Set to? (0/1): 
if /i "%choice%"=="0" goto ToDisable
if /i "%choice%"=="1" goto ToEnable
goto setCancel

:ToDisable
reg delete "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /f
echo.
echo ShowSecondsInSystemClock set to disable, reboot to take effect.
echo.
goto end

:ToEnable
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /t "REG_DWORD" /d "1" /f
echo.
echo ShowSecondsInSystemClock set to enable, reboot to take effect.
echo.
goto end

:setCancel
echo.
echo Set cancel.
echo.

:end
pause