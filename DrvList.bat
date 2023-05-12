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
cls
echo.
echo =====================================================
echo      all       - All drivers
echo      ibt       - BT drivers    
echo      net       - WLAN drivers  
echo      dptf      - DTT drivers   
echo      lake      - PCH drivers   
echo      ial       - SIO drivers   
echo      hide      - HID drivers   
echo      heci      - MEI drivers   
echo.
echo =====================================================
set keyWords=
set /p keyWords=Enter keywords of the driver (Case-sensitive): 
if /i "%keyWords%"=="all" goto listAll
if /i "%keyWords%"=="" goto checkUsage

mode 150
echo.
echo Please wait...
echo.
dism /online /get-drivers /format:table | find  "%keyWords%"
echo.

goto checkUsage

:listAll
mode 150
echo.
echo Please wait...
echo.
dism /online /get-drivers /format:table | find ".inf"
echo.

:checkUsage
echo.
echo =====================================================
set number=
set /p number=Enter OEM number to check usage: 
if /i "%number%"=="" goto START_PROCESS

echo.
echo If "oem%number%.inf" show below, means PC loaded this driver: 
pnputil /enum-devices | find "oem%number%.inf"
echo --------------------------------------------

echo.
echo =====================================================
set choice=
set /p choice=Enter "Y" to delete / "F" to force delete: 
if /i "%choice%"=="Y" goto deleteDriver
if /i "%choice%"=="y" goto deleteDriver
if /i "%choice%"=="F" goto forceDeleteDriver
if /i "%choice%"=="f" goto forceDeleteDriver
goto checkUsage

:deleteDriver
pnputil /delete-driver oem%number%.inf
goto checkUsage

:forceDeleteDriver
pnputil /delete-driver oem%number%.inf /force
goto checkUsage

:end
pause
