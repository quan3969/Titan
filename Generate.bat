@echo off
setLocal enableDelayedExpansion
rem Find BIOS update files and generate script for easy update.
rem By Q3aN 240826
rem Todo:
rem  1. add ARL
rem  2. use py for dnx
set ver=v04

echo.
echo =====================================================
echo ^>
echo ^> Welcome to Generate %ver%

set "LNL_ID=JZR VAJ ALY RHF AMA"
set "MTL_ID=RHA RHB RHD"
set "RPL_ID=RGU RGS RGT RHC"
set "ADL_ID=RGG RGE RGF RGL RGM RGL"
set "TGL_ID=RFX RFW"
set "CML_ID=RFG"

set "DnX_LNL=Intel(R) LunarLake M Chipset - DnX Recovery Image"
set "DnX_MTL=Intel(R) MeteorLake P Chipset - DnX Recovery Image"
set "DnX_RPL=Intel(R) AlderLake P Chipset - DnX Recovery Image"

set "AFU_Para1=/p /b /n /capsule /q"
set "Para1_Support=MTL LNL"
set "AFU_Para2=/p /b /n /r /e /capsule /q"
set "Para2_Support=RPL ADL TGL CML"
set "AFU_Para3=/p /b /n /meul /capsule /q"
set "Para3_Support="

