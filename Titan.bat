@echo off
setLocal enableDelayedExpansion
rem For Titan WinPE.
rem By Q3aN 240304
set ver=v02

rem echo.
rem echo =====================================================
rem echo Welcome to Titan %ver%:
rem echo.

call :Init_Titan

rem echo.
rem echo =====================================================
rem echo.

endLocal
exit /b 0


rem ****************************************************************************
rem Initialize script for Titan WinPE.
rem Show the avaliable menu item.
:Init_Titan
setLocal enableDelayedExpansion
for %%i in (C D E F G H I J K L M N O P Q R X T U Y W X Y Z) do (
    if exist "%%i:\4-Misc\Scripts\WinInst.bat" (
        set "CleanOS_Path=%%i:\4-Misc\Scripts\WinInst.bat"
    )
    if exist "%%i:\1-Apps\7-Zip\7zFM.exe" (
        set "Explorer_Path=%%i:\1-Apps\7-Zip\7zFM.exe"
    )
    if exist "%%i:\1-Apps\WinClon\WCWizard.exe" (
        set "WinClon_Path=%%i:\1-Apps\WinClon\WCWizard.exe"
    )
    if exist "%%i:\Windows\System32\wpeinit.exe" (
        set "Wpeinit_Vol=%%i"
    )
)
if "%Wpeinit_Vol%" EQU "" ( 
    echo.
    echo =====================================================
    echo = Please run in WinPE Env. %ver%
    echo =====================================================
    echo.
    pause
    exit /b 0
)
call :Gen_Unattend %Wpeinit_Vol%
wpeinit /unattend="%Wpeinit_Vol%:\Windows\System32\unattend.xml"
cls
echo.
echo ===========================================================================
echo.
echo     /$$$$$$$$ /$$$$$$ /$$$$$$$$  /$$$$$$  /$$   /$$
echo    ^|__  $$__/^|_  $$_/^|__  $$__/ /$$__  $$^| $$$ ^| $$
echo       ^| $$     ^| $$     ^| $$   ^| $$  \ $$^| $$$$^| $$
echo       ^| $$     ^| $$     ^| $$   ^| $$$$$$$$^| $$ $$ $$
echo       ^| $$     ^| $$     ^| $$   ^| $$__  $$^| $$  $$$$
echo       ^| $$     ^| $$     ^| $$   ^| $$  ^| $$^| $$\  $$$
echo       ^| $$    /$$$$$$   ^| $$   ^| $$  ^| $$^| $$ \  $$
echo       ^|__/   ^|______/   ^|__/   ^|__/  ^|__/^|__/  \__/
echo.
echo  %ver%
echo ---------------------------------------------------------------------------
echo                                     Reboot: R    Shutdown: S
echo  Select:
echo @echo off > %Wpeinit_Vol%:\Windows\System32\R.bat
echo Wpeutil Reboot >> %Wpeinit_Vol%:\Windows\System32\R.bat
echo @echo off > %Wpeinit_Vol%:\Windows\System32\S.bat
echo Wpeutil Reboot >> %Wpeinit_Vol%:\Windows\System32\S.bat
if "%CleanOS_Path%" NEQ "" (
    echo   1. Clean OS
    echo @echo off > %Wpeinit_Vol%:\Windows\System32\1.bat
    echo %CleanOS_Path% >> %Wpeinit_Vol%:\Windows\System32\1.bat
)
if "%Explorer_Path%" NEQ "" (
    echo   2. Explorer
    echo @echo off > %Wpeinit_Vol%:\Windows\System32\2.bat
    echo %Explorer_Path% >> %Wpeinit_Vol%:\Windows\System32\2.bat
)
if "%WinClon_Path%" NEQ "" (
    echo   3. WinClon
    echo @echo off > %Wpeinit_Vol%:\Windows\System32\3.bat
    echo %WinClon_Path% >> %Wpeinit_Vol%:\Windows\System32\3.bat
) 
echo.
echo ===========================================================================
endLocal
exit /b 0


rem ****************************************************************************
rem Generate Unattend file to not enable Network
rem %~1 WinPE OS file volume
:Gen_Unattend
setLocal enableDelayedExpansion
set "Unattend_Path=%~1:\Windows\System32\unattend.xml"
echo ^<?xml version="1.0" encoding="utf-8"?^> > !Unattend_Path!
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^> >> !Unattend_Path!
echo     ^<settings pass="windowsPE"^> >> !Unattend_Path!
echo         ^<component name="Microsoft-Windows-Setup" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" processorArchitecture="AMD64"^> >> !Unattend_Path!
echo             ^<EnableNetwork^>false^</EnableNetwork^> >> !Unattend_Path!
echo         ^</component^> >> !Unattend_Path!
echo     ^</settings^> >> !Unattend_Path!
echo     ^<cpi:offlineImage cpi:source="" xmlns:cpi="urn:schemas-microsoft-com:cpi" /^> >> !Unattend_Path!
echo ^</unattend^> >> !Unattend_Path!
endLocal
exit /b 0

