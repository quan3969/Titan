@echo off
rem Presented with heart by Q3aN.
rem 2022.12.10

if not exist "Token_s.h" goto Start_Sort
echo.
echo =====================================================
set /p choice=Clear up? (Y/y): 
if /i "%choice%"=="Y" goto Clear_Files
if /i "%choice%"=="y" goto Clear_Files

:Start_Sort
echo.
echo =====================================================
echo Please wait...
echo.
:: Sort Token.h
if exist "Token.h" goto Sort_1
goto Not_Sort_1
:Sort_1
sort "Token.h" > "Token_s.h"
:Not_Sort_1

:: Sort Token.mak
if exist "Token.mak" goto Sort_2
goto Not_Sort_2
:Sort_2
sort "Token.mak" > "Token_s.mak"
:Not_Sort_2

:: Sort SetupDefaults.i
if exist "SetupDefaults.i" goto Sort_3
goto Not_Sort_3
:Sort_3
if exist "SetupDefaults_s.i" del "SetupDefaults_s.i"
if exist "SetupDefaults_ss.i" del "SetupDefaults_ss.i"

for /f "usebackq delims=" %%a in (`findstr /c:"." "SetupDefaults.i" ^| findstr /v "#line"`) do (
    echo.%%a >>SetupDefaults_s.i
)

powershell -command "((get-content SetupDefaults_s.i) -replace 'STRING_TOKEN\(.......', '') -replace 'STRING_TOKEN \(.......', '' | set-content SetupDefaults_ss.i"

:Not_Sort_3
goto End

:Clear_Files
if exist "Token_s.h" del "Token_s.h"
if exist "Token_s.mak" del "Token_s.mak"
if exist "SetupDefaults.i" del "SetupDefaults_s.i"
if exist "SetupDefaults_ss.i" del "SetupDefaults_ss.i"
del BuildSort.bat

:End