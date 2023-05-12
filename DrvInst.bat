@echo off

rem Presented with heart by Q3aN.                        
rem 2021.04.22   

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
pnputil /add-driver "%~dp0*.inf" /subdirs /install

echo.
echo =====================================================
set choice=
set /p choice=Do you want to reboot now? (Y/n): 
if /i "%choice%"=="Y" goto reboot
if /i "%choice%"=="y" goto reboot
goto end

:reboot
shutdown /r /t 0

:end
