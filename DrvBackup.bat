@echo off

rem Presented by Q3aN.
rem 2023.05.12

cls
echo.
echo This script will help exprot 3rd driver.
echo.
set name=
set /p name=Enter folder name: 
if /i "%name%"=="" goto end
mkdir %USERPROFILE%\Desktop\%name%\Drivers

:backup
echo.
echo =====================================================
set number=
set /p number=Enter OEM number to backup (0/1/.../)(u:using)(a:all): 
if /i "%number%"=="a" goto backupAll
if /i "%number%"=="A" goto backupAll
if /i "%number%"=="u" goto backupUsing
if /i "%number%"=="U" goto backupUsing
if /i "%number%"=="" goto end

:backupOEM
pnputil /export-driver oem%number%.inf %USERPROFILE%\Desktop\%name%\Drivers
echo.
echo =====================================================
set number=
set /p number=Enter OEM number to backup (0/1/.../): 
if /i "%number%"=="" goto complete
goto backupOEM

:backupAll
pnputil /export-driver * %USERPROFILE%\Desktop\%name%\Drivers
goto complete

:backupUsing
for /f "tokens=2 delims=:" %%i in ('pnputil /enum-devices ^| findstr "oem"') do (
    echo %%i
)

echo.
echo =====================================================
set choice=
set /p choice=Backup above drivers? (Y/N):
if /i "%choice%"=="Y" goto backupYes
if /i "%choice%"=="y" goto backupYes
goto end

:backupYes
for /f "tokens=2 delims=:" %%a in ('pnputil /enum-devices ^| findstr "oem"') do (
    pnputil /export-driver %%a %USERPROFILE%\Desktop\%name%\Drivers
)

:complete
set output=%USERPROFILE%\Desktop\%name%\DrvInst.bat

rem ==========================================================================
echo @echo off > %output%
echo if "[%%1]" == "[49127c4b-02dc-482e-ac4f-ec4d659b7547]" goto :START_PROCESS >> %output%
echo REG QUERY HKU^\S-1-5-19^\Environment ^>NUL 2^>^&1 ^&^& goto :START_PROCESS >> %output%
echo set command="""%%~f0""" 49127c4b-02dc-482e-ac4f-ec4d659b7547 >> %output%
echo SETLOCAL ENABLEDELAYEDEXPANSION >> %output%
echo set "command=!command:'=''!" >> %output%
echo powershell -NoProfile Start-Process -FilePath '%%COMSPEC%%' ^^>>%output%
echo -ArgumentList '/c """!command!"""' -Verb RunAs 2^>NUL >> %output%
echo IF %%ERRORLEVEL%% GTR 0 ( >> %output%
echo     echo ===================================================== >> %output%
echo     echo This script needs to be executed as an administrator. >> %output%
echo     echo ===================================================== >> %output%
echo     echo. >> %output%
echo     pause >> %output%
echo ) >> %output%
echo SETLOCAL DISABLEDELAYEDEXPANSION >> %output%
echo goto :EOF >> %output%
echo :START_PROCESS >> %output%
echo pnputil /add-driver "%%~dp0*.inf" /subdirs /install >> %output%
echo pause >> %output%

rem ==========================================================================

echo.
echo =====================================================
echo Backup complete, check "%USERPROFILE%\Desktop\%name%" folder.
echo.

:end
pause
