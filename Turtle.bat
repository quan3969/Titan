@echo off

rem By Q3aN 230903
set ver=v01

call :AskAdmin
echo.
echo =====================================================
echo  Welcome to Turtle %ver%, stting up now:
echo.

:: Win11
call :Set_LagecyMenu     1

:: Win10
:: call :Set_AntiSpyWare    0

:: Win10/Win11
call :Set_ShowSeconds    1
call :Set_AutoUpdate     0
call :Set_UsbPrompt      0
call :Set_RemoteDesktop  1
call :Set_ShowHidden     1

echo.
echo =====================================================
echo.

pause
exit

:: Ask user for administrator privileges 
:AskAdmin
if "[%1]" == "[49127c4b-02dc-482e-ac4f-ec4d659b7547]" exit /b 0
reg query HKU\S-1-5-19\Environment >nul 2>&1 && exit /b 0
set command="""%~f0""" 49127c4b-02dc-482e-ac4f-ec4d659b7547
setLocal enableDelayedExpansion
set "command=!command:'=''!"
powershell -NoProfile Start-Process -FilePath '%COMSPEC%' ^
-ArgumentList '/c """!command!"""' -Verb RunAs 2>nul
if %ERRORLEVEL% GTR 0 (
    echo =====================================================
    echo This script needs to be executed as an administrator.
    echo =====================================================
    echo.
    pause
)
endLocal
exit


:: Set menu menu style for Win11
:Set_LagecyMenu
setLocal enableDelayedExpansion
set val=0
for /f "tokens=6 delims=\" %%i in ('reg query "HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"') do (
    if "%%i"=="InprocServer32" ( set val=1 )
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f >nul
    echo   Lagecy menu:        1 -^> 0
    endLocal
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve >nul
    echo   Lagecy menu:        0 -^> 1
    endLocal
    exit /b 0
)
echo   Lagecy menu:        %val%
endLocal
exit /b 0


:: Set Show seconds in system Clock
:Set_ShowSeconds
setLocal enableDelayedExpansion
set val=0
for /f "tokens=3" %%i in ('reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^| find "ShowSecondsInSystemClock"') do (
    if "%%i"=="0x1" set val=1
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg delete "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /f >nul
    echo   Show seconds:       1 -^> 0
    endLocal
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /t "REG_DWORD" /d "1" /f >nul
    echo   Show seconds:       0 -^> 1
    endLocal
    exit /b 0
)
echo   Show seconds:       %val%
endLocal
exit /b 0


:: Set Auto Windows Update
:Set_AutoUpdate
setLocal enableDelayedExpansion
set val=1
for /f "tokens=3" %%i in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" ^| find "NoAutoUpdate"') do (
    if "%%i"=="0x1" set val=0
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t "REG_DWORD" /d "1" /f >nul
    echo   Auto Update:        1 -^> 0
    endLocal
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /f >nul
    echo   Auto Update:        0 -^> 1
    endLocal
    exit /b 0
)
echo   Auto Update:        %val%
endLocal
exit /b 0


:: Set USB disk Auto play
:Set_UsbPrompt
setLocal enableDelayedExpansion
set val=1
for /f "tokens=3" %%i in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" ^| find "DisableAutoplay"') do (
    if "%%i"=="0x1" set val=0
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /t "REG_DWORD" /d "1" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlersDefaultSelection\StorageOnArrival" /d "MSTakeNoAction" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\UserChosenExecuteHandlers\StorageOnArrival" /d "MSTakeNoAction" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlersDefaultSelection\CameraAlternate\ShowPicturesOnArrival" /d "MSTakeNoAction" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\UserChosenExecuteHandlers\CameraAlternate\ShowPicturesOnArrival" /d "MSTakeNoAction" /f >nul
    echo   USB Prompt:         1 -^> 0
    endLocal
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlersDefaultSelection\StorageOnArrival" /d "MSPromptEachTime" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\UserChosenExecuteHandlers\StorageOnArrival" /d "MSPromptEachTime" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlersDefaultSelection\CameraAlternate\ShowPicturesOnArrival" /d "MSPromptEachTime" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\UserChosenExecuteHandlers\CameraAlternate\ShowPicturesOnArrival" /d "MSPromptEachTime" /f >nul
    echo   USB Prompt:         0 -^> 1
    endLocal
    exit /b 0
)
echo   USB Prompt:         %val%
endLocal
exit /b 0


:: Set Remote desktop
:Set_RemoteDesktop
setLocal enableDelayedExpansion
set val=1
for /f "tokens=3" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" ^| find "fDenyTSConnections"') do (
    if "%%i"=="0x1" set val=0
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t "REG_DWORD" /d 1 /f >nul
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "updateRDStatus" /t "REG_DWORD" /d 0 /f >nul
    netsh advfirewall firewall set rule group="remote desktop" new enable=No
    echo   Remote Desktop:     1 -^> 0
    endLocal
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t "REG_DWORD" /d 0 /f >nul
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "updateRDStatus" /t "REG_DWORD" /d 1 /f >nul
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "UserAuthentication" /t "REG_DWORD" /d 1 /f >nul
    netsh advfirewall firewall set rule group="remote desktop" new enable=Yes
    echo   Remote Desktop:     0 -^> 1
    endLocal
    exit /b 0
)
echo   Remote Desktop:     %val%
endLocal
exit /b 0


:: Set AntiSpyWare
:Set_AntiSpyWare
setLocal enableDelayedExpansion
set val=1
for /f "tokens=3" %%i in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" ^| find "DisableAntiSpyware"') do (
    if "%%i"=="0x1" set val=0
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t "REG_DWORD" /d "1" /f >nul
    echo   AntiSpyWare:        1 -^> 0
    endLocal
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /f >nul
    echo   AntiSpyWare:        0 -^> 1
    endLocal
    exit /b 0
)
echo   AntiSpyWare:        %val%
endLocal
exit /b 0


:: Set Show Hidden items and file exentions
:Set_ShowHidden
setLocal enableDelayedExpansion
set val=1
for /f "tokens=3" %%i in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^| find "HideFileExt"') do (
    if "%%i"=="0x1" set val=0
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t "REG_DWORD" /d 2 /f >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t "REG_DWORD" /d 1 /f >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t "REG_DWORD" /d 2 /f >nul
    echo   Show Hidden:        1 -^> 0
    endLocal
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t "REG_DWORD" /d 1 /f >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t "REG_DWORD" /d 0 /f >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t "REG_DWORD" /d 1 /f >nul
    echo   Show Hidden:        0 -^> 1
    endLocal
    exit /b 0
)
echo   Show Hidden:        %val%
endLocal
exit /b 0

