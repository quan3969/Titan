@echo off
setlocal enabledelayedexpansion

rem Fine BIOS update files and generate script for easy update.
rem Presented by Q3aN.
rem 2023.07.06

rem BIN
for /f "usebackq delims=" %%i in (`dir /b ^| findstr /i /c:".bin"`) do (
    set file_name=%%i
    rem "E" version
    if "!file_name:~13!" EQU "" if "!file_name:~12,1!" NEQ "" if "!file_name:~0,1!" EQU "E" (
        set outname=!file_name:~6,3!_BIN.nsh
        rem MTL
        for /f "usebackq delims=" %%a in (`echo %%i ^| findstr /i "RHA"`) do (
            echo Fpt_MTL.efi /f !file_name! > !outname!
        )
        rem RPL
        for /f "usebackq delims=" %%a in (`echo %%i ^| findstr /i "RGU RGS RGT"`) do (
            echo Fpt_RPL.efi /f !file_name! > !outname!
        )
        rem ADL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RGG RGE RGF RGL RGM RGL"`) do (
            echo Fpt_ADL.efi /f !file_name! > !outname!
        )
        rem TGL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFX RFW"`) do (
            echo Fpt_TGL.efi /f !file_name! > !outname!
        )
        rem CML
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFG"`) do (
            echo Fpt_CML.efi /f !file_name! > !outname!
        )
    )
    rem not a "E" version
    if "!file_name:~13!" EQU "" if "!file_name:~12,1!" NEQ "" if "!file_name:~0,1!" NEQ "E" (
        set outname=!file_name:~0,3!_BIN.nsh
        rem RPL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RHA"`) do (
            echo Fpt_MTL.efi /f !file_name! > !outname!
        )
        rem RPL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RGU RGS RGT"`) do (
            echo Fpt_RPL.efi /f !file_name! > !outname!
        )
        rem ADL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RGG RGE RGF RGL RGM RGL"`) do (
            echo Fpt_ADL.efi /f !file_name! > !outname!
        )
        rem TGL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFX RFW"`) do (
            echo Fpt_TGL.efi /f !file_name! > !outname!
        )
        rem CML
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFG"`) do (
            echo Fpt_CML.efi /f !file_name! > !outname!
        )
    )
)

rem CAP
for /f "usebackq delims=" %%i in (`dir /b ^| findstr /i /c:".cap"`) do (
    set file_name=%%i
    rem "E" version
    if "!file_name:~13!" EQU "" if "!file_name:~12,1!" NEQ "" if "!file_name:~0,1!" EQU "E" (
        set outname=!file_name:~6,3!_CAP.nsh
        rem MTL
        for /f "usebackq delims=" %%a in (`echo %%i ^| findstr /i "RHA"`) do (
            echo AfuEfix64_MTL.efi !file_name! /p /b /n /r /e /capsule /q > !outname!
        )
        rem RPL
        for /f "usebackq delims=" %%a in (`echo %%i ^| findstr /i "RGU RGS RGT"`) do (
            echo AfuEfix64_RPL.efi !file_name! /p /b /n /r /e /capsule /q > !outname!
        )
        rem ADL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RGG RGE RGF RGL RGM RGL"`) do (
            echo AfuEfix64_ADL.efi !file_name! /p /b /n /r /e /capsule /q > !outname!
        )
        rem TGL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFX RFW"`) do (
            echo AfuEfix64_TGL.efi !file_name! /p /b /n /r /e /capsule /q > !outname!
        )
        rem CML
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFG"`) do (
            echo AfuEfix64_RPL.efi !file_name! /p /b /n /r /e /capsule /q > !outname!
        )
    )
    rem not a "E" version
    if "!file_name:~13!" EQU "" if "!file_name:~12,1!" NEQ "" if "!file_name:~0,1!" NEQ "E" (
        set outname=!file_name:~0,3!_CAP.nsh
        rem RPL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RGU RGS RGT"`) do (
            echo AfuEfix64_RPL.efi !file_name! /p /b /n /r /e /capsule /q > !outname!
        )
        rem ADL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RGG RGE RGF RGL RGM RGL"`) do (
            echo AfuEfix64_ADL.efi !file_name! /p /b /n /r /e /capsule /q > !outname!
        )
        rem TGL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFX RFW"`) do (
            echo AfuEfix64_TGL.efi !file_name! /p /b /n /r /e /capsule /q > !outname!
        )
        rem CML
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFG"`) do (
            echo AfuEfix64_RPL.efi !file_name! /p /b /n /r /e /capsule /q > !outname!
        )
    )
)

rem EXE
for /f "usebackq delims=" %%i in (`dir /b ^| findstr /i /c:".exe"`) do (
    set file_name=%%i
    rem "E" version
    if "!file_name:~18!" EQU "" if "!file_name:~17,1!" NEQ "" if "!file_name:~4,1!" EQU "E" (
        set outname=!file_name:~11,3!_EXE.bat
        rem MTL
        for /f "usebackq delims=" %%a in (`echo %%i ^| findstr /i "RHA"`) do (
            echo !file_name! /eu:Venus4 > !outname!
        )
        rem RPL
        for /f "usebackq delims=" %%a in (`echo %%i ^| findstr /i "RGU RGS"`) do (
            echo !file_name! /eu:Venus3 > !outname!
        )
        rem ADL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RGF RGM"`) do (
            echo !file_name! /eu:Venus2 > !outname!
        )
        rem TGL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFX RFW"`) do (
            echo !file_name! /eu:Venus > !outname!
        )
        rem CML
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFG"`) do (
            echo !file_name! /eu:Apollon > !outname!
        )
    )
    rem not a "E" version
    if "!file_name:~18!" EQU "" if "!file_name:~17,1!" NEQ "" if "!file_name:~4,1!" NEQ "E" (
        set outname=!file_name:~4,3!_EXE.bat
        rem MTL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RHA"`) do (
            echo !file_name! /eu:Venus4 > !outname!
        )
        rem RPL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RGU RGS"`) do (
            echo !file_name! /eu:Venus3 > !outname!
        )
        rem TGL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RGF RGM"`) do (
            echo !file_name! /eu:Venus2 > !outname!
        )
        rem TGL
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFX RFW"`) do (
            echo !file_name! /eu:Venus > !outname!
        )
        rem CML
        for /f "usebackq" %%a in (`echo %%i ^| findstr /i "RFG"`) do (
            echo !file_name! /eu:Apollon > !outname!
        )
    )
)

:End
endlocal
