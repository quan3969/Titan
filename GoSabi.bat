@echo off
setLocal enableDelayedExpansion

rem By Q3aN 260128
set "ver=v06"

rem Future feature:
rem  [x] ec ver
rem  [x] check sabi
rem  [x] pd ver
rem  [x] show ec, pd default
rem  [x] user select ui
rem  [x] set shipmode
rem  [x] me disable
rem  [x] dci on/off
rem  [x] hdmi ver
rem  [ ] oa key
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
if "%errorlevel%" EQU "0" ( call :Check_Sabi )
if "%errorlevel%" EQU "0" (
    call :Print_Menu
    if "!user_sel!" EQU "1" call :Set_Shipmode
    if "!user_sel!" EQU "2" call :Set_Dci
    if "!user_sel!" EQU "3" call :Set_PurchaseDate
    if "!user_sel!" EQU "4" call :Set_MeDisable
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
rem        2 - Sabiscai.exe not exist
rem        3 - Sabi not support
rem        4 - Not admin (user click "No")
rem        5 - Not admin (user click "Yes", origin script, don't care)
:Do_Ending
if "%~1" EQU "0" ( echo ^>
    echo ^> Done
) else if "%~1" EQU "2" ( echo ^>
    echo ^> Sabiscai.exe not exist
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
set "sabi_ver="
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 00`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
for /f "tokens=1,2" %%a in ("%sabi_return%") do (
    set "sabi_ver=%%b%%a"
)
exit /b


rem ****************************************************************************
rem Get EC ver
:Get_EcVer
set "dec="
set "sabi_return="
set "ec_ver="
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 46`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
for %%i in (%sabi_return%) do (
    set /a "dec=0x%%i"
    cmd /c exit !dec!
    set "ec_ver=!ec_ver!!=ExitCodeAscii!"
)
exit /b


rem ****************************************************************************
rem Check SABI
:Check_Sabi
set "sabiscai=%bat_dir%\SabiScai.exe"
if not exist "%sabiscai%" exit /b 2
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
set "pd_ver="
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 7a 82 ef a9 01`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
for /f "tokens=7,8,9,10" %%a in ("%sabi_return%") do (
    set "pd_major_hex=%%c %%b %%a"
    set "pd_com_hex=%%d"
)
set /a "pd_ver_hex=0x%pd_com_hex%"
set /a "pd_index=(pd_ver_hex & 0xC0) >> 6"
set /a "pd_minor=pd_ver_hex & 0x3F"
for %%i in (%pd_major_hex%) do (
    set /a "dec=0x%%i"
    cmd /c exit !dec!
    set "pd_major=!pd_major!!=ExitCodeAscii!"
)
set "pd_ver=%pd_major%.%pd_index%.%pd_minor%"
exit /b


rem ****************************************************************************
rem Set shipmode
:Set_Shipmode
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 7A 82 E8`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
echo ^>
echo ^> Return: %sabi_return%
exit /b


rem ****************************************************************************
rem Set ME disable
:Set_MeDisable
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 7A 82 F5`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
echo ^>
echo ^> Return: %sabi_return%
exit /b


rem ****************************************************************************
rem Set Purchase date
:Set_PurchaseDate
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 47`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
echo ^>
echo ^> Return: %sabi_return%
exit /b


rem ****************************************************************************
rem Set Dci
:Set_Dci
for /f "usebackq tokens=1,2,3,4,5,6,* delims= " %%a in (`"%sabiscai%" 96 81 81`) do (
    if "%%a" EQU "Output:" set "sabi_return=%%g"
)
echo ^>
echo ^> Return: %sabi_return%
exit /b


rem ****************************************************************************
rem Get HDMI ver (Chn 1)
rem     ForceHdmiRetimerPowerEnable(TRUE); 7A 82 EF AD 80
rem     MicroSecondDelay(50 * 1000); //Delay 50ms
rem     Status = EcGetHdmiRetimerVersion(&Major, &Minor);
rem       Status = EcReadFromI2c(SAMSUNG_HDMI_RETIMER_CHANNEL, 0xAC/*PAGE_14*/, 0xFE, Buffer, 1);
rem         7A 82 EF A7
rem         7A 82 EF A4 01 0D AC FE 01
rem         7A 82 EF A3 00
rem         7A 82 EF A1
rem       Status = EcReadFromI2c(SAMSUNG_HDMI_RETIMER_CHANNEL, 0xAC/*PAGE_14*/, 0xFF, Buffer, 1);
rem     ForceHdmiRetimerPowerEnable(FALSE); 7A 82 EF AD 81
:Get_HdmiVer
"%sabiscai%" 7A 82 EF AD 80 >nul
ping 127.0.0.1 -n 1 >nul
"%sabiscai%" 7A 82 EF A7 >nul
"%sabiscai%" 7A 82 EF A4 01 0D AC FE 01 >nul
for /f "usebackq tokens=1,2,3,4,5,6,11 delims= " %%a in (`"%sabiscai%" 7A 82 EF A3`) do (
    if "%%a" EQU "Output:" set "hdmi_ver_maj=%%g"
)
"%sabiscai%" 7A 82 EF A1 >nul
"%sabiscai%" 7A 82 EF A7 >nul
"%sabiscai%" 7A 82 EF A4 01 0D AC FF 01 >nul
for /f "usebackq tokens=1,2,3,4,5,6,11 delims= " %%a in (`"%sabiscai%" 7A 82 EF A3`) do (
    if "%%a" EQU "Output:" set "hdmi_ver_min=%%g"
)
"%sabiscai%" 7A 82 EF A1 >nul
"%sabiscai%" 7A 82 EF AD 81 >nul
set "hdmi_ver=!hdmi_ver_maj!.!hdmi_ver_min!"
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
rem   - - - A1       # Exit I2C mode
rem   - - - A3       # Get I2C buffer
rem   - - - A4       # Send I2C buffer
rem   - - - A7       # Enter I2C mode
rem   - - - AD       # SET_HDMI_RETIMER_POWER
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
:Print_Menu
call :Get_SabiVer
call :Get_EcVer
call :Get_PdVer
call :Get_HdmiVer
echo ^>
echo ^> Basic Info:
echo ^>  - Sabi (00)             : %sabi_ver%
echo ^>  - EC   (46)             : %ec_ver%
echo ^>  - PD   (7A 82 EF A9 01) : %pd_ver%
echo ^>  - HDMI (7A 82 EF AD)    : %hdmi_ver%
echo ^>
echo ^> Call SABI:
echo ^>  1. Shipmode      (7A 82 E8)
echo ^>  2. DCI Config    (96)
echo ^>  3. PurchasedDate (47)
echo ^>  4. Disable ME    (F5)
echo ^>
set /p "user_sel=> Select: "
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
