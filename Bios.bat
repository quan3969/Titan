@echo off
setLocal enableDelayedExpansion
rem For AMI AptioV project build.
rem By Q3aN 250902
set ver=v10

rem Future feature:
rem  [x] print help
rem  [x] support quick build command

echo.
echo =====================================================
echo ^>
echo ^> Welcome to BIOS %ver%

set "veb_ver=Aptio_5.x_TOOLS_JRE_59_x64"
set "VEB="
for /f "delims=." %%v in ('dir /b *.veb 2^>nul') do ( set "VEB=%%v" )
if "%VEB%" EQU "AlderLake" (
    set "veb_ver=Aptio_5.x_TOOLS_JRE_50!"
    set "EWDK_DIR=C:\EWDK"
)
if "%VEB%" EQU "RaptorLake" (
    set "veb_ver=Aptio_5.x_TOOLS_JRE_50!"
    set "EWDK_DIR=C:\EWDK"
)
set "VeB_Dir=C:\%veb_ver%"
set "TOOLS_DIR=%VeB_Dir%\BuildTools"
set "Java_Dir=%VeB_Dir%\VisualeBios\zulu\bin"
set "PYTHON_COMMAND=python"
set "CHECKSUM_FILE=checksum.json"
set "CLANG_BIN=C:\Program Files\LLVM\bin"
set "path=%cd%;%TOOLS_DIR%;%Java_Dir%;%path%;"
set "BuildLog=Build.log"
set "Tee_Exe=C:\PROGRA~1\Git\usr\bin\tee.exe"
rem === QuickBuild ===
set "qb_xml_file=qb.xml"
set "qb_micom_github_repo="
set "qb_micom_tag="
set "qb_bios_github_repo="
set "qb_bios_tag="
set "qb_build_option=single_build"
set "qb_bios_veb_tag=%veb_ver%"
set "qb_user_comment="
set "qb_user=jason.zheng"
set "qb_token=dlMb2xcUGPZ8ZyoE1Og7G766KavCVfTa4iQEaTvY"
set "qb_link=https://package.qb.sec.samsung.net"
set "qb_req_id="
set "qb_build_id="
rem === QuickBuild ===
call :Check_Python
set "param=%~1"
if defined param (
    set "param=!param:/=!"
    set "param=!param:-=!"
)
if "%param%" EQU "c" (
    call :Clean
) else if "%param%" EQU "g" (
    call :Gather
) else if "%param%" EQU "s" (
    call :Sort_Cmd "Token.h" "Token_s.h"
    call :Sort_Cmd "Token.mak" "Token_s.mak"
    call :Sort_Custom "SetupDefaults.i" "SetupDefaults_s.i"
) else if "%param%" EQU "asl" (
    call :Asl_Decode
) else if "%param%" EQU "h" (
    call :Print_Help
) else if "%param%" EQU "q" (
    call :Get_Info_For_Qb
    if !errorlevel! EQU 0 ( call :Gen_QbXml )
    if !errorlevel! EQU 0 ( call :Quick_Build )
) else (
    if exist %BuildLog% (
        for /f "usebackq" %%i in (`powershell ^(Get-Item "%BuildLog%"^).CreationTime.toString^('MM/dd/yyyy'^)`) do ( set "file_date=%%i" )
        for /f "usebackq" %%i in (`powershell get-date -format "{MM/dd/yyyy}"`) do ( set "current_date=%%i" )
        if "!file_date!" NEQ "!current_date!" ( call :Clean )
    )
    call :BuildAll
)

call :Do_Ending %errorlevel%

echo ^>
echo =====================================================
echo.

endLocal
exit /b


rem ****************************************************************************
rem Clean build files
:Clean
if "%VEB%" EQU "" (
    exit /b 7
)
make clean
git clean -x -d -f
for /f "delims=" %%d in ('dir /ad/b/s /o-n') do @rd %%d 2>nul
exit /b


rem ****************************************************************************
rem Gather build files
:Gather
call :Save_Buildfiles
exit /b


