@echo off

rem Presented by Q3aN.
rem 2023.02.27

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
for /f "tokens=3" %%I in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization" ^| find "NoLockScreen"') do (
    if "%%I"=="0x1" set isConfiged=1
)

:QueryUser
echo.
echo =====================================================
if %isConfiged% EQU 1 ( echo  NoLockScreen is now: 1 )
if %isConfiged% EQU 0 ( echo  NoLockScreen is now: 0 )
echo.
set /p choice=Set NoLockScreen to? (0/1): 
if /i "%choice%"=="0" goto ToDisable
if /i "%choice%"=="1" goto ToEnable
goto setCancel

:ToDisable
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreen" /t "REG_DWORD" /d "1" /f
echo.
echo NoLockScreen set to 1, reboot to take effect.
echo.
goto end

:ToEnable
reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Personalization" /v "NoLockScreen" /f
echo.
echo NoLockScreen set to default, reboot to take effect.
echo.
goto end

:setCancel
echo.
echo Set cancel.
echo.

:end
pause