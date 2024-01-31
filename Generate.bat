@echo off
setLocal enableDelayedExpansion
rem Fine BIOS update files and generate script for easy update.
rem By Q3aN 240131
set ver=v01

echo.
echo =====================================================
echo Welcome to Generate %ver%, output now:
echo.

set "LNL_ID=JZR"
set "MTL_ID=RHA RHB RHD"
set "RPL_ID=RGU RGS RGT RHC"
set "ADL_ID=RGG RGE RGF RGL RGM RGL"
set "TGL_ID=RFX RFW"
set "CML_ID=RFG"

set "DnX_LNL=Intel(R) LunarLake M Chipset - DnX Recovery Image"
set "DnX_MTL=Intel(R) MeteorLake P Chipset - DnX Recovery Image"
set "DnX_RPL=Intel(R) AlderLake P Chipset - DnX Recovery Image"

set "AFU_Para1=/p /b /n /capsule /q"
set "Para1_Support=LNL MTL"
set "AFU_Para2=/p /b /n /r /e /capsule /q"
set "Para2_Support=RPL ADL TGL CML"

set ID_PW=
for %%a in (
    "JZR-VENUS5 " 
    "RHA-Venus4 "
    "RHB-Mars4 "
    "RGU-Venus3 "
    "RGS-Venus3 "
    "RGF-Venus2 "
    "RGM-Venus2 "
) do ( set "ID_PW=!ID_PW!%%~a" )

call :Gen_BIN
call :Gen_CAP
call :Gen_EXE

echo.
echo =====================================================
echo.

endLocal
exit /b 0


rem ****************************************************************************
rem Find the BIOS EXE file, generate script according to platform
:Gen_EXE
setLocal enableDelayedExpansion
for /f "usebackq delims=" %%i in (`dir /b WIN_*.exe 2^>nul`) do (
    set File_Name=%%i
    for %%a in ( %ID_PW% ) do (
        set ID_PW_Now=%%a
        if "!File_Name:~7,3!" EQU "!ID_PW_Now:~0,3!" (
            for /f "usebackq tokens=2 delims=-" %%x in (`echo !ID_PW_Now!`) do ( 
                set PW_Now=%%x
                if "!File_Name:~4,1!" NEQ "E" (
                    set Out_Name=!File_Name:~4,3!_EXE.bat
                ) else (
                    set Out_Name=!File_Name:~11,3!_EXE.bat
                )
                echo !File_Name! /eu:!PW_Now! > !Out_Name!
                echo !Out_Name!
            )
        )
    )
)
endLocal
exit /b 0


rem ****************************************************************************
rem Find the BIOS CAP file, generate script according to platform
:Gen_CAP
setLocal enableDelayedExpansion
for /f "usebackq delims=" %%i in (`dir /b *.cap 2^>nul`) do (
    set File_Name=%%i
    set Platform_Is=
    for %%a in ( %LNL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=LNL" )
    )
    for %%a in ( %MTL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=MTL" )
    )
    for %%a in ( %RPL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=RPL" )
    )
    for %%a in ( %ADL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=ADL" )
    )
    for %%a in ( %TGL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=TGL" )
    )
    for %%a in ( %CML_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=CML" )
    )
    if "!Platform_Is!" NEQ "" (
        if "!File_Name:~0,1!" NEQ "E" (
            set Out_Name=!File_Name:~0,3!_CAP.nsh
        ) else if "!File_Name:~-7,3!" NEQ "dbg" (
            set Out_Name=!File_Name:~-7,3!_CAP.nsh
        ) else (
            set Out_Name=!File_Name:~-11,3!_CAP.nsh
        )
        for /f "usebackq delims=" %%i in (`echo !Para1_Support! ^| find "!Platform_Is!"`) do (
            echo AfuEfix64_!Platform_Is!.efi !File_Name! !AFU_Para1! > !Out_Name!
            echo !Out_Name!
        )
        for /f "usebackq delims=" %%i in (`echo !Para2_Support! ^| find "!Platform_Is!"`) do (
            echo AfuEfix64_!Platform_Is!.efi !File_Name! !AFU_Para2! > !Out_Name!
            echo !Out_Name!
        )
    )
)
endLocal
exit /b 0


rem ****************************************************************************
rem Find the BIOS BIN file, check if DnX FW exist, generate DnX bat script
rem Otherwise generate nsh script for Fpt flash
:Gen_BIN
setLocal enableDelayedExpansion
for /f "usebackq delims=" %%i in (`dir /b DNX*.bin 2^>nul`) do (
    set DnxFwExist=1
    set DnxFwName=%%i
)
for /f "usebackq delims=" %%i in (`dir /b *.bin 2^>nul`) do (
    set File_Name=%%i
    set Platform_Is=
    for %%a in ( %LNL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=LNL" )
    )
    for %%a in ( %MTL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=MTL" )
    )
    for %%a in ( %RPL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=RPL" )
    )
    for %%a in ( %ADL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=ADL" )
    )
    for %%a in ( %TGL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=TGL" )
    )
    for %%a in ( %CML_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "Platform_Is=CML" )
    )
    if "!Platform_Is!" NEQ "" (
        if "!File_Name:~0,1!" NEQ "E" (
            set Out_Name=!File_Name:~0,3!
        ) else if "!File_Name:~-7,3!" NEQ "dbg" (
            set Out_Name=!File_Name:~-7,3!
        ) else (
            set Out_Name=!File_Name:~-11,3!
        )
        if "!DnxFwExist!" EQU "1" (
            call :Out_DnX !Platform_Is! !DnxFwName! !File_Name! !Out_Name!_DnX.bat
        ) else (
            call :Out_Fpt Fpt_!Platform_Is!.efi !File_Name! !Out_Name!_BIN.nsh
        )
    )
)
endLocal
exit /b 0


