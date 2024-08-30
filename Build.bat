@echo off
setLocal enableDelayedExpansion
rem For AMI AptioV project build.
rem By Q3aN 240829
set ver=v01

echo.
echo =====================================================
echo ^>
echo ^> Welcome to Build %ver%
set TOOLS_DIR=C:\Aptio_5.x_TOOLS_JRE_53\BuildTools
set PYTHON_COMMAND=py
set CHECKSUM_FILE=checksum.json
set path=%cd%;%path%;%TOOLS_DIR%
set BuildLog=Build.log
set VEB=
for /f "delims=." %%v in ('dir /b *.veb') do ( set "VEB=%%v" )
if /i "%~1" EQU "/c" ( set "in_para1=c" )
if /i "%~1" EQU "-c" ( set "in_para1=c" )
if /i "%~1" EQU "c"  ( set "in_para1=c" )
if /i "%~1" EQU "/g" ( set "in_para1=g" )
if /i "%~1" EQU "-g" ( set "in_para1=g" )
if /i "%~1" EQU "g"  ( set "in_para1=g" )
if "%in_para1%" EQU "c" (
    call :Clean
) else if "%in_para1%" EQU "g" (
    call :Gather
) else (
    call :BuildAll
    echo ^>
    echo ^> Press any key to gather build files ...
    pause >nul
    call :Gather
)
echo ^>
echo =====================================================
echo.

endLocal
exit /b 0


rem ****************************************************************************
rem Gather build files
:Clean
make clean
for /f "delims=" %%d in ('dir /ad/b/s /o-n') do @rd %%d 2>nul
exit /b 0


rem ****************************************************************************
rem Gather build files
:Gather
call :Save_Buildfiles
call :Do_Ending %errorlevel%
exit /b 0


rem ****************************************************************************
rem Build all, save logs and calulate duration
:BuildAll
set begin=%time%
powershell "make rebuild 2>&1 | Add-Content %BuildLog% -Passthru"
set end=%time%
set /a begin_sec=(%begin:~0,2%)*3600 + (1%begin:~3,2% %% 100)*60 + (1%begin:~6,2% %% 100)
set /a end_sec=(%end:~0,2%)*3600 + (1%end:~3,2% %% 100)*60 + (1%end:~6,2% %% 100)
set /a spend=%end_sec% - %begin_sec%
set /a spend_min=%spend% / 60
set /a spend_sec=%spend% - %spend_min%*60
set /a out_min=spend_min + 100
set /a out_sec=spend_sec + 100
powershell "echo '' 'Build total time: 00:%out_min:~1%:%out_sec:~1%' | Add-Content %BuildLog% -Passthru"
exit /b 0


rem ****************************************************************************
rem Check and save build output files
:Save_Buildfiles
:: 1. Check build complete
if not exist Build\Token.h (
    exit /b 6
)
set Debug_Mode=0
for /f "usebackq delims=" %%i in (`findstr /c:"#define DEBUG_MODE	1" Build\Token.h`) do (
    set Debug_Mode=1
)
:: 2. Check Samsung Project
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"SAMSUNG_BIOS_MAJOR_VERSION" Build\Token.h`) do (
    set Ver_Major=%%i
)
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"SAMSUNG_BIOS_MINOR_VERSION" Build\Token.h`) do (
    set Ver_Minor=%%i
)
set test_build=4
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"SAMSUNG_TEST_BIOS_VERSION" Build\Token.h`) do (
    set test_build=%%i
)
if "%Ver_Major%" NEQ "" (
    call :Save_Samsung %Ver_Major% %Ver_Minor% %Debug_Mode% %test_build%
    exit /b
)
:: 3. Check AMI project
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"RECOVERY_ROM" Build\Token.h`) do (
    set Rom_Name=%%i
)
if "%Rom_Name%" NEQ "" (
    call :Save_AMI %Rom_Name%
    exit /b
)
exit /b