set ID_PW=
for %%a in (
    "ALY-Mars5 "
    "VAJ-VENUS5 "
    "RHF-VENUS5 "
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

echo ^>
echo =====================================================
echo.

endLocal
exit /b 0


rem ****************************************************************************
rem Find the BIOS EXE file, generate script according to platform
:Gen_EXE
setLocal enableDelayedExpansion
for /f "usebackq delims=" %%i in (`dir /b WIN_*.exe 2^>nul`) do (
    set file_name=%%i
    for /f "delims=" %%j in ('where !file_name!') do ( set file_path=%%j )
    set file_path=!file_path:\=\\!
    for /f "usebackq" %%k in (`wmic datafile where name^="!file_path!" get version ^| find ".0"`) do ( set file_ver=%%k )
    if !file_ver! GTR 4.43.0.0 (
        if "!file_name:~4,1!" NEQ "E" (
            set out_name=!file_name:~4,3!_EXE.bat
        ) else (
            set out_name=!file_name:~11,-4!_EXE.bat
        )
        echo !file_name! /eu /afu /op:w > !out_name!
        echo ^>
        echo ^> !out_name!
    ) else (
        for %%a in ( %ID_PW% ) do (
            set file_id_pw=%%a
            if "!file_name:~7,3!" EQU "!file_id_pw:~0,3!" (
                for /f "usebackq tokens=2 delims=-" %%x in (`echo !file_id_pw!`) do ( 
                    set file_pw=%%x
                    if "!file_name:~4,1!" NEQ "E" (
                        set out_name=!file_name:~4,3!_EXE.bat
                    ) else (
                        set out_name=!file_name:~11,-4!_EXE.bat
                    )
                    echo !file_name! /eu:!file_pw! /op:w > !out_name!
                    echo ^>
                    echo ^> !out_name!
                )
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
    set File_Platform=
    for %%a in ( %LNL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=LNL" )
    )
    for %%a in ( %MTL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=MTL" )
    )
    for %%a in ( %RPL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=RPL" )
    )
    for %%a in ( %ADL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=ADL" )
    )
    for %%a in ( %TGL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=TGL" )
    )
    for %%a in ( %CML_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=CML" )
    )
    if "!File_Platform!" NEQ "" (
        if "!File_Name:~0,1!" NEQ "E" (
            set out_name=!File_Name:~0,3!_CAP.nsh
        ) else if "!File_Name:~6,1!" NEQ "_" (
            set out_name=!File_Name:~6,-4!_CAP.nsh
        ) else (
            set out_name=!file_name:~7,-4!_CAP.nsh
        )
        for /f "usebackq delims=" %%i in (`echo !Para1_Support! ^| find "!File_Platform!"`) do (
            set "afu_cmd=AfuEfix64_!File_Platform!.efi !File_Name! !AFU_Para1!"
        )
        for /f "usebackq delims=" %%i in (`echo !Para2_Support! ^| find "!File_Platform!"`) do (
            set "afu_cmd=AfuEfix64_!File_Platform!.efi !File_Name! !AFU_Para2!"
        )
        for /f "usebackq delims=" %%i in (`echo !Para3_Support! ^| find "!File_Platform!"`) do (
            set "afu_cmd=AfuEfix64_!File_Platform!.efi !File_Name! !AFU_Para3!"
        )
        echo !afu_cmd! > !out_name!
        echo ^>
        echo ^> !out_name!
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
    set File_Platform=
    for %%a in ( %LNL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=LNL" )
    )
    for %%a in ( %MTL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=MTL" )
    )
    for %%a in ( %RPL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=RPL" )
    )
    for %%a in ( %ADL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=ADL" )
    )
    for %%a in ( %TGL_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=TGL" )
    )
    for %%a in ( %CML_ID% ) do (
        if "!File_Name:~3,3!" EQU "%%a" ( set "File_Platform=CML" )
    )
    if "!File_Platform!" NEQ "" (
        if "!File_Name:~0,1!" NEQ "E" (
            set Out_Name=!File_Name:~0,3!
        ) else if "!File_Name:~6,1!" NEQ "_" (
            set out_name=!File_Name:~6,-4!
        ) else (
            set Out_Name=!file_name:~7,-4!
        )
        if "!DnxFwExist!" EQU "1" (
            call :Out_DnX !File_Platform! !DnxFwName! !File_Name! !Out_Name!_DnX.bat
        ) else (
            call :Out_Fpt Fpt_!File_Platform!.efi !File_Name! !Out_Name!_BIN.nsh
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
echo echo -off> %~3
echo echo " ">> %~3
echo echo =====================================================>> %~3
echo echo ^^^>>> %~3
echo.>> %~3
echo set -v BiosFile %~2>> %~3
echo set -v Fpt %~1>> %~3
echo set -v sFpt SamsungFpt.efi>> %~3
echo.>> %~3
echo if not exist %%BiosFile%% then>> %~3
echo     goto NotFound>> %~3
echo endif>> %~3
echo if exist %%sFpt%% and ZZ%%1 == ZZ then>> %~3
echo     %%sFpt%% -f %%BiosFile%% -unlock>> %~3
echo     goto End>> %~3
echo endif>> %~3
echo if not exist %%Fpt%% then>> %~3
echo     goto NotFound>> %~3
echo endif>> %~3
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
echo cp -q %%cwd%%\%%Fpt%% fs%%DiskNo%%:\BIOS\ ^> nul>> %~3
echo cp -q %%cwd%%\%%BiosFile%% fs%%DiskNo%%:\BIOS\ ^> nul>> %~3
echo echo ^^^> Now flashing: %%BiosFile%%>> %~3
echo echo " ">> %~3
echo fs%%DiskNo%%:\BIOS\%%Fpt%% -f fs%%DiskNo%%:\BIOS\%%BiosFile%%>> %~3
echo rm -q fs%%DiskNo%%:\BIOS\%%BiosFile%% ^> nul>> %~3
echo goto Greset>> %~3
echo.>> %~3
echo :NotFoundDisk>> %~3
echo echo ^^^> Now flashing: %%BiosFile%%>> %~3
echo echo ^^^> Please don't unlpug usb disk...>> %~3
echo echo ^^^>>> %~3
echo %%Fpt%% -f %%BiosFile%%>> %~3
echo.>> %~3
echo :Greset>> %~3
echo echo ^^^> Reboot now, please wait...>> %~3
echo echo ^^^>>> %~3
echo if exist fs%%DiskNo%%:\BIOS\%%Fpt%% then>> %~3
echo     fs%%DiskNo%%:\BIOS\%%Fpt%% -greset ^> nul>> %~3
echo else>> %~3
echo     %%Fpt%% -greset ^> nul>> %~3
echo endif>> %~3
echo goto End>> %~3
echo.>> %~3
echo :NotFound>> %~3
echo echo ^^^> Fail: Fpt or BIOS file not found>> %~3
echo echo ^^^>>> %~3
echo.>> %~3
echo :End>> %~3
echo echo =====================================================>> %~3
echo echo " ">> %~3
echo echo -on>> %~3
echo ^>
echo ^> %~3
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
echo ^>
echo ^> %~4
echo dnxFwDownloader --command startover --flags 9 > ExitDnXMode.bat
echo dnxFwDownloader --command readbootmedia --fw_dnx %~2 --path dump.bin --device spi --idx 0 --part 0 --start 0 --blocks 8192 > RomDump.bat
echo pause >> RomDump.bat
endLocal
exit /b 0
