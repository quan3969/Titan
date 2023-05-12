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
for /f "delims=_,& tokens=6*" %%I in ('reg query HKLM\SYSTEM\CurrentControlSet\Enum\PCI ^| find "PCI\VEN_8086&DEV"') do (
    rem  Check if the device is StP   
	if "%%I"=="095A" GOTO INSTALL_LEGACY_DRIVER
	if "%%I"=="095B" GOTO INSTALL_LEGACY_DRIVER
	if "%%I"=="3165" GOTO INSTALL_LEGACY_DRIVER
	if "%%I"=="3166" GOTO INSTALL_LEGACY_DRIVER	
	
	rem  Check if the device is SdP
	if "%%I"=="24FB" GOTO INSTALL_LEGACY_DRIVER	
	
	rem  Check if the device is SfP
	if "%%I"=="24F3" GOTO INSTALL_06_DRIVER	
	rem  Check if the device is LnP1
	if "%%I"=="24F5" GOTO INSTALL_06_DRIVER	
	rem  Check if the device is WsP
	if "%%I"=="24FD" GOTO INSTALL_06_DRIVER	
)

rem Then install netwtw08
pnputil /add-driver "%~dp0Netwtw08.inf" /subdirs /install
GOTO finish

:INSTALL_06_DRIVER
pnputil /add-driver "%~dp0Netwtw06.inf" /subdirs /install
GOTO finish

:INSTALL_LEGACY_DRIVER
pnputil /add-driver "%~dp0Netwtw04.inf" /subdirs /install
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
