@echo off
setLocal enableDelayedExpansion
rem Driver Backup
rem
rem This script will help exprot 3rd driver.
rem
rem By Q3aN 250125
set ver=v01

echo.
echo =====================================================
echo ^>
echo ^> Welcome to DrvBackup %ver%

call :Do_Prepare
call :Drv_Backup
call :Do_Ending %errorlevel%

echo ^>
echo =====================================================
echo.
endLocal
pause
exit /b


rem ****************************************************************************
rem Do the preparing job
:Do_Prepare
for /f "usebackq" %%i in (`powershell get-date -format "{yyMMdd}"`) do ( set "current_date=%%i" )
set out_dir=%USERPROFILE%\Desktop\Drv_%current_date%
if exist "%out_dir%" rmdir /s /q "%out_dir%"
mkdir "%out_dir%"
mkdir "%out_dir%\Drivers"
exit /b


rem ****************************************************************************
rem Do the preparing job
:Drv_Backup
set drv_num=
echo ^>
set /p "drv_num=> Enter OEM number to backup (0/1/.../)(u:inUse)(a:all): "
if /i "%drv_num%" EQU "a" goto backupAll
if /i "%drv_num%" EQU "all" goto backupAll
if /i "%drv_num%" EQU "u" goto backupUsing
if /i "%drv_num%" EQU "" exit /b 23
for /f "delims=0123456789" %%i in ("%drv_num%") do (
    if "%%i" NEQ "" exit /b 23
)
:backupOEM
mkdir "%out_dir%\Drivers\oem%drv_num%"
pnputil /export-driver oem%drv_num%.inf "%out_dir%\Drivers\oem%drv_num%"
set drv_num=
echo ^>
set /p "drv_num=> Enter OEM number to backup (0/1/.../): "
if /i "%drv_num%" EQU "" exit /b 0
for /f "delims=0123456789" %%i in ("%drv_num%") do (
    if "%%i" NEQ "" exit /b 0
)
goto backupOEM
:backupAll
pnputil /export-driver * "%out_dir%\Drivers"
exit /b
:backupUsing
for /f "tokens=2 delims=:" %%i in ('pnputil /enum-devices ^| find "oem"') do (
    set drv_oem=%%i
    set drv_oem=!drv_oem: =!
    echo !drv_oem!
)
echo ^>
set /p "choice=> Backup above drivers? (Y/N): "
if /i "%choice%" EQU "y" goto backupYes
exit /b 23
:backupYes
for /f "tokens=2 delims=:" %%a in ('pnputil /enum-devices ^| findstr "oem"') do (
    set drv_oem=%%a
    set drv_oem=!drv_oem: =!
    mkdir "%out_dir%\Drivers\!drv_oem!"
    pnputil /export-driver %%a "%out_dir%\Drivers\!drv_oem!"
)
exit /b


rem ****************************************************************************
rem Do the ending and clean up job
:Do_Ending
if "%~1" EQU "0" ( echo ^>
    echo ^> Success: "%out_dir%"
    call :Gen_DrvInst
) else if "%~1" EQU "23" ( echo ^>
    echo ^> Cancel
    if exist "%out_dir%" rmdir /s /q "%out_dir%"
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
rem Generate DrvInst.bat scirpt
:Gen_DrvInst
echo @echo off> "%out_dir%\DrvInst.bat"
echo setLocal enableDelayedExpansion>> "%out_dir%\DrvInst.bat"
echo call :AskAdmin>> "%out_dir%\DrvInst.bat"
echo if %%errorlevel%% EQU 0 pnputil /add-driver "%%bat_dir%%\*.inf" /subdirs /install>> "%out_dir%\DrvInst.bat"
echo endLocal>> "%out_dir%\DrvInst.bat"
echo if %%errorlevel%% NEQ 5 pause>> "%out_dir%\DrvInst.bat"
echo exit /b>> "%out_dir%\DrvInst.bat"
echo :AskAdmin>> "%out_dir%\DrvInst.bat"
echo set bat_dir=%%~dp0>> "%out_dir%\DrvInst.bat"
echo if "[%%1]" EQU "[49127c4b-02dc-482e-ac4f-ec4d659b7547]" set bat_dir=%%~2 ^&^& exit /b>> "%out_dir%\DrvInst.bat"
echo reg query HKU\S-1-5-19\Environment ^>nul 2^>^&1 ^&^& exit /b>> "%out_dir%\DrvInst.bat"
echo set command="""%%~f0""" 49127c4b-02dc-482e-ac4f-ec4d659b7547 %%~dp0>> "%out_dir%\DrvInst.bat"
echo set "command=^!command:'=''^!">> "%out_dir%\DrvInst.bat"
echo powershell -NoProfile Start-Process -FilePath '%%ComSpec%%' -ArgumentList '/c """^!command^!"""' -Verb RunAs 2^>nul>> "%out_dir%\DrvInst.bat"
echo if %%errorlevel%% GTR 0 exit /b ^4>> "%out_dir%\DrvInst.bat"
echo exit /b ^5>> "%out_dir%\DrvInst.bat"
exit /b
