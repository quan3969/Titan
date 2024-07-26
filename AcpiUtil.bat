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
rem By Q3aN 240724
set ver=v02
set bat_dir=%~dp0
set out_dir=%USERPROFILE%\Desktop\ASL_%date:~-2%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
echo.
echo =====================================================
echo ^>
echo ^> Welcome to AcpiUtil %ver%

mkdir %out_dir%
cd %out_dir%
%bat_dir%etc\acpidump.exe -b
%bat_dir%etc\iasl.exe -d %out_dir%\*.dat
if exist %out_dir%\*.dat ( del %out_dir%\*.dat )

mkdir %out_dir%\Resources
xcopy %bat_dir%etc\acpidump.exe %out_dir%\Resources
xcopy %bat_dir%etc\iasl.exe %out_dir%\Resources
xcopy %bat_dir%etc\asl.exe %out_dir%\Resources

echo Resources\iasl -vi dsdt.dsl> %out_dir%\CompileDSDT.bat
echo Resources\iasl -vi dsdt.dsl> %out_dir%\CompileLoadDSDT.bat
echo Resources\asl /loadtable -d dsdt.aml>> %out_dir%\CompileLoadDSDT.bat
echo Resources\asl /loadtable dsdt.aml /v>> %out_dir%\CompileLoadDSDT.bat
echo Resources\asl /loadtable -d dsdt.aml> %out_dir%\DeleteDSDT.bat
echo Resources\acpidump -b> %out_dir%\GetDSDT.bat
echo Resources\iasl -d dsdt.dat>> %out_dir%\GetDSDT.bat

echo ^>
echo =====================================================
echo.
endLocal
pause
exit /b
