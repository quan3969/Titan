@echo off

rem Presented with heart by Q3aN.                        
rem 2021.04.25   

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
for /f "delims=_,& tokens=6*" %%I in ('reg query HKLM\SYSTEM\CurrentControlSet\Enum\USB ^| find "VID_8087&PID"') do (
    
	if "%%I"=="0A2A" GOTO StP_Drv
	if "%%I"=="0AA7" GOTO SdP_Drv
	if "%%I"=="0A2B" GOTO SfP_WsP_Drv
	if "%%I"=="0025" GOTO ThP_Drv
    if "%%I"=="0AAA" GOTO JfP_Drv
	if "%%I"=="0029" GOTO CcP_Drv
	if "%%I"=="0026" GOTO HrP_Drv
	if "%%I"=="0032" GOTO TyP_Drv
	if "%%I"=="0033" GOTO GfP_Drv
)

echo.
echo =====================================================
echo No IBT device found.
GOTO finish

:StP_Drv
echo.
echo =====================================================
echo Stone Peak card found.
pnputil /add-driver "%~dp0/Drivers/STP/ibtusb.inf" /install
GOTO finish

:SdP_Drv
echo.
echo =====================================================
echo Sandy Peak card found.
pnputil /add-driver "%~dp0/Drivers/SDP/ibtusb.inf" /install
GOTO finish

:SfP_WsP_Drv
echo.
echo =====================================================
echo Snowfield/Windstorm Peak card found.
pnputil /add-driver "%~dp0/Drivers/SFP/ibtusb.inf" /install
pnputil /add-driver "%~dp0/Drivers/WSP/ibtusb.inf" /install
GOTO finish

:ThP_Drv
echo.
echo =====================================================
echo Thunder Peak card found.
pnputil /add-driver "%~dp0/Drivers/THP/ibtusb.inf" /install
GOTO finish

:JfP_Drv
echo.
echo =====================================================
echo Jefferson Peak card found.
pnputil /add-driver "%~dp0/Drivers/JFP/ibtusb.inf" /install
GOTO finish

:CcP_Drv
echo.
echo =====================================================
echo Cyclone Peak card found.
pnputil /add-driver "%~dp0/Drivers/CCP/ibtusb.inf" /install
GOTO finish

:HrP_Drv
echo.
echo =====================================================
echo Harrison Peak card found.
pnputil /add-driver "%~dp0/Drivers/HRP/ibtusb.inf" /install
GOTO finish

:TyP_Drv
echo.
echo =====================================================
echo Typhoon Peak card found.
pnputil /add-driver "%~dp0/Drivers/TYP/ibtusb.inf" /install
GOTO finish

:GfP_Drv
echo.
echo =====================================================
echo Garfield Peak card found.
pnputil /add-driver "%~dp0/Drivers/GFP/ibtusb.inf" /install
GOTO finish

:finish
echo.
echo =====================================================
set choice=
set /p choice=Enter "Y" if you want to reboot now: 
if /i "%choice%"=="Y" goto reboot
if /i "%choice%"=="y" goto reboot
goto end

:reboot
shutdown /r /t 0

:end
