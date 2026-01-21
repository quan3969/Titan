@echo off
setLocal enableDelayedExpansion

rem By Q3aN 260121
set "ver=v03"

rem Future feature:
rem  [x] ec ver
rem  [x] check sabi
rem  [x] pd ver
rem  [x] show ec, pd default
rem  [ ] user select ui
rem  [ ] set shipmode
rem  [ ] dci on/off
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
set "sabiscai=%bat_dir%\SabiScai.exe"
if "%errorlevel%" EQU "0" ( call :Check_Sabi )
if "%errorlevel%" EQU "0" if exist "%sabiscai%" (
    if "%param%" EQU "1" (
        call :Set_Shipmode
    ) else (
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
rem        3 - Sabi not support
rem        4 - Not admin (user click "No")
rem        5 - Not admin (user click "Yes", origin script, don't care)
:Do_Ending
if "%~1" EQU "0" ( echo ^>
    echo ^> Done
) else if "%~1" EQU "3" ( echo ^>
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
:Get_SabiVer
set "sabi_return="
set "sabi_format="
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 00`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
for /f "tokens=1,2" %%a in ("%sabi_return%") do (
    set "sabi_format=%%b%%a"
)
echo ^>   Sabi ver (00)           : %sabi_format%
exit /b


rem ****************************************************************************
rem Get EC ver
:Get_EcVer
set "dec="
set "sabi_return="
set "sabi_format="
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 46`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
for %%i in (%sabi_return%) do (
    set /a "dec=0x%%i"
    cmd /c exit !dec!
    set "sabi_format=!sabi_format!!=ExitCodeAscii!"
)
echo ^>   EC ver (46)             : %sabi_format%
exit /b


rem ****************************************************************************
rem Check SABI
:Check_Sabi
set "sabi_return="
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 00`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
if "%sabi_return%" EQU "" exit /b 3
exit /b


rem ****************************************************************************
rem Get PD ver
:Get_PdVer
set "sabi_return="
set "sabi_format="
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 7a 82 ef a9 01`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
for /f "tokens=7,8,9,10" %%a in ("%sabi_return%") do (
    set "pd_major_hex=%%c %%b %%a"
    set "pd_com_hex=%%d"
)
set /a "pd_ver=0x%pd_com_hex%"
set /a "pd_index=(pd_ver & 0xC0) >> 6"
set /a "pd_minor=pd_ver & 0x3F"
for %%i in (%pd_major_hex%) do (
    set /a "dec=0x%%i"
    cmd /c exit !dec!
    set "pd_major=!pd_major!!=ExitCodeAscii!"
)
set "sabi_format=%pd_major%.%pd_index%.%pd_minor%"
echo ^>   PD ver (7A 82 EF A9 01) : %sabi_format%
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
rem   - - - A9       # Get PD version
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
call :Get_SabiVer
call :Get_EcVer
call :Get_PdVer
echo ^>
echo ^>  Select:
echo ^>   1. Shipmode (7A 82 E8)
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
