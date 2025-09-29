@echo off
setLocal enableDelayedExpansion
rem For Windows Auto OOBE.
rem By Q3aN 240807
set ver=v01
set end_pause=0

rem Future feature:
rem  [ ] language, region setup

echo.
echo =====================================================
echo ^>
echo ^> Welcome to AutoOOBE %ver%

taskkill /f /im sysprep.exe >nul 2>nul
call :Gen_Unattend_User "%localappdata%\Temp\unattend.xml"

@REM start cmd /k %SystemRoot%\System32\Sysprep\sysprep.exe /audit /reboot
start cmd /k %SystemRoot%\System32\Sysprep\sysprep.exe /oobe /reboot /unattend:"%localappdata%\Temp\unattend.xml"

echo ^>
echo =====================================================
echo.

if "%end_pause%" EQU "1" ( pause )
endLocal
exit /b


rem ****************************************************************************
rem Generate Unattend file to enable Local account
rem %~1 Output File
:Gen_Unattend_User
echo ^<?xml version="1.0" encoding="utf-8"?^> > "%~1"
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^> >> "%~1"
echo     ^<settings pass="oobeSystem"^> >> "%~1"
echo         ^<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> "%~1"
echo             ^<OOBE^> >> "%~1"
echo                 ^<HideEULAPage^>true^</HideEULAPage^> >> "%~1"
echo                 ^<HideOEMRegistrationScreen^>true^</HideOEMRegistrationScreen^> >> "%~1"
echo                 ^<HideOnlineAccountScreens^>true^</HideOnlineAccountScreens^> >> "%~1"
echo                 ^<HideWirelessSetupInOOBE^>true^</HideWirelessSetupInOOBE^> >> "%~1"
echo                 ^<ProtectYourPC^>3^</ProtectYourPC^> >> "%~1"
echo             ^</OOBE^> >> "%~1"
echo         ^</component^> >> "%~1"
echo         ^<component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> "%~1"
echo             ^<SystemLocale^>en-US^</SystemLocale^> >> "%~1"
echo         ^</component^> >> "%~1"
echo     ^</settings^> >> "%~1"
echo ^</unattend^> >> "%~1"
echo ^>
echo ^> Answer file generated: %~1
exit /b

