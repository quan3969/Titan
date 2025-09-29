@echo off
setLocal enableDelayedExpansion
rem For Titan WinPE.
rem By Q3aN 250222
set ver=v03

rem Future feature:
rem  [ ] origin winpe setup

set end_pause=1

echo.
echo =====================================================
echo ^>
echo ^> Welcome to Titan %ver%

call :Do_Prepare %1
if %errorlevel% EQU 0   ( call :Init_Titan )
if %errorlevel% EQU 333 ( call :Covert_To_Swm %1 )
call :Do_Ending %errorlevel%

echo ^>
echo =====================================================
echo.

if "%end_pause%" EQU "1" ( pause )
endLocal
exit /b


rem ****************************************************************************
rem Do the ending and clean up job
rem %~1: Ending reason:
rem        0 - Success
rem      334 - Draw and drop file type not support
rem      335 - Cannot find Titan USB disk
rem      222 - Current is not in WinPE
:Do_Ending
if "%~1" EQU "0" ( echo ^>
    echo ^> Success
) else if "%~1" EQU "334" ( echo ^>
    echo ^> File not support
) else if "%~1" EQU "335" ( echo ^>
    echo ^> Titan USB not found
) else if "%~1" EQU "336" ( echo ^>
    echo ^> File already exist
) else if "%~1" EQU "222" ( echo ^>
    echo ^> Please run in WinPE Environment
) else ( echo ^>
    echo ^> Unknown error
)
exit /b


rem ****************************************************************************
rem Check and covert win / esd to swm file
rem %1: esd / win file
:Covert_To_Swm
set need_convert=0
set input_name=
set output_path=
set output_name=
set titan_exist=0
for /f "usebackq delims=" %%i in (`dir /b %1`) do (
    set input_name=%%i
)
set output_name=%input_name:~0,-3%swm
if /i "!input_name:~-3,3!" NEQ "esd" if /i "!input_name:~-3,3!" NEQ "wim" (
    exit /b 334
)
for /f "usebackq tokens=3 delims= " %%i in (`dir /-c %~1 ^| find "File(s)"`) do (
    if "%%i" GTR "4294967295" (
        set need_convert=1
    )
)
for %%i in (C D E F G H I J K L M N O P Q R X T U Y W X Y Z) do (
    if exist "%%i:\sources\Titan.bat" (
        set output_path=%%i:\sources
    )
)
if "%output_path%" EQU "" (
    exit /b 335
)
if "%need_convert%" EQU "1" (
    if not exist "%output_path%\%output_name%" (
        powershell -NoProfile Start-Process -FilePath '%ComSpec%' -ArgumentList '/c """echo. & echo Please wait... Copying: %output_path%\%output_name% & dism /split-image /imagefile:%1 /swmfile:"%output_path%\%output_name%" /filesize:3800 & pause"""' -Verb RunAs 2>nul
        set end_pause=0
    ) else (
        exit /b 336
    )
) else (
    if not exist "%output_path%\%input_name%" (
        echo ^>
        echo ^> Please wait... Copying: %output_path%\%input_name%
        xcopy %1 "%output_path%\" /q >nul
    ) else (
        exit /b 336
    )
)
exit /b 0


rem ****************************************************************************
rem Do the preparing job
rem %~1: User input or Draw and dropped file
rem Set errorlevel: 
rem      0   - No para
rem      333 - Para exist
:Do_Prepare
if "%~1" EQU "" (
    set end_pause=0
    exit /b 0
)
exit /b 333


rem ****************************************************************************
rem Initialize script for Titan WinPE.
rem Show the avaliable menu item.
:Init_Titan
for %%i in (C D E F G H I J K L M N O P Q R X T U Y W X Y Z) do (
    if exist "%%i:\4-Misc\Scripts\WinInst.bat" (
        set "cleanOS_path=%%i:\4-Misc\Scripts\WinInst.bat"
    )
    if exist "%%i:\1-Apps\7-Zip\7zFM.exe" (
        set "explorer_path=%%i:\1-Apps\7-Zip\7zFM.exe"
    )
    if exist "%%i:\1-Apps\WinClon\WCWizard.exe" (
        set "winClon_path=%%i:\1-Apps\WinClon\WCWizard.exe"
    )
    if exist "%%i:\Windows\System32\wpeinit.exe" (
        set "wpeinit_vol=%%i"
    )
)
if "%wpeinit_vol%" EQU "" (
    set end_pause=1
    exit /b 222
)
call :Gen_Unattend %wpeinit_vol%
wpeinit /unattend="%wpeinit_vol%:\Windows\System32\unattend.xml"
echo ^>
echo ^>  Select (Reboot: rr, Shutdown: ss):
echo Wpeutil Reboot > %wpeinit_vol%:\Windows\System32\rr.bat
echo Wpeutil Shutdown > %wpeinit_vol%:\Windows\System32\ss.bat
if "%cleanOS_path%" NEQ "" (
    echo ^>   1. Clean OS
    echo %cleanOS_path% > %wpeinit_vol%:\Windows\System32\1.bat
)
if "%explorer_path%" NEQ "" (
    echo ^>   2. Explorer
    echo %explorer_path% > %wpeinit_vol%:\Windows\System32\2.bat
)
if "%winClon_path%" NEQ "" (
    echo ^>   3. WinClon
    echo %winClon_path% > %wpeinit_vol%:\Windows\System32\3.bat
)
echo ^>   4. FFU
echo @echo ^^^> > %wpeinit_vol%:\Windows\System32\4.bat
echo @echo ^^^> DISM.exe /capture-ffu /imagefile=e:\WinOEM.ffu /capturedrive=\\.\PhysicalDrive0 /name:disk0 >> %wpeinit_vol%:\Windows\System32\4.bat
echo @echo ^^^> DISM /apply-ffu /ImageFile=N:\WinOEM.ffu /ApplyDrive:\\.\PhysicalDrive0 >> %wpeinit_vol%:\Windows\System32\4.bat
exit /b


rem ****************************************************************************
rem Generate Unattend file to not enable Network
rem %~1 WinPE OS file volume
:Gen_Unattend
set "unattend_path=%~1:\Windows\System32\unattend.xml"
echo ^<?xml version="1.0" encoding="utf-8"?^> > !unattend_path!
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^> >> !unattend_path!
echo     ^<settings pass="windowsPE"^> >> !unattend_path!
echo         ^<component name="Microsoft-Windows-Setup" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" processorArchitecture="AMD64"^> >> !unattend_path!
echo             ^<EnableNetwork^>false^</EnableNetwork^> >> !unattend_path!
echo         ^</component^> >> !unattend_path!
echo     ^</settings^> >> !unattend_path!
echo     ^<cpi:offlineImage cpi:source="" xmlns:cpi="urn:schemas-microsoft-com:cpi" /^> >> !unattend_path!
echo ^</unattend^> >> !unattend_path!
exit /b
