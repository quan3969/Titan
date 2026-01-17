@echo off
setLocal enableDelayedExpansion

rem By Q3aN 260117
set "ver=v1"

call :AskAdmin

echo.
echo =====================================================
echo ^>
echo ^> Welcome to GoSabi %ver%

set "param=%~1"
if defined param (
    set "param=!param:/=!"
    set "param=!param:-=!"
)
set "sabiscai=%~dp0%\SabiScai.exe"
if "%errorlevel%" EQU "0" if exist "%sabiscai%" (
    if "%param%" EQU "ec" (
        call :EcVer
    ) else if "%param%" EQU "pd" (
        call :Print_Help
    ) else (
        call :SabiVer
        call :Print_Help
    )
)

call :Do_Ending "%errorlevel%"

echo ^>
echo =====================================================
echo.

endLocal
if "%errorlevel%" NEQ "5" pause
exit /b

rem ****************************************************************************
rem Do the ending and clean up job
rem %~1: Ending reason:
rem        0 - Success
rem        4 - Not admin (user click "No")
rem        5 - Not admin (user click "Yes", origin script, don't care)
:Do_Ending
if "%~1" EQU "0" ( echo ^>
    echo ^> Done
) else if "%~1" EQU "1" ( echo ^>
    echo ^> Not support
) else if "%~1" EQU "4" ( echo ^>
    echo ^> Please run as administrator
) else if "%~1" EQU "5" ( echo ^>
    echo ^> Done
) else ( echo ^>
    echo ^> Unknown state
)
exit /b


rem ****************************************************************************
rem Get SABI ver
:SabiVer
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 00`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
set "b1=%sabi_return:~0,2%"
set "b2=%sabi_return:~3,2%"
set "sabi_fomat=%b2%%b1%"
echo ^>
echo ^> SABI ver: %sabi_fomat%
exit /b


rem ****************************************************************************
rem Print help
rem  00              # Get SABI ver
rem  04              # Get model name
rem  46              # Get EC version
rem  47              # PurchasedDate
rem   - 80           # Set/Del
rem  
rem  7A
rem   - 82           # Send Ec Command with Parameter
rem   - - E8         # Set Shipmode
rem   - - F5         # Disable ME
rem   - - EF         # Micom Special Command
rem   - - - 88       # Get TJ_MAX
rem   - - - BA       # Connector status
rem   - - - - 80     # Get DtoS connector status
rem   - - - - 81     # Get Display connector status
rem   - - A6         # Misc Control
rem   - - - 3C       # Get CPU temperature
rem  
rem  7B
rem   - 84           # Get OA key
rem   - - 00         # Get OA key[0]
rem   - - 01         # Get OA key[1]
rem   - - 02         # Get OA key[2]
rem   - - 03         # Get OA key[3]
rem   - - 04         # Get OA key[4]
rem  
rem  85              # BIOS policy control
rem   - 89           # ME service
rem   - - 80         # ME lock
rem   - - 82         # Check ME lock
rem  
rem  8D              # IO, Mem, PCI access
rem  
rem  94              # Set Maintenance Mode
rem   - 80           # Disable
rem   - 81           # Enable
rem   - - 06         # Password length
rem   - - - 31       # "100000"
rem  
rem  96              # Debug options
rem   - 80           # Get DCI status
rem   - 81           # Set DCI Status
rem   - - 80         # Off
rem   - - 81         # On
rem   - 82           # Get IBECC status
rem   - 83           # Set IBECC status
rem   - - 80         # Off
rem   - - 81         # On
:Print_Help
echo ^>
echo ^> Usage: GoSabi [options...]  Get SABI version (00)
echo ^>  ec                         Get EC version   (46)
echo ^>  pd                         Get PD version   ()
exit /b 0


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
