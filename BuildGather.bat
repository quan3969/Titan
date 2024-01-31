@echo off
setLocal enableDelayedExpansion
rem By Q3aN 240131
set ver=v02

echo.
echo =====================================================
echo Welcome to BuildGather %ver%, gather build output:
echo.

call :Save_Buildfiles

echo.
echo =====================================================
echo.

endLocal
exit /b 0

rem ****************************************************************************
rem Check and save build output files
:Save_Buildfiles
setLocal enableDelayedExpansion
:: 1. Check build complete
if not exist Build\Token.h (
    echo.
    echo ^> Project may bot be compiled.
    echo.
    pause
    exit /b 0
)
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"DEBUG_MODE" Build\Token.h`) do (
    set Debug_Mode=%%i
)
:: 2. Check Samsung Project
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"SAMSUNG_BIOS_MAJOR_VERSION" Build\Token.h`) do (
    set Ver_Major=%%i
)
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"SAMSUNG_BIOS_MINOR_VERSION" Build\Token.h`) do (
    set Ver_Minor=%%i
)
if "%Ver_Major%" NEQ "" (
    call :Save_Samsung %Ver_Major% %Ver_Minor% %Debug_Mode%
    exit /b 0
)
:: 3. Check AMI project
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"RECOVERY_ROM" Build\Token.h`) do (
    set Rom_Name=%%i
)
if "%Rom_Name%" NEQ "" (
    call :Save_AMI %Rom_Name%
    exit /b 0
)
endLocal
exit /b 0

rem ****************************************************************************
rem Save build output files for Samsung Project
rem %~1: Major version
rem %~2: Minor version
rem %~3: Debug mode
:Save_Samsung
setLocal enableDelayedExpansion
echo.
echo ^> Gather files for Samsung project.
echo.
:: for E00JZR_01A
if "%~3" EQU "1" (
    set Rom_Name=%~1_%~2_dbg
) else (
    set Rom_Name=%~1_%~2
)
:: for E00JZR01A
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"FWCAPSULE_FILE_NAME" Build\Token.h`) do (
    set Version_Now_Using=%%i
)
if %~1%~2 EQU %Version_Now_Using% (
    set Rom_Name=%~1%~2
)
if exist %Rom_Name% (del /q %Rom_Name%\*) else (mkdir %Rom_Name%)
if exist Build.log xcopy Build.log %Rom_Name%\
if exist Build\Token.h xcopy Build\Token.h %Rom_Name%\
if exist Build\Token.mak xcopy Build\Token.mak %Rom_Name%\
if exist %Rom_Name%.BIN xcopy %Rom_Name%.BIN %Rom_Name%\
if exist %Rom_Name%.map xcopy %Rom_Name%.map %Rom_Name%\
if exist %~1.map xcopy %~1.map %Rom_Name%\
if exist %Rom_Name%.CAP xcopy %Rom_Name%.CAP %Rom_Name%\
if exist WIN_%~1_%~2.exe xcopy WIN_%~1_%~2.exe %Rom_Name%\
if exist WIN_%~1_%~2_dbg.exe xcopy WIN_%~1_%~2.exe %Rom_Name%\
for /f "usebackq delims=" %%i in (`dir /b/s SetupDefaults.i ^| findstr /i /c:"Build"`) do (
    if "%%i" NEQ "" (xcopy %%i %Rom_Name%\)
)
for /f "usebackq tokens=1 delims=." %%i in (`dir /b ^| ^(findstr /i /c:".veb"^)`) do (
    set POJ_Name=%%i
)
for /f "usebackq delims=" %%i in (`dir /b/s "%POJ_Name%.map" ^| findstr /i /c:"Build"`) do (
    if exist %%i xcopy %%i %Rom_Name%\
)
explorer %~dp0%ROM_Name%
endLocal
exit /b 0

rem ****************************************************************************
rem Save build output files for AMI Project
rem %~1: Rom name
:Save_AMI
setLocal enableDelayedExpansion
echo.
echo ^> Gather files for CRB project.
echo.
if exist %~1 (del /q /s %~1\*) else (mkdir %~1)
if exist Build.log xcopy Build.log %~1\
if exist Build\Token.h xcopy Build\Token.h %~1\
if exist Build\Token.mak xcopy Build\Token.mak %~1\
if exist Build\AmiCrbMeRoms xcopy Build\AmiCrbMeRoms %~1\AmiCrbMeRoms\
if exist %~1.rom xcopy %~1.rom %~1\
for /f "usebackq delims=" %%i in (`dir /b/s SetupDefaults.i ^| findstr /i /c:"Build"`) do (
    if "%%i" NEQ "" (xcopy %%i %~1\)
)
for /f "usebackq tokens=1 delims=." %%i in (`dir /b ^| ^(findstr /i /c:".veb"^)`) do (
    set POJ_Name=%%i
)
for /f "usebackq delims=" %%i in (`dir /b/s "%POJ_Name%.map" ^| findstr /i /c:"Build"`) do (
    if exist %%i xcopy %%i %~1\
)
explorer %~dp0%~1
endLocal
exit /b 0