rem ****************************************************************************
rem Generate a script for FPT file flash
rem %~1: FPT name
rem %~2: BIN name
rem %~3: Output name
:Out_Fpt
setLocal enableDelayedExpansion
echo echo -off> %~3
echo cls>> %~3
echo.>> %~3
echo set -v BiosFile %~2>> %~3
echo.>> %~3
echo for %%n in 0 1 2 3 4 5 6 7 >> %~3
echo     if exist fs%%n:\EFI\Microsoft\Boot\bootmgr.efi then>> %~3
echo         set -v DiskNo %%n>> %~3
echo         goto FoundDisk>> %~3
echo     endif>> %~3
echo endfor>> %~3
echo goto NotFoundDisk>> %~3
echo.>> %~3
echo :FoundDisk>> %~3
echo if exist fs%%DiskNo%%:\BIOS then>> %~3
echo     rm -q fs%%DiskNo%%:\BIOS ^> nul>> %~3
echo endif>> %~3
echo mkdir fs%%DiskNo%%:\BIOS ^> nul>> %~3
echo cp -q %%cwd%%\%~1 fs%%DiskNo%%:\BIOS\ ^> nul>> %~3
echo cp -q %%cwd%%\%%BiosFile%% fs%%DiskNo%%:\BIOS\ ^> nul>> %~3
echo echo =====================================================>> %~3
echo echo = Now flashing: %%BiosFile%%>> %~3
echo echo =====================================================>> %~3
echo echo " ">> %~3
echo fs%%DiskNo%%:\BIOS\%~1 -f fs%%DiskNo%%:\BIOS\%%BiosFile%%>> %~3
echo rm -q fs%%DiskNo%%:\BIOS\%%BiosFile%% ^> nul>> %~3
echo echo =====================================================>> %~3
echo echo = Reboot now, please wait...>> %~3
echo echo =====================================================>> %~3
echo echo " ">> %~3
echo fs%%DiskNo%%:\BIOS\%~1 -greset ^> nul>> %~3
echo goto End>> %~3
echo.>> %~3
echo :NotFoundDisk>> %~3
echo echo =====================================================>> %~3
echo echo = Now flashing: %%BiosFile%%>> %~3
echo echo = Please don't unlpug usb disk...>> %~3
echo echo =====================================================>> %~3
echo echo " ">> %~3
echo %~1 -f %%BiosFile%%>> %~3
echo echo =====================================================>> %~3
echo echo = Reboot now, please wait...>> %~3
echo echo =====================================================>> %~3
echo echo " ">> %~3
echo %~1 -greset ^> nul>> %~3
echo goto End>> %~3
echo.>> %~3
echo :End>> %~3
echo echo -on>> %~3
echo %~3
endLocal
exit /b 0


rem ****************************************************************************
rem Generate a script for DnX flash
rem %~1: Platform
rem %~2: DnX FW name
rem %~3: BIN name
rem %~4: Output name
rem Necessary files: E00JZR03C.BIN, DNXP_0x1.bin, mfit.exe, meu.exe
rem mfit --layout "Intel(R) LunarLake M Chipset - DnX Recovery Image" --setvalues ManifestSigningUtilPlugin:SigningContainer:MeuToolPath="./meu.exe";DnxPlugin:Dnx:InputFile="./E00JZR03C.BIN" --build E00JZR03C_DnX.BIN
:Out_DnX
setLocal enableDelayedExpansion
if "%~1" EQU "LNL" (
    set Mfit_Para=!DnX_LNL!
) else if "%~1" EQU "MTL" (
    set Mfit_Para=!DnX_MTL!
) else if "%~1" EQU "RPL" (
    set Mfit_Para=!DnX_RPL!
) else (
    exit /b 0
)
set Bin_For_DnX=%~3
for /f "delims=." %%i in ('echo !Bin_For_DnX!') do ( set Bin_For_DnX=%%i_DnX.bin )
echo @echo off > %~4
echo mfit --layout "!Mfit_Para!" --setvalues ManifestSigningUtilPlugin:SigningContainer:MeuToolPath="./meu.exe";DnxPlugin:Dnx:InputFile="./%~3" --build !Bin_For_DnX! >> %~4
echo del *.txt >> %~4
echo del *.map >> %~4
echo del *.log >> %~4
echo del *.xml >> %~4
echo dnxFwDownloader --command downloadfwos --flags 0 --fw_dnx %~2 --fw_image !Bin_For_DnX! >> %~4
echo del !Bin_For_DnX! >> %~4
echo echo. >> %~4
echo echo ===================================================== >> %~4
echo echo Flash done! Press any key to reboot target system, or >> %~4
echo echo close this windows. >> %~4
echo echo. >> %~4
echo pause >> %~4
echo dnxFwDownloader --command startover --flags 9 >> %~4
echo %~4
echo dnxFwDownloader --command startover --flags 9 > ExitDnXMode.bat
echo dnxFwDownloader --command readbootmedia --fw_dnx %~2 --path dump.bin --device spi --idx 0 --part 0 --start 0 --blocks 8192 > RomDump.bat
echo pause >> RomDump.bat
endLocal
exit /b 0