rem ****************************************************************************
rem Build all, save logs and calulate duration
:BuildAll
if "%VEB%" EQU "" (
    exit /b 7
)
set begin=%time%
set PYTHONUNBUFFERED=1
if exist %Tee_Exe% (
    make rebuild 2>&1 | %Tee_Exe% %BuildLog%
) else (
    make rebuild 2>&1
)
set end=%time%
set /a begin_sec=(%begin:~0,2%)*3600 + (1%begin:~3,2% %% 100)*60 + (1%begin:~6,2% %% 100)
set /a end_sec=(%end:~0,2%)*3600 + (1%end:~3,2% %% 100)*60 + (1%end:~6,2% %% 100)
set /a spend=%end_sec% - %begin_sec%
set /a spend_min=%spend% / 60
set /a spend_sec=%spend% - %spend_min%*60
set /a out_min=spend_min + 100
set /a out_sec=spend_sec + 100
if exist %Tee_Exe% (
    echo Build total time: 00:%out_min:~1%:%out_sec:~1% | %Tee_Exe% -a %BuildLog%
) else (
    echo Build total time: 00:%out_min:~1%:%out_sec:~1%
)
exit /b


rem ****************************************************************************
rem Check and save build output files
:Save_Buildfiles
rem
rem 1. Check build complete
rem
if "%VEB%" EQU "" (
    exit /b 7
)
if not exist Build\Token.h (
    exit /b 6
)
set Debug_Mode=0
for /f "usebackq delims=" %%i in (`findstr /c:"#define DEBUG_MODE	1" Build\Token.h`) do (
    set Debug_Mode=1
)
rem
rem 2. Check Samsung Project
rem
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:" SAMSUNG_BIOS_MAJOR_VERSION" Build\Token.h`) do (
    set Ver_Major=%%i
)
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:" SAMSUNG_BIOS_MINOR_VERSION" Build\Token.h`) do (
    set Ver_Minor=%%i
)
set test_build=4
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:" SAMSUNG_TEST_BIOS_VERSION" Build\Token.h`) do (
    set test_build=%%i
)
if "%Ver_Major%" NEQ "" (
    call :Save_Samsung %Ver_Major% %Ver_Minor% %Debug_Mode% %test_build%
    exit /b
)
rem
rem 3. Check Samsung project new format
rem
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:" SAMSUNG_BIOS_VERSION_MAJOR	" Build\Token.h`) do (
    set /a Ver_Major=%%i
)
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:" SAMSUNG_BIOS_VERSION_MINOR	" Build\Token.h`) do (
    set /a Ver_Minor=%%i
)
set test_build=4
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:" SAMSUNG_TEST_BIOS_VERSION	" Build\Token.h`) do (
    set test_build=%%i
)
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:" SAMSUNG_BIOS_TAG	" Build\Token.h`) do (
    set Ver_Tag=%%i
)
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:" SAMSUNG_BIOS_VERSION_RP	" Build\Token.h`) do (
    set /a Ver_RP=%%i
)
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:" SAMSUNG_BIOS_VERSION_BUILD	" Build\Token.h`) do (
    set /a Ver_Build=%%i
)
if "%Ver_Major%" NEQ "" (
    call :Save_Samsung_New %Ver_Major% %Ver_Minor% %Debug_Mode% %test_build% %Ver_Tag% %Ver_RP% %Ver_Build%
    exit /b
)
rem
rem 4. Check AMI project
rem
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:" RECOVERY_ROM" Build\Token.h`) do (
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
rem        0 - Done
rem        6 - Not complied yet
rem        7 - Not a Project folder
rem        8 - No aml file
:Do_Ending
if "%~1" EQU "0" ( echo ^>
    echo ^> Done
) else if "%~1" EQU "6" ( echo ^>
    echo ^> Not complied yet.
) else if "%~1" EQU "7" ( echo ^>
    echo ^> Not a Project folder.
) else if "%~1" EQU "8" ( echo ^>
    echo ^> No aml file.
) else if "%~1" EQU "9" ( echo ^>
    echo ^> Quick Build: HEAD not push yet.
) else if "%~1" EQU "10" ( echo ^>
    echo ^> Quick Build: Not a "github.sec.samsung.net" repo.
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
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:" FWCAPSULE_FILE_NAME" Build\Token.h`) do (
    set Version_Now_Using=%%i
)
if not exist %Rom_Name%.bin if %~1%~2 EQU %Version_Now_Using% (
    set Rom_Name=%~1%~2
)
if exist %Rom_Name% (del /s/q %Rom_Name%\*) else (mkdir %Rom_Name%)
if exist Build.log xcopy Build.log %Rom_Name%\
if exist Build\Token.h xcopy Build\Token.h %Rom_Name%\
if exist Build\Token.mak xcopy Build\Token.mak %Rom_Name%\
if exist Build\Platform.fdf xcopy Build\Platform.fdf %Rom_Name%\
if exist Build\Platform.dsc xcopy Build\Platform.dsc %Rom_Name%\
if exist %Rom_Name%.bin xcopy %Rom_Name%.bin %Rom_Name%\
if exist %Rom_Name%.map xcopy %Rom_Name%.map %Rom_Name%\
if exist %Rom_Name%.txt xcopy %Rom_Name%.txt %Rom_Name%\
if exist %~1.map xcopy %~1.map %Rom_Name%\
if exist %~1.txt xcopy %~1.txt %Rom_Name%\
if exist %Rom_Name%.cap xcopy %Rom_Name%.cap %Rom_Name%\
if exist WIN_%Rom_Name%.exe xcopy WIN_%Rom_Name%.exe %Rom_Name%\
if exist Build\AmiCrbMeRoms\ME_FWUpdate.bin xcopy Build\AmiCrbMeRoms\ME_FWUpdate.bin %Rom_Name%\
if exist Build\AmiCrbMeRoms\ME_FWUpdate.map xcopy Build\AmiCrbMeRoms\ME_FWUpdate.map %Rom_Name%\
if exist Build\AmiCrbMeRoms\ME_FWUpdate.txt xcopy Build\AmiCrbMeRoms\ME_FWUpdate.txt %Rom_Name%\
for /f "usebackq delims=" %%i in (`dir /b/s SetupDefaults.i ^| find "Build"`) do (
    if "%%i" NEQ "" (xcopy %%i %Rom_Name%\)
)
for /f "usebackq delims=" %%i in (`dir /b/s SetupDefaultsStrDefs.h ^| find "Build"`) do (
    if "%%i" NEQ "" (xcopy %%i %Rom_Name%\)
)
for /f "usebackq tokens=1 delims=." %%i in (`dir /b ^| ^(findstr /i /c:".veb"^)`) do (
    set POJ_Name=%%i
)
for /f "usebackq delims=" %%i in (`dir /b/s "%POJ_Name%.map" ^| find "Build"`) do (
    if exist %%i xcopy %%i %Rom_Name%\
)
for /f "usebackq delims=" %%i in (`dir /b *.cab 2^>nul ^| findstr /i /c:"%~1"`) do (
    if exist %%i xcopy %%i %Rom_Name%\
)
for /f "usebackq delims=" %%i in (`dir /b/s *.aml ^| find "Build"`) do (
    if exist %%i xcopy %%i %Rom_Name%\ACPI\
)
if exist WFU/%~1.cat xcopy WFU %Rom_Name%\WFU\
explorer %ROM_Name%
exit /b


rem ****************************************************************************
rem Save build output files for Samsung Project new format
rem %~1: Major
rem %~2: Minor
rem %~3: Debug mode
rem %~4: Test build (%~4 = 4 means not found)
rem %~5: Tag
rem %~6: RP
rem %~7: Build
:Save_Samsung_New
echo ^>
echo ^> Gather for Samsung project new format.
rem
rem ERHK.0.0.2.11_mem.bin
rem
set Rom_Name=%~5.%~6.%~1.%~2.%~7
if "%~4" NEQ "4" (
    set Rom_Name=%Rom_Name%_%~4
)
if "%~3" EQU "1" (
    set Rom_Name=%Rom_Name%_dbg
)
if exist %Rom_Name% (del /s/q %Rom_Name%\*) else (mkdir %Rom_Name%)
if exist Build.log xcopy Build.log %Rom_Name%\
if exist Build\Token.h xcopy Build\Token.h %Rom_Name%\
if exist Build\Token.mak xcopy Build\Token.mak %Rom_Name%\
if exist Build\Platform.fdf xcopy Build\Platform.fdf %Rom_Name%\
if exist Build\Platform.dsc xcopy Build\Platform.dsc %Rom_Name%\
if exist %~5.map xcopy %~5.map %Rom_Name%\
if exist %~5.txt xcopy %~5.txt %Rom_Name%\
if exist %Rom_Name%.bin xcopy %Rom_Name%.bin %Rom_Name%\
if exist %Rom_Name%.cap xcopy %Rom_Name%.cap %Rom_Name%\
if exist WIN_%Rom_Name%.exe xcopy WIN_%Rom_Name%.exe %Rom_Name%\
if exist Build\AmiCrbMeRoms\ME_FWUpdate.bin xcopy Build\AmiCrbMeRoms\ME_FWUpdate.bin %Rom_Name%\
if exist Build\AmiCrbMeRoms\ME_FWUpdate.map xcopy Build\AmiCrbMeRoms\ME_FWUpdate.map %Rom_Name%\
if exist Build\AmiCrbMeRoms\ME_FWUpdate.txt xcopy Build\AmiCrbMeRoms\ME_FWUpdate.txt %Rom_Name%\
for /f "usebackq delims=" %%i in (`dir /b/s SetupDefaults.i ^| find "Build"`) do (
    if "%%i" NEQ "" (xcopy %%i %Rom_Name%\)
)
for /f "usebackq delims=" %%i in (`dir /b/s SetupDefaultsStrDefs.h ^| find "Build"`) do (
    if "%%i" NEQ "" (xcopy %%i %Rom_Name%\)
)
for /f "usebackq tokens=1 delims=." %%i in (`dir /b ^| ^(findstr /i /c:".veb"^)`) do (
    set POJ_Name=%%i
)
for /f "usebackq delims=" %%i in (`dir /b/s "%POJ_Name%.map" ^| find "Build"`) do (
    if exist %%i xcopy %%i %Rom_Name%\
)
for /f "usebackq delims=" %%i in (`dir /b/s *.aml ^| find "Build"`) do (
    if exist %%i xcopy %%i %Rom_Name%\ACPI\
)
explorer %ROM_Name%
exit /b


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
if exist Build\Platform.dsc xcopy Build\Platform.dsc %Rom_Name%\
if exist Build\AmiCrbMeRoms xcopy Build\AmiCrbMeRoms %~1\AmiCrbMeRoms\
if exist %~1.rom xcopy %~1.rom %~1\
for /f "usebackq delims=" %%i in (`dir /b/s SetupDefaults.i ^| find "Build"`) do (
    if "%%i" NEQ "" (xcopy %%i %~1\)
)
for /f "usebackq delims=" %%i in (`dir /b/s SetupDefaultsStrDefs.h ^| findstr /i /c:"Build"`) do (
    if "%%i" NEQ "" (xcopy %%i %~1\)
)
for /f "usebackq tokens=1 delims=." %%i in (`dir /b ^| ^(findstr /i /c:".veb"^)`) do (
    set POJ_Name=%%i
)
for /f "usebackq delims=" %%i in (`dir /b/s "%POJ_Name%.map" ^| findstr /i /c:"Build"`) do (
    if exist %%i xcopy %%i %~1\
)
for /f "usebackq delims=" %%i in (`dir /b/s *.aml ^| find "Build"`) do (
    if exist %%i xcopy %%i %Rom_Name%\ACPI\
)
explorer %~1
exit /b


rem ****************************************************************************
rem Check Python Path, make sure "python" can call python
rem   If "py" avaliable but "python" not, means py was install by installer
rem   without checking "add python to path"
:Check_Python
for /f "usebackq" %%i in (`where python 2^>nul ^| find /v "WindowsApps\python.exe"`) do (
    exit /b
)
where py 1>nul 2>nul
if "%errorlevel%" NEQ "0" (
    echo Python Path check fail
    exit /b 99
)
for /f "tokens=1 delims=[" %%a in ('py -h ^| find "python.exe"') do (
  set python_exe=%%a
  set python_dir=!python_exe:~7,-12!
)
set path=%python_dir%;%path%;
exit /b


rem ****************************************************************************
rem Use CMD command to sort file line by name
rem   %~1: file input
rem   %~2: file output
:Sort_Cmd
if not exist %~1 (
    echo ^>
    echo ^> %~1 not found.
    exit /b 0
)
echo ^>
echo ^> Sorting: %~1
sort %~1 > %~2
exit /b 0


rem ****************************************************************************
rem Use custom command to sort file and remove unwanted string
rem   %~1: file input
rem   %~2: file output
:Sort_Custom
if not exist %~1 (
    echo ^>
    echo ^> %~1 not found.
    exit /b 0
)
if exist %~2 (
    del %~2
)
echo ^>
echo ^> Sorting: %~1
for /f "usebackq delims=" %%a in (`findstr /c:"." %~1 ^| findstr /v "#line"`) do (
    echo.%%a >>%~2
)
for %%a in (
    "((((get-content %~2) " 
    "-replace 'STRING_TOKEN\(.......', '') "
    "-replace 'STRING_TOKEN \(.......', '') "
    "-replace 'questionid = .....', 'questionid = ') "
    "-replace 'key = .....', 'key = ' "
    "| set-content %~2"
) do set Cmd_Exc=!Cmd_Exc!%%~a
powershell -command "%Cmd_Exc%"
exit /b 0


rem ****************************************************************************
rem Decode ACPI aml file to readable asl file
:Asl_Decode
if not exist *.aml (
    exit /b 8
)
for /f "usebackq delims=" %%i in (`dir /b/s *.aml`) do (
    iasl6 -d %%i
)
exit /b 0


rem ****************************************************************************
rem Print help
:Print_Help
echo ^>
echo ^> Usage: bios [options...]    Start BIOS build
echo ^>  h, /h, -h                  Get help for commands
echo ^>  c, /c, -c                  Clean project folder
echo ^>  g, /g, -g                  Gather project build files
echo ^>  s, /s, -s                  Sort build files for compare
echo ^>  q, /q, -q                  Trigger a quick build request
echo ^>  asl, /asl, -asl            Convert ACPI aml file to readable dsl file
exit /b 0


rem ****************************************************************************
rem Generate qb.xml file
:Gen_QbXml
echo ^<?xml version='1.0' encoding='utf-8'?^> > %qb_xml_file%
echo ^<com.pmease.quickbuild.BuildRequest^> >> %qb_xml_file%
echo     ^<configurationId^>160721^</configurationId^> >> %qb_xml_file%
echo     ^<variables^> >> %qb_xml_file%
echo         ^<entry^> >> %qb_xml_file%
echo             ^<string^>MICOM_ENVIRONMENT^</string^> >> %qb_xml_file%
echo             ^<string^>2023^</string^> >> %qb_xml_file%
echo         ^</entry^> >> %qb_xml_file%
echo         ^<entry^> >> %qb_xml_file%
echo             ^<string^>MICOM_GITHUB_REPO^</string^> >> %qb_xml_file%
echo             ^<string^>%qb_micom_github_repo%^</string^> >> %qb_xml_file%
echo         ^</entry^> >> %qb_xml_file%
echo         ^<entry^> >> %qb_xml_file%
echo             ^<string^>MICOM_TAG^</string^> >> %qb_xml_file%
echo             ^<string^>%qb_micom_tag%^</string^> >> %qb_xml_file%
echo         ^</entry^> >> %qb_xml_file%
echo         ^<entry^> >> %qb_xml_file%
echo             ^<string^>BIOS_ENVIRONMENT^</string^> >> %qb_xml_file%
echo             ^<string^>2023^</string^> >> %qb_xml_file%
echo         ^</entry^> >> %qb_xml_file%
echo         ^<entry^> >> %qb_xml_file%
echo             ^<string^>BIOS_GITHUB_REPO^</string^> >> %qb_xml_file%
echo             ^<string^>%qb_bios_github_repo%^</string^> >> %qb_xml_file%
echo         ^</entry^> >> %qb_xml_file%
echo         ^<entry^> >> %qb_xml_file%
echo             ^<string^>BIOS_TAG^</string^> >> %qb_xml_file%
echo             ^<string^>%qb_bios_tag%^</string^> >> %qb_xml_file%
echo         ^</entry^> >> %qb_xml_file%
echo         ^<entry^> >> %qb_xml_file%
echo             ^<string^>BIOS_VEB_GITHUB_REPO^</string^> >> %qb_xml_file%
echo             ^<string^>MD7-PC-TEAM/TOOLS_Aptio_5.x_TOOLS_JRE^</string^> >> %qb_xml_file%
echo         ^</entry^> >> %qb_xml_file%
echo         ^<entry^> >> %qb_xml_file%
echo             ^<string^>BIOS_VEB_TAG^</string^> >> %qb_xml_file%
echo             ^<string^>%qb_bios_veb_tag%^</string^> >> %qb_xml_file%
echo         ^</entry^> >> %qb_xml_file%
echo         ^<entry^> >> %qb_xml_file%
echo             ^<string^>BUILD_OPTION^</string^> >> %qb_xml_file%
echo             ^<string^>%qb_build_option%^</string^> >> %qb_xml_file%
echo         ^</entry^> >> %qb_xml_file%
echo         ^<entry^> >> %qb_xml_file%
echo             ^<string^>REPO_TYPE^</string^> >> %qb_xml_file%
echo             ^<string^>github^</string^> >> %qb_xml_file%
echo         ^</entry^> >> %qb_xml_file%
echo         ^<entry^> >> %qb_xml_file%
echo             ^<string^>USER_COMMENT^</string^> >> %qb_xml_file%
echo             ^<string^>%qb_user_comment%^</string^> >> %qb_xml_file%
echo         ^</entry^> >> %qb_xml_file%
echo     ^</variables^> >> %qb_xml_file%
echo ^</com.pmease.quickbuild.BuildRequest^> >> %qb_xml_file%
exit /b 0


rem ****************************************************************************
rem Trigger a quick build and get link
rem   curl -u jason.zheng:dlMb2xcUGPZ8ZyoE1Og7G766KavCVfTa4iQEaTvY -d@qb.xml https://package.qb.sec.samsung.net/rest/build_requests
rem   curl -u jason.zheng:dlMb2xcUGPZ8ZyoE1Og7G766KavCVfTa4iQEaTvY https://package.qb.sec.samsung.net/rest/ids?request_id=6eca287b-a75f-4d3f-8c66-b2e83c2727c8
rem   Link: https://package.qb.sec.samsung.net/build/170912335
:Quick_Build
for /f "usebackq tokens=3 delims=<>" %%i in (`curl -u %qb_user%:%qb_token% -d@qb.xml %qb_link%/rest/build_requests 2^>nul ^| find "requestId"`) do (
    set "qb_req_id=%%i"
)
PING -n 2 127.0.0.1 > nul
for /f "usebackq" %%i in (`curl -u %qb_user%:%qb_token% %qb_link%/rest/ids?request_id^=!qb_req_id! 2^>nul`) do (
    set "qb_build_id=%%i"
)
echo ^>
echo ^> Quick Build: https://package.qb.sec.samsung.net/build/!qb_build_id!
exit /b 0


rem ****************************************************************************
rem Check current folder is github.sec.samsung.net, check
rem  curent HEAD is on remote git
rem   git config --get remote.origin.url
rem   git rev-parse --short=7 HEAD
:Get_Info_For_Qb
for /f "usebackq tokens=6,7 delims=/." %%i in (`git config --get remote.origin.url ^| find "github.sec.samsung.net"`) do (
    set "qb_bios_github_repo=%%i/%%j"
)
if "%qb_bios_github_repo%" EQU "" (
    exit /b 10
)
for /f "usebackq" %%i in (`git rev-parse --short^=7 HEAD`) do (
    set "qb_bios_tag=%%i"
)
set "org_exist=0"
for /f "usebackq" %%i in (`git ls-remote origin ^| find "!qb_bios_tag!"`) do (
    set "org_exist=1"
)
if "%org_exist%" NEQ "1" (
    exit /b 9
)
exit /b 0