rem ****************************************************************************
rem Do the ending and clean up job
rem %~1: Ending reason:
rem        0 - Success
rem        6 - Project not complied yet
:Do_Ending
if "%~1" EQU "0" ( echo ^>
    echo ^> Success
) else if "%~1" EQU "6" ( echo ^>
    echo ^> Project may not be compiled.
)
exit /b


rem ****************************************************************************
rem Save build output files for Samsung Project
rem %~1: Major version
rem %~2: Minor version
rem %~3: Debug mode
rem %~4: Test build (%~4 = 4 means not found)
:Save_Samsung
echo ^>
echo ^> Gather for Samsung project.
:: for E00JZR_01A
set Rom_Name=%~1_%~2
if "%~4" NEQ "4" (
    set Rom_Name=%Rom_Name%_%~4
)
if "%~3" EQU "1" (
    set Rom_Name=%Rom_Name%_dbg
)
:: for E00JZR01A
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"FWCAPSULE_FILE_NAME" Build\Token.h`) do (
    set Version_Now_Using=%%i
)
if %~1%~2 EQU %Version_Now_Using% (
    set Rom_Name=%~1%~2
)
if exist %Rom_Name% (del /s/q %Rom_Name%\*) else (mkdir %Rom_Name%)
if exist Build.log xcopy Build.log %Rom_Name%\
if exist Build\Token.h xcopy Build\Token.h %Rom_Name%\
if exist Build\Token.mak xcopy Build\Token.mak %Rom_Name%\
if exist Build\Platform.fdf xcopy Build\Platform.fdf %Rom_Name%\
if exist %Rom_Name%.bin xcopy %Rom_Name%.bin %Rom_Name%\
if exist %Rom_Name%.map xcopy %Rom_Name%.map %Rom_Name%\
if exist %~1.map xcopy %~1.map %Rom_Name%\
if exist %Rom_Name%.CAP xcopy %Rom_Name%.CAP %Rom_Name%\
if exist WIN_%Rom_Name%.exe xcopy WIN_%Rom_Name%.exe %Rom_Name%\
if exist Build\AmiCrbMeRoms\ME_FWUpdate.bin xcopy Build\AmiCrbMeRoms\ME_FWUpdate.bin %Rom_Name%\
if exist Build\AmiCrbMeRoms\ME_FWUpdate.map xcopy Build\AmiCrbMeRoms\ME_FWUpdate.map %Rom_Name%\
for /f "usebackq delims=" %%i in (`dir /b/s SetupDefaults.i ^| findstr /i /c:"Build"`) do (
    if "%%i" NEQ "" (xcopy %%i %Rom_Name%\)
)
for /f "usebackq tokens=1 delims=." %%i in (`dir /b ^| ^(findstr /i /c:".veb"^)`) do (
    set POJ_Name=%%i
)
for /f "usebackq delims=" %%i in (`dir /b/s "%POJ_Name%.map" ^| findstr /i /c:"Build"`) do (
    if exist %%i xcopy %%i %Rom_Name%\
)
for /f "usebackq delims=" %%i in (`dir /b *.cab ^| findstr /i /c:"%~1"`) do (
    if exist %%i xcopy %%i %Rom_Name%\
)
if exist WFU/%~1.cat xcopy WFU %Rom_Name%\WFU\
explorer %~dp0%ROM_Name%
exit /b 0


rem ****************************************************************************
rem Save build output files for AMI Project
rem %~1: Rom name
:Save_AMI
echo ^>
echo ^> Gather for AMI project.
if exist %~1 (del /q /s %~1\*) else (mkdir %~1)
if exist Build.log xcopy Build.log %~1\
if exist Build\Token.h xcopy Build\Token.h %~1\
if exist Build\Token.mak xcopy Build\Token.mak %~1\
if exist Build\Platform.fdf xcopy Build\Platform.fdf %Rom_Name%\
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
exit /b