@echo off

rem Presented with heart by Q3aN.                        
rem 2022.02.22   

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
for /f "tokens=6 delims=\" %%I in ('reg query "HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"') do (
    if "%%I"=="InprocServer32" goto legacyConfig
)

:win11Config
cls
echo.
echo =====================================================
echo Now right click menu is Win11 default mode.
echo.
set /p choice=Set to lagecy mode? (Y/N): 
if /i "%choice%"=="Y" goto setLegacy
if /i "%choice%"=="y" goto setLegacy
goto setCancel

:legacyConfig
cls
echo.
echo =====================================================
echo Now right click menu is lagecy mode.
echo.
set /p choice=Set to Win11 default mode? (Y/N): 
if /i "%choice%"=="Y" goto setWin11
if /i "%choice%"=="y" goto setWin11
goto setCancel

:setWin11
reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f
echo.
echo Set to Win11 default, reboot to take effect.
echo.
goto end

:setLegacy
reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve
echo.
echo Set to legacy mode, reboot to take effect.
echo.
goto end

:setCancel
echo.
echo Set cancel.
echo.

:end
pause