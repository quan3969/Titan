@echo off
setLocal enableDelayedExpansion
rem All in one script for windows customization
rem By Q3aN 240308
set ver=v03

call :AskAdmin

echo.
echo =====================================================
echo ^>
echo ^> Welcome to Turtle %ver%

@REM :: Win11
@REM call :Set_LagecyMenu     1
if %errorlevel% EQU 0 ( call :Set_LagecyMenu     1 )
:: if %errorlevel% EQU 0 ( call :Set_Language "en-US" )

@REM :: Win10
:: if %errorlevel% EQU 0 ( call :Set_AntiSpyWare    0 )

@REM :: Win10/Win11
if %errorlevel% EQU 0 ( call :Set_ShowSeconds    1 )
if %errorlevel% EQU 0 ( call :Set_AutoUpdate     0 )
if %errorlevel% EQU 0 ( call :Set_UsbPrompt      0 )
if %errorlevel% EQU 0 ( call :Set_RemoteDesktop  1 )
:: if %errorlevel% EQU 0 ( call :Set_ShowHidden     1 )
:: if %errorlevel% EQU 0 ( call :Set_Recovery       0 )

call :Do_Ending %errorlevel%

echo ^>
echo =====================================================
echo.

if %errorlevel% EQU 5 exit /b
endLocal
pause
exit /b


rem ****************************************************************************
rem Set current OS language
rem %~1: language to set "en-US", "zh-CN", "ko-KR"
:Set_Language
rem Local Experience Packs (LXPs)
set lpxs_added=0
for /f "usebackq delims=" %%i in (`Dism /Online /English /Get-Packages ^| find "LanguagePack" ^| find "%~1"`) do (
    if exist %bat_dir%\etc\%~1\Microsoft-Windows-Client-Language-Pack_x64_%~1.cab ( set lpxs_added=1 )
)
if %lpxs_added% EQU 0 (
    Dism /Online /Add-Package /PackagePath:%bat_dir%\etc\%~1\Microsoft-Windows-Client-Language-Pack_x64_%~1.cab
)
for /f "usebackq tokens=2 delims=:" %%i in (`DISM /Online /English /Get-CapabilityInfo /CapabilityName:Language.Basic~~~%~1~0.0.1.0 ^| find "State"`) do (
    if /i "%%i"==" Not Present" ( if exist %bat_dir%\etc\%~1\Microsoft-Windows-LanguageFeatures-Basic-%~1-Package~31bf3856ad364e35~amd64~~.cab (
            Dism /Online /Add-capability /CapabilityName:"Language.Basic~~~%~1~0.0.1.0" /source:%bat_dir%\etc\%~1
    ))
)
for /f "usebackq tokens=2 delims=:" %%i in (`powershell Get-WinUserLanguageList ^| find "LanguageTag"`) do (
    if /i "%%i"==" en-US" ( 
        powershell "$LangList = Get-WinUserLanguageList; $LangList.Add('%~1'); Set-WinUserLanguageList $LangList -force"
    )
)
rem Features On Demand (FODs)
rem Download and apply if need
set culture_setted=0
for /f "usebackq delims=" %%i in (`powershell Get-Culture ^| find "%~1"`) do (
    set culture_setted=1
)
if %culture_setted% EQU 0 (
    rem Add one time run to next boot
    reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "SetLang" /t REG_SZ /d "powershell Set-WinUILanguageOverride -Language %~1; Restart-Computer" /f
)
rem UIIntl (intl.cpl)
set locale_setted=0
for /f "usebackq delims=" %%i in (`powershell Get-WinSystemLocale ^| find "%~1"`) do (
    set locale_setted=1
)
if %locale_setted% EQU 0 (
    powershell Set-WinSystemLocale -SystemLocale %~1
)
exit /b


rem ****************************************************************************
rem Do the ending and clean up job
rem %~1: Ending reason:
rem        0 - Success
rem        4 - Not admin (user click "No")
rem        5 - Not admin (user click "Yes", origin script, don't care)
:Do_Ending
if "%~1" EQU "0" ( echo ^>
    echo ^> Success
) else if "%~1" EQU "4" ( echo ^>
    echo ^> Please run as administrator
)
exit /b


rem ****************************************************************************
rem Ask user for administrator privileges 
rem SET bat_dir: Current path
:AskAdmin
set bat_dir=%~dp0
if "[%1]" == "[49127c4b-02dc-482e-ac4f-ec4d659b7547]" (
    set bat_dir=%~2
    exit /b 0
)
reg query HKU\S-1-5-19\Environment >nul 2>&1 && exit /b 0
set command="""%~f0""" 49127c4b-02dc-482e-ac4f-ec4d659b7547 %~dp0
setLocal enableDelayedExpansion
set "command=!command:'=''!"
powershell -NoProfile Start-Process -FilePath '%ComSpec%' ^
-ArgumentList '/c """!command!"""' -Verb RunAs 2>nul
if %errorlevel% GTR 0 (
    exit /b 4
)
exit /b 5


rem ****************************************************************************
rem bcdedit /set {current} recoveryenabled no
rem Disable system auto repair after abnormal shutdown
:Set_Recovery
setLocal enableDelayedExpansion
set val=0
for /f "tokens=2" %%i in ('bcdedit ^| find "recoveryenabled"') do (
    if /i "%%i"=="Yes" set val=1
)
if "%~1" EQU "0" if %val% EQU 1 (
    bcdedit /set {current} recoveryenabled no >nul
    echo   Recovery:           1 -^> 0
    endLocal
    exit /b
)
if "%~1" EQU "1" if %val% EQU 0 (
    bcdedit /set {current} recoveryenabled yes >nul
    echo   Recovery:           0 -^> 1
    endLocal
    exit /b
)
echo   Recovery:           %val%
endLocal
exit /b


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
