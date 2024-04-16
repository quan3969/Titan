@echo off
setLocal enableDelayedExpansion
rem ACPI Utility
rem 
rem Require:
rem   etc/asl https://learn.microsoft.com/en-us/windows-hardware/drivers/bringup/microsoft-asl-compiler
rem   etc/iasl https://acpica.org/downloads/binary-tools
rem 
rem Brief:
rem   1. Dump system table to *dat
rem   2. Convert table to *.dal
rem   3. Compile table to *.aml
rem   4. Load new table to system and enable debug mode
rem   5. Delete table after finish
rem 
rem How to use:
rem   AcpiUtil.bat [option] [parameter]
rem   option:
rem     /r: Read system table
rem     /b: Build table (default)
rem     /w: Write table to system
rem     /d: Delete table from system
rem   parameter:
rem     dsdt (default)
rem
rem By Q3aN 240416
set ver=v01
set end_pause=1
set bat_dir=%~dp0
set para1=
set para2=
@REM call :AskAdmin %1 %2 %3
echo.
echo =====================================================
echo ^>
echo ^> Welcome to AcpiUtil %ver%
if %errorlevel% EQU 0   ( call :Do_Prepare %1 %2 %3 %4 )
if %errorlevel% EQU 0   ( call :BuildTable %para1% %para2% )
call :Do_Ending %errorlevel%
echo ^>
echo =====================================================
echo.
if "%end_pause%" EQU "1" ( pause )
endLocal
exit /b


rem ****************************************************************************
rem Dump, convert, compile, load, delete the table
rem %1: /r, /b, /w, /d
rem %2: table name
rem Check Parameters:
rem   /r: Dump and convert the table
rem   /b: Compile the table
rem   /w: Load the table
rem   /d: Delete the table
rem Set errorlevel:
rem   0: Success
rem   1: Acpi tool not found
rem   2: Administrator process run
:BuildTable
set "in_para1=b"
set "in_para2=dsdt"
if not exist %bat_dir%etc\iasl.exe ( exit /b 1 )
if not exist %bat_dir%etc\acpidump.exe ( exit /b 1 )
if not exist %bat_dir%etc\asl.exe ( exit /b 1 )
if /i "%~1" EQU "/r" ( set "in_para1=r" )
if /i "%~1" EQU "-r" ( set "in_para1=r" )
if /i "%~1" EQU "/b" ( set "in_para1=b" )
if /i "%~1" EQU "-b" ( set "in_para1=b" )
if /i "%~1" EQU "/w" ( set "in_para1=w" )
if /i "%~1" EQU "-w" ( set "in_para1=w" )
if /i "%~1" EQU "/d" ( set "in_para1=d" )
if /i "%~1" EQU "-d" ( set "in_para1=d" )
if "%in_para1%" EQU "r" (
    %bat_dir%etc\acpidump.exe -b
    %bat_dir%etc\iasl.exe -d %in_para2%.dat
    if exist %bat_dir%*.dat ( del %bat_dir%*.dat )
) else if "%in_para1%" EQU "b" (
    if not exist %bat_dir%%in_para2%.dsl (
        %bat_dir%etc\acpidump.exe -b
        %bat_dir%etc\iasl.exe -d %in_para2%.dat
        if exist %bat_dir%*.dat ( del %bat_dir%*.dat )
    )
    %bat_dir%etc\iasl.exe %bat_dir%%in_para2%.dsl
) else if "%in_para1%" EQU "w" (
    powershell -NoProfile Start-Process -FilePath '%ComSpec%' -ArgumentList '/c ^
    """%bat_dir%etc\asl.exe /loadtable -d %bat_dir%dsdt.aml & %bat_dir%etc\asl.exe /loadtable %bat_dir%dsdt.aml /v & pause"""' ^
    -Verb RunAs 2>nul
    exit /b 2
) else if "%in_para1%" EQU "d" (
    powershell -NoProfile Start-Process -FilePath '%ComSpec%' -ArgumentList '/c ^
    """%bat_dir%etc\asl.exe /loadtable -d %bat_dir%dsdt.aml & pause"""' ^
    -Verb RunAs 2>nul
    exit /b 2
)
exit /b


rem ****************************************************************************
rem Do the preparing job
rem %~1: User input or Draw and dropped file
rem Set para1: 1st parameter
rem Set para2: 2nd parameter
:Do_Prepare
if "%1" EQU "" (
    exit /b
)
if "[%1]" EQU "[49127c4b-02dc-482e-ac4f-ec4d659b7547]" if "%3" EQU "" (
    exit /b
)
if "[%1]" EQU "[49127c4b-02dc-482e-ac4f-ec4d659b7547]" (
    set para1=%3
    set para2=%4
    exit
)
set para1=%1
set para2=%2
exit /b


rem ****************************************************************************
rem Do the ending and clean up job
rem %~1: Ending reason:
rem        0 - Success
rem        1: Acpi tool not found
rem        2: Administrator process run
rem        4 - Not admin (user click "No")
rem        5 - Old session, should be closed (user click "Yes", )
:Do_Ending
if "%~1" EQU "0" ( echo ^>
    echo ^> Success
) else if "%~1" EQU "1" ( echo ^>
    echo ^> ACPI tool not found
) else if "%~1" EQU "2" ( echo ^>
    echo ^> Process run
    set end_pause=0
) else if "%~1" EQU "4" ( echo ^>
    echo ^> Please run as administrator
) else if "%~1" EQU "5" ( echo ^>
    set end_pause=0
)
exit /b


rem ****************************************************************************
rem Ask user for administrator privileges 
rem Set bat_dir: Current path
rem Set %errorlevel%: 
rem     0: Success
rem     4: User clicked "No"
rem     5: User clicked "Yes"
:AskAdmin
if "[%1]" == "[49127c4b-02dc-482e-ac4f-ec4d659b7547]" (
    set bat_dir=%~2
    exit /b 0
)
reg query HKU\S-1-5-19\Environment >nul 2>&1 && exit /b 0
set command="""%~f0""" 49127c4b-02dc-482e-ac4f-ec4d659b7547 %~dp0 %1
set "command=!command:'=''!"
powershell -NoProfile Start-Process -FilePath '%ComSpec%' ^
-ArgumentList '/c """!command!"""' -Verb RunAs 2>nul
if %errorlevel% GTR 0 (
    exit /b 4
)
exit /b 5

