@echo off

rem Presented by Q3aN.
rem 2021.12.07

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
for /f "tokens=3" %%I in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" ^| find "AutoAdminLogon"') do (
    if "%%I"=="0x1" goto configExist
)

:configNotExist
cls
echo.
echo =====================================================
set choice=
set /p choice=Do you want to add a new auto login config? (Y/N): 
if /i "%choice%"=="Y" goto addConfig
if /i "%choice%"=="y" goto addConfig
goto configCancel

:configExist
for /f "tokens=3" %%I in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" ^| find "DefaultUserName"') do (
    set userName=%%I
)
for /f "tokens=3" %%I in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" ^| find "DefaultPassword"') do (
    set password=%%I
)

cls
echo.
echo =====================================================
echo  Auto login config exist. 
echo    UserName: %userName%
echo    Password: %password%
echo.
echo =====================================================
set choice=
set /p choice=Do you want to delete the exist config? (Y/N): 
if /i "%choice%"=="Y" goto deleteConfig
if /i "%choice%"=="y" goto deleteConfig
goto configCancel

:addConfig
echo.
set userName=
set /p userName="  UserName: "
if /i "%userName%"=="" goto configCancel
set password=
set /p password="  Password: "
if /i "%password%"=="" goto configCancel
echo.
set choice=
set /p choice=Set up above config? (Y/N): 
if /i "%choice%"=="Y" goto configConfirm
if /i "%choice%"=="y" goto configConfirm
goto configCancel

:configConfirm
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t "REG_DWORD" /d "1" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /t "REG_SZ" /d "%userName%" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /t "REG_SZ" /d "%password%" /f
goto configDone

:deleteConfig
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /f
goto configDelete

:configDone
echo.
echo =====================================================
echo Auto login info config done.
goto end

:configDelete
echo.
echo =====================================================
echo Auto login info config deleted.
goto end

:configCancel
echo.
echo =====================================================
echo Auto login info config cancel.

:end
pause