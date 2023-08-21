@echo off
rem Presented with heart by Q3aN.
rem 2023.07.06

setlocal EnableDelayedExpansion

rem 1. Check build complete, store version
if not exist Build\Token.h goto Not_yet_build
set ROM_Name=
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"FWCAPSULE_FILE_NAME" Build\Token.h`) do (
    set ROM_Name=%%i
    goto Found_Samsung
)
set ROM_Name=
for /f "usebackq tokens=2 delims=	." %%i in (`findstr /i /c:"RECOVERY_ROM" Build\Token.h`) do (
    set ROM_Name=%%i
)


rem 2. Store needed files for AMI CRB project
echo.
echo =====================================================
echo Gather files for CRB project.
echo.
if exist %ROM_Name% (del /q %ROM_Name%\*) else (mkdir %ROM_Name%)
if exist Build.log xcopy Build.log %ROM_Name%\
if exist Build\Token.h xcopy Build\Token.h %ROM_Name%\
if exist Build\Token.mak xcopy Build\Token.mak %ROM_Name%\
if exist Build\AmiCrbMeRoms xcopy Build\AmiCrbMeRoms %ROM_Name%\AmiCrbMeRoms\
if exist %ROM_Name%.rom xcopy %ROM_Name%.rom %ROM_Name%\
for /f "usebackq delims=" %%i in (`dir /b/s SetupDefaults.i`) do (
    if "%%i" NEQ "" (xcopy %%i %ROM_Name%\)
)
for /f "usebackq tokens=1 delims=." %%i in (`dir /b ^| ^(findstr /i /c:".veb"^)`) do (
    set POJ_Name=%%i
)
for /f "usebackq delims=" %%i in (`dir /b/s "%POJ_Name%.map"`) do (
    if exist %%i xcopy %%i %ROM_Name%\
)
explorer %~dp0%ROM_Name%
goto End

rem 3. Store needed files for Samsung Project
:Found_Samsung
echo.
echo =====================================================
echo Gather files for Samsung project.
echo.
if exist %ROM_Name% (del /q %ROM_Name%\*) else (mkdir %ROM_Name%)
if exist Build.log xcopy Build.log %ROM_Name%\
if exist Build\Token.h xcopy Build\Token.h %ROM_Name%\
if exist Build\Token.mak xcopy Build\Token.mak %ROM_Name%\
if exist %ROM_Name%.BIN xcopy %ROM_Name%.BIN %ROM_Name%\
if exist %ROM_Name%.CAP xcopy %ROM_Name%.CAP %ROM_Name%\
for /f "usebackq tokens=2 delims=	" %%i in (`findstr /i /c:"SAMSUNG_ONEPACK_FILENAME" Build\Token.h`) do (
    if exist %%i.exe xcopy %%i.exe %ROM_Name%\
)
for /f "usebackq delims=" %%i in (`dir /b ^| ^(findstr /i /c:".cab"^)`) do (
    if exist %%i xcopy %%i %ROM_Name%\
)
for /f "usebackq delims=" %%i in (`dir /b/s SetupDefaults.i`) do (
    if "%%i" NEQ "" (xcopy %%i %ROM_Name%\)
)
for /f "usebackq tokens=1 delims=." %%i in (`dir /b ^| ^(findstr /i /c:".veb"^)`) do (
    set POJ_Name=%%i
)
for /f "usebackq delims=" %%i in (`dir /b/s "%POJ_Name%.map"`) do (
    if exist %%i xcopy %%i %ROM_Name%\
)
explorer %~dp0%ROM_Name%
goto End

:Not_yet_build
echo.
echo =====================================================
echo Project may bot be compiled.
echo.
pause

:End
