@echo off
setLocal enableDelayedExpansion
rem ACPI Utility
rem 
rem Require:
rem   etc/asl https://learn.microsoft.com/en-us/windows-hardware/drivers/bringup/microsoft-asl-compiler
rem   etc/iasl https://acpica.org/downloads/binary-tools
rem 
rem Brief:
rem   1. Dump ASL Table dat : acpidump -b
rem   2. Convert dat to dal : iasl -d *.dat
rem   3. Convert dal to aml : iasl *.dsl
rem   4. Load aml to system : asl /loadtable *.aml
rem   5. Delete asl table   : asl /loadtable -d *.aml
rem
rem By Q3aN 250125
set ver=v03

echo.
echo =====================================================
echo ^>
echo ^> Welcome to AcpiUtil %ver%

call :Do_Prepare
if %errorlevel% EQU 0   ( call :Dump_Table )
if %errorlevel% EQU 0   ( call :Copy_Tools )
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
set bat_dir=%~dp0
if not exist "%bat_dir%etc\acpidump.exe" exit /b 77
if not exist "%bat_dir%etc\iasl.exe" exit /b 77
if not exist "%bat_dir%etc\asl.exe" exit /b 77
for /f "usebackq" %%i in (`powershell get-date -format "{yyMMdd}"`) do ( set "current_date=%%i" )
set out_dir=%USERPROFILE%\Desktop\ASL_%current_date%
if exist "%out_dir%" rmdir /s /q "%out_dir%"
mkdir "%out_dir%"
exit /b


rem ****************************************************************************
rem Do the ending and clean up job
:Do_Ending
if "%~1" EQU "0" ( echo ^>
    echo ^> Success
) else if "%~1" EQU "77" ( echo ^>
    echo ^> Tools not found
)
exit /b


rem ****************************************************************************
rem Dump ACPI Table
:Dump_Table
"%bat_dir%etc\acpidump.exe" -b
"%bat_dir%etc\iasl.exe" -d "%out_dir%\*.dat"
if exist "%out_dir%\*.dat" del "%out_dir%\*.dat"
exit /b


rem ****************************************************************************
rem Copy ASL tools
:Copy_Tools
mkdir "%out_dir%\Resources"
xcopy "%bat_dir%etc\acpidump.exe" "%out_dir%\Resources"
xcopy "%bat_dir%etc\iasl.exe" "%out_dir%\Resources"
xcopy "%bat_dir%etc\asl.exe" "%out_dir%\Resources"
echo Resources\iasl -vi dsdt.dsl> "%out_dir%\CompileDSDT.bat"
echo Resources\iasl -vi dsdt.dsl> "%out_dir%\CompileLoadDSDT.bat"
echo Resources\asl /loadtable -d dsdt.aml>> "%out_dir%\CompileLoadDSDT.bat"
echo Resources\asl /loadtable dsdt.aml /v>> "%out_dir%\CompileLoadDSDT.bat"
echo Resources\asl /loadtable -d dsdt.aml> "%out_dir%\DeleteDSDT.bat"
echo Resources\acpidump -b> "%out_dir%\GetDSDT.bat"
echo Resources\iasl -d dsdt.dat>> "%out_dir%\GetDSDT.bat"
exit /b
