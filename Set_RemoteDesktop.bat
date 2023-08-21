@echo off

if "[%1]" == "[49127c4b-02dc-482e-ac4f-ec4d659b7547]" goto :StartProcess
REG QUERY HKU\S-1-5-19\Environment >nul 2>&1 && goto :StartProcess

set command="""%~f0""" 49127c4b-02dc-482e-ac4f-ec4d659b7547
setlocal EnableDelayedExpansion
set "command=!command:'=''!"

powershell -NoProfile Start-Process -FilePath '%COMSPEC%' ^
-ArgumentList '/c """!command!"""' -Verb RunAs 2>nul

IF %ERRORLEVEL% GTR 0 (
    echo =====================================================
    echo This script needs to be executed as an administrator.
    echo =====================================================
    echo.
    pause
)

setlocal EnableDelayedExpansion
goto :EOF

reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f

:StartProcess
set isConfiged=0
for /f "tokens=3" %%I in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" ^| find "fDenyTSConnections"') do (
    if "%%I"=="0x1" set isConfiged=1
)

:QueryUser
echo.
echo =====================================================
if %isConfiged% EQU 1 ( echo  fDenyTSConnections is now: 1 )
if %isConfiged% EQU 0 ( echo  fDenyTSConnections is now: 0 )
echo.
set /p choice=Set to? (0/1): 
if /i "%choice%"=="0" goto ToDisable
if /i "%choice%"=="1" goto ToEnable
goto setCancel

:ToDisable
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 1 /f
echo.
echo Reboot to take effect.
echo.
goto end

:ToEnable
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
echo.
echo Reboot to take effect.
echo.
goto end

:setCancel
echo.
echo Set cancel.
echo.

:end
pause