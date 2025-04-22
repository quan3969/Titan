@echo off
setLocal enableDelayedExpansion
rem All in one script for windows customization
rem By Q3aN 250219
set ver=v05

rem Future feature:
rem  [x] set testsigning mode
rem  [ ] explorer privicy

call :AskAdmin

echo.
echo =====================================================
echo ^>
echo ^> Welcome to Turtle %ver%

rem
rem Win11
rem
if %errorlevel% EQU 0 ( call :Set_LagecyMenu      1 )

rem
rem Win10 / Win11
rem
if %errorlevel% EQU 0 ( call :Set_AntiSpyWare     0 )
if %errorlevel% EQU 0 ( call :Set_ShowSeconds     1 )
if %errorlevel% EQU 0 ( call :Set_AutoUpdate      0 )
if %errorlevel% EQU 0 ( call :Set_UsbPrompt       0 )
if %errorlevel% EQU 0 ( call :Set_RemoteDesktop   1 )
if %errorlevel% EQU 0 ( call :Set_ShowHidden      1 )
:: if %errorlevel% EQU 0 ( call :Set_TestSigning     0 )
:: if %errorlevel% EQU 0 ( call :Set_Recovery        0 )
:: if %errorlevel% EQU 0 ( call :Set_AutoAdminLogon    )
:: if %errorlevel% EQU 0 ( call :Set_Language  "en-US" )

call :Do_Ending %errorlevel%

echo ^>
echo =====================================================
echo.

endLocal
if %errorlevel% NEQ 5 pause
exit /b


rem ****************************************************************************
rem Set_AutoAdminLogon
:Set_AutoAdminLogon
echo ^>
echo ^>  Auto Admin Logon:
set cfg_exist=0
set userName=
set password=
set cfg_required=0
for /f "tokens=3" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" 2^>nul ^| find "AutoAdminLogon"') do (
    if "%%i" equ "0x1" ( set "cfg_exist=1" )
)
if "%cfg_exist%" EQU "1" (
    echo ^>   Config exist.
    for /f "tokens=3" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" 2^>nul ^| find "DefaultUserName"') do (
        echo ^>    UserName: %%i
    )
    for /f "tokens=3" %%i in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" 2^>nul ^| find "DefaultPassword"') do (
        echo ^>    Password: %%i
    )
    set choice=
    set /p choice=" >   Delete it? (y/N): "
    if /i "!choice!"=="Y" ( set "cfg_required=1" )
    if "!cfg_required!" equ "0" (
        echo ^> Cancel.
        exit /b 0
    )
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /f >nul
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /f >nul
    reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /f >nul
    echo ^>   Deleted.
) else (
    set "cfg_required=1"
    set /p userName="  >    UserName: "
    if /i "!userName!" equ "" ( set "cfg_required=0" )
    set /p password="  >    Password: "
    if /i "!password!" equ "" ( set "cfg_required=0" )
    set choice=
    set /p choice=" >   Config above? (y/N): "
    if /i "!choice!" neq "Y" ( set "cfg_required=0" )
    if "!cfg_required!" equ "0" (
        echo ^>   Cancel.
        exit /b 0
    )
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "AutoAdminLogon" /t "REG_DWORD" /d "1" /f >nul
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultUserName" /t "REG_SZ" /d "!userName!" /f >nul
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v "DefaultPassword" /t "REG_SZ" /d "!password!" /f >nul
    echo ^>   Done.
)
exit /b 0


rem ****************************************************************************
rem Set current OS language
rem  %~1: language to set "en-US", "zh-CN", "ko-KR"
rem
rem 1. Make sure all config set correctly:
rem  - powershell Get-WinUserLanguageList
rem  - powershell Get-Culture
rem  - powershell Get-WinSystemLocale
rem
rem 2. Necessarily cab package:
rem  - Microsoft-Windows-Client-LanguagePack-Package-amd64-en-us.esd
rem  - Microsoft-Windows-LanguageFeatures-Basic-en-us-Package-amd64.cab
rem
rem 3. Different OS should use different cab packages:
rem  - Download from UUPs
rem
:Set_Language
echo ^>
echo ^>  Set Language %~1:
set os_ver=
for /f "tokens=3 delims=." %%i in ('ver') do (
    set os_ver=%%i
)
rem
rem Local Experience Packs (LXPs)
rem
set lpxs_required=1
for /f "usebackq delims=" %%i in (`powershell Get-Culture ^| find "%~1"`) do (
    set "lpxs_required=0"
)
for /f "usebackq delims=" %%i in (`Dism /Online /English /Get-Packages ^| find "LanguagePack" ^| find "%~1"`) do (
    set "lpxs_required=0"
)
if not exist "%bat_dir%\etc\%os_ver%\%~1\Microsoft-Windows-Client-LanguagePack-Package-amd64-%~1.esd" (
    set "lpxs_required=0"
)
if %lpxs_required% EQU 1 (
    Dism /Online /Add-Package /PackagePath:%bat_dir%\etc\%os_ver%\%~1\Microsoft-Windows-Client-LanguagePack-Package-amd64-%~1.esd
    rem Add one time run to next boot
    reg add "HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\RunOnce" /v "SetLang" /t REG_SZ /d "powershell Set-WinUILanguageOverride -Language %~1; Restart-Computer" /f >nul
    echo ^>   LXPs done.
) else (
    echo ^>   LXPs skip.
)
rem
rem Features On Demand (FODs)
rem
set fods_required=1
for /f "usebackq tokens=2 delims=:" %%i in (`powershell Get-WinUserLanguageList ^| find "LanguageTag"`) do (
    if /i "%%i" EQU " en-US" ( set "fods_required=0" )
)
for /f "usebackq tokens=2 delims=:" %%i in (`Dism /Online /English /Get-CapabilityInfo /CapabilityName:Language.Basic~~~%~1~0.0.1.0 ^| find "State"`) do (
    if /i "%%i" EQU " Installed" ( set "fods_required=0" )
)
if not exist "%bat_dir%\etc\%os_ver%\%~1\Microsoft-Windows-LanguageFeatures-Basic-%~1-Package-amd64.cab" (
    set fods_required=0
)
if %fods_required% EQU 1 (
    Dism /Online /Add-capability /CapabilityName:"Language.Basic~~~%~1~0.0.1.0" /source:%bat_dir%\etc\%os_ver%\%~1
    powershell "$LangList = Get-WinUserLanguageList; $LangList.Add('%~1'); Set-WinUserLanguageList $LangList -force" >nul 2>&1
    echo ^>   FODs done.
) else (
    echo ^>   FODs skip.
)
rem
rem UIIntl (intl.cpl)
rem
set intl_required=1
for /f "usebackq delims=" %%i in (`powershell Get-WinSystemLocale ^| find "%~1"`) do (
    set intl_required=0
)
if %intl_required% EQU 1 (
    powershell Set-WinSystemLocale -SystemLocale %~1
    echo ^>   Intl done.
) else (
    echo ^>   Intl skip.
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
set val=0
for /f "tokens=2" %%i in ('bcdedit ^| find "recoveryenabled"') do (
    if /i "%%i"=="Yes" set val=1
)
if "%~1" EQU "0" if %val% EQU 1 (
    bcdedit /set {current} recoveryenabled no >nul
    echo ^>  Recovery:           1 -^> 0
    exit /b
)
if "%~1" EQU "1" if %val% EQU 0 (
    bcdedit /set {current} recoveryenabled yes >nul
    echo ^>  Recovery:           0 -^> 1
    exit /b
)
echo ^>  Recovery:           %val%
exit /b


rem ****************************************************************************
rem Set menu menu style for Win11
:Set_LagecyMenu
set val=0
for /f "tokens=6 delims=\" %%i in ('reg query "HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" 2^>nul') do (
    if "%%i"=="InprocServer32" ( set val=1 )
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg delete "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /f >nul
    echo ^>  Lagecy menu:        1 -^> 0
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg add "HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /f /ve >nul
    echo ^>  Lagecy menu:        0 -^> 1
    exit /b 0
)
echo ^>  Lagecy menu:        %val%
exit /b 0


rem ****************************************************************************
rem Set Show seconds in system Clock
:Set_ShowSeconds
set val=0
for /f "tokens=3" %%i in ('reg query "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" 2^>nul ^| find "ShowSecondsInSystemClock"') do (
    if "%%i"=="0x1" set val=1
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg delete "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /f >nul
    echo ^>  Show seconds:       1 -^> 0
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "ShowSecondsInSystemClock" /t "REG_DWORD" /d "1" /f >nul
    echo ^>  Show seconds:       0 -^> 1
    exit /b 0
)
echo ^>  Show seconds:       %val%
exit /b 0


rem ****************************************************************************
rem Set Auto Windows Update
:Set_AutoUpdate
set val=1
for /f "tokens=3" %%i in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" 2^>nul ^| find "NoAutoUpdate"') do (
    if "%%i"=="0x1" set val=0
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /t "REG_DWORD" /d "1" /f >nul
    echo ^>  Auto Update:        1 -^> 0
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v "NoAutoUpdate" /f >nul
    echo ^>  Auto Update:        0 -^> 1
    exit /b 0
)
echo ^>  Auto Update:        %val%
exit /b 0


rem ****************************************************************************
rem Set USB disk Auto play
:Set_UsbPrompt
set val=1
for /f "tokens=3" %%i in ('reg query "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" 2^>nul ^| find "DisableAutoplay"') do (
    if "%%i"=="0x1" set val=0
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /t "REG_DWORD" /d "1" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlersDefaultSelection\StorageOnArrival" /d "MSTakeNoAction" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\UserChosenExecuteHandlers\StorageOnArrival" /d "MSTakeNoAction" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlersDefaultSelection\CameraAlternate\ShowPicturesOnArrival" /d "MSTakeNoAction" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\UserChosenExecuteHandlers\CameraAlternate\ShowPicturesOnArrival" /d "MSTakeNoAction" /f >nul
    echo ^>  USB Prompt:         1 -^> 0
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" /v "DisableAutoplay" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlersDefaultSelection\StorageOnArrival" /d "MSPromptEachTime" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\UserChosenExecuteHandlers\StorageOnArrival" /d "MSPromptEachTime" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\EventHandlersDefaultSelection\CameraAlternate\ShowPicturesOnArrival" /d "MSPromptEachTime" /f >nul
    reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\UserChosenExecuteHandlers\CameraAlternate\ShowPicturesOnArrival" /d "MSPromptEachTime" /f >nul
    echo ^>  USB Prompt:         0 -^> 1
    exit /b 0
)
echo ^>  USB Prompt:         %val%
exit /b 0


rem ****************************************************************************
rem Set Remote desktop
:Set_RemoteDesktop
set val=1
for /f "tokens=3" %%i in ('reg query "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" 2^>nul ^| find "fDenyTSConnections"') do (
    if "%%i"=="0x1" set val=0
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t "REG_DWORD" /d 1 /f >nul
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "updateRDStatus" /t "REG_DWORD" /d 0 /f >nul
    netsh advfirewall firewall set rule group="remote desktop" new enable=No >nul
    echo ^>  Remote Desktop:     1 -^> 0
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "fDenyTSConnections" /t "REG_DWORD" /d 0 /f >nul
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v "updateRDStatus" /t "REG_DWORD" /d 1 /f >nul
    reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" /v "UserAuthentication" /t "REG_DWORD" /d 1 /f >nul
    netsh advfirewall firewall set rule group="remote desktop" new enable=Yes >nul
    echo ^>  Remote Desktop:     0 -^> 1
    exit /b 0
)
echo ^>  Remote Desktop:     %val%
exit /b 0


rem ****************************************************************************
rem Set AntiSpyWare
:Set_AntiSpyWare
set val=1
for /f "tokens=3" %%i in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" 2^>nul ^| find "DisableAntiSpyware"') do (
    if "%%i"=="0x1" set val=0
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /t "REG_DWORD" /d "1" /f >nul
    echo ^>  AntiSpyWare:        1 -^> 0
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg delete "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows Defender" /v "DisableAntiSpyware" /f >nul
    echo ^>  AntiSpyWare:        0 -^> 1
    exit /b 0
)
echo ^>  AntiSpyWare:        %val%
exit /b 0


rem ****************************************************************************
rem Set Show Hidden items and file exentions
:Set_ShowHidden
set val=1
for /f "tokens=3" %%i in ('reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" 2^>nul ^| find "HideFileExt"') do (
    if "%%i"=="0x1" set val=0
)
if "%~1" EQU "0" if %val% EQU 1 (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t "REG_DWORD" /d 2 /f >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t "REG_DWORD" /d 1 /f >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t "REG_DWORD" /d 2 /f >nul
    echo ^>  Show Hidden:        1 -^> 0
    exit /b 0
)
if "%~1" EQU "1" if %val% EQU 0 (
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "Hidden" /t "REG_DWORD" /d 1 /f >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t "REG_DWORD" /d 0 /f >nul
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "LaunchTo" /t "REG_DWORD" /d 1 /f >nul
    echo ^>  Show Hidden:        0 -^> 1
    exit /b 0
)
echo ^>  Show Hidden:        %val%
exit /b 0


rem ****************************************************************************
rem Set Test Signing mode
:Set_TestSigning
chcp 437 >nul
set val=0
for /f "tokens=2 delims= " %%i in ('bcdedit /enum {current} ^| find "testsigning"') do (
    if "%%i" EQU "Yes" set val=1
)
if "%~1" EQU "1" if %val% EQU 0 (
    for /f "usebackq tokens=2 delims= " %%i in (`bcdedit /enum {current} ^| findstr "identifier recoverysequence resumeobject"`) do bcdedit /set %%i testsigning on >nul
    echo ^>  Test Mode:        0 -^> 1
    exit /b 0
)
if "%~1" EQU "0" if %val% EQU 1 (
    for /f "usebackq tokens=2 delims= " %%i in (`bcdedit /enum {current} ^| findstr "identifier recoverysequence resumeobject"`) do bcdedit /set %%i testsigning off >nul
    echo ^>  Test Mode:        1 -^> 0
    exit /b 0
)
echo ^>  Test Mode:          %val%
exit /b 0
