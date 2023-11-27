@echo off
setlocal enabledelayedexpansion

rem Presented by Q3aN.
rem 2023.11.27

rem find avaliavle image and wait for user input
set found_image=0
echo.
echo =====================================================
echo Found below image: 
for /f "usebackq delims=" %%i in (`%~d0 ^& cd %~dp0 ^& dir /s/b *.esd *.wim ^| find /v "boot.wim .:\\sources\\install."`) do (
    set /a found_image=found_image+1
    echo   !found_image!. %%i
)
for %%i in (C D E F G H I J K L M N O P Q R X T U Y W X Y Z) do (
    if exist "%%i:\sources\install.esd" (
        set /a found_image=found_image+1
        echo   !found_image!. %%i:\sources\install.esd
    )
    if exist "%%i:\sources\install.wim" (
        set /a found_image=found_image+1
        echo   !found_image!. %%i:\sources\install.wim
    )
)

echo.
echo =====================================================
set choice=
set /p choice=Choice to continue: 
echo.

rem check user input
if /i "%choice%" EQU "" goto Cancel
if /i "%choice%" EQU "0" goto Cancel
for /f "delims=0123456789" %%i in ("%choice%") do (
    if "%%i" NEQ "" goto Cancel
)
if /i "%choice%" GTR "%found_image%" goto Cancel

rem set user select image path
set found_image=0
for /f "usebackq delims=" %%i in (`%~d0 ^& cd %~dp0 ^& dir /s/b *.esd *.wim ^| find /v "boot.wim .:\\sources\\install."`) do (
    set /a found_image=found_image+1
    if "!choice!" EQU "!found_image!" set image_path=%%i
)
for %%i in (C D E F G H I J K L M N O P Q R X T U Y W X Y Z) do (
    if exist "%%i:\sources\install.esd" (
        set /a found_image=found_image+1
        if "!choice!" EQU "!found_image!" set image_path=%%i:\sources\install.esd
    )
    if exist "%%i:\sources\install.wim" (
        set /a found_image=found_image+1
        if "!choice!" EQU "!found_image!" set image_path=%%i:\sources\install.wim
    )
)

rem list disk and wait for user input
echo list disk > temp.txt
diskpart /s temp.txt
set disk_count=0
for /f "usebackq delims=" %%i in (`diskpart /s temp.txt ^| find /i "GB"`) do (
    set /a disk_count=disk_count+1
)
echo.
echo =====================================================
set choice=
set /p choice=Select Disk to install: 
echo.

rem check user input
if /i "%choice%" EQU "" goto Cancel
for /f "delims=0123456789" %%i in ("%choice%") do (
    if "%%i" NEQ "" goto Cancel
)
if /i "%choice%" GEQ "%disk_count%" goto Cancel

echo select disk %choice% > temp.txt
echo clean >> temp.txt
echo convert gpt >> temp.txt
echo create partition efi size=260 >> temp.txt
echo format quick fs=fat32 label="System" >> temp.txt
echo assign letter="S" >> temp.txt
echo create partition msr size=16 >> temp.txt
echo create partition primary >> temp.txt
echo shrink minimum=500 >> temp.txt
echo format quick fs=ntfs label="Windows" >> temp.txt
echo assign letter="W" >> temp.txt
echo create partition primary >> temp.txt
echo format quick fs=ntfs label="Recovery" >> temp.txt
echo assign letter="R" >> temp.txt
echo set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac" >> temp.txt
echo gpt attributes=0x8000000000000001 >> temp.txt
echo list volume >> temp.txt
echo exit >> temp.txt
diskpart /s temp.txt

dism /Apply-Image /ImageFile:"%image_path%" /Index:1 /ApplyDir:W:\
bcdboot W:\Windows

echo.
echo =====================================================
echo Install completed!
echo  1. Audio Mode
echo  2. Local User
echo  3. Admin User
echo  4. S mode
echo.
echo =====================================================
set choice=
set /p choice=Select next boot: 
echo.
if /i "%choice%"=="1" goto Audit
if /i "%choice%"=="2" goto User
if /i "%choice%"=="3" goto Admin
if /i "%choice%"=="4" goto Smode
goto End

rem Audit mode
:Audit
echo ^<?xml version="1.0" encoding="utf-8"?^> > unattend.xml
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^> >> unattend.xml
echo     ^<settings pass="oobeSystem"^> >> unattend.xml
echo         ^<component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> unattend.xml
echo             ^<Reseal^> >> unattend.xml
echo                 ^<Mode^>Audit^</Mode^> >> unattend.xml
echo             ^</Reseal^> >> unattend.xml
echo         ^</component^> >> unattend.xml
echo     ^</settings^> >> unattend.xml
echo ^</unattend^> >> unattend.xml
goto DoneAnswer

rem Local user
:User
echo ^<?xml version="1.0" encoding="utf-8"?^> > unattend.xml
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^> >> unattend.xml
echo     ^<settings pass="oobeSystem"^> >> unattend.xml
echo         ^<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> unattend.xml
echo             ^<OOBE^> >> unattend.xml
echo                 ^<HideEULAPage^>true^</HideEULAPage^> >> unattend.xml
echo                 ^<HideOEMRegistrationScreen^>true^</HideOEMRegistrationScreen^> >> unattend.xml
echo                 ^<HideOnlineAccountScreens^>true^</HideOnlineAccountScreens^> >> unattend.xml
echo                 ^<HideWirelessSetupInOOBE^>true^</HideWirelessSetupInOOBE^> >> unattend.xml
echo                 ^<ProtectYourPC^>3^</ProtectYourPC^> >> unattend.xml
echo             ^</OOBE^> >> unattend.xml
echo         ^</component^> >> unattend.xml
echo         ^<component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> unattend.xml
echo             ^<SystemLocale^>en-US^</SystemLocale^> >> unattend.xml
echo         ^</component^> >> unattend.xml
echo     ^</settings^> >> unattend.xml
echo ^</unattend^> >> unattend.xml
goto DoneAnswer

rem Administrator
:Admin
echo ^<?xml version="1.0" encoding="utf-8"?^> > unattend.xml
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^> >> unattend.xml
echo     ^<settings pass="oobeSystem"^> >> unattend.xml
echo         ^<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> unattend.xml
echo             ^<AutoLogon^> >> unattend.xml
echo                 ^<Enabled^>true^</Enabled^> >> unattend.xml
echo                 ^<LogonCount^>5^</LogonCount^> >> unattend.xml
echo                 ^<Username^>Administrator^</Username^> >> unattend.xml
echo                 ^<Domain^>^</Domain^> >> unattend.xml
echo             ^</AutoLogon^> >> unattend.xml
echo             ^<OOBE^> >> unattend.xml
echo                 ^<SkipMachineOOBE^>true^</SkipMachineOOBE^> >> unattend.xml
echo             ^</OOBE^> >> unattend.xml
echo         ^</component^> >> unattend.xml
echo     ^</settings^> >> unattend.xml
echo ^</unattend^> >> unattend.xml
goto DoneAnswer

rem S Mode
:Smode
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^> > unattend.xml
echo     ^<settings pass="offlineServicing"^> >> unattend.xml
echo         ^<component name="Microsoft-Windows-CodeIntegrity" processorArchitecture="amd64" publicKeyToken="31bf39567ab364e25" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> unattend.xml
echo             ^<SkuPolicyRequired^>1^</SkuPolicyRequired^> >> unattend.xml
echo         ^</component^> >> unattend.xml
echo     ^</settings^> >> unattend.xml
echo ^</unattend^> >> unattend.xml
goto DoneAnswer

:Cancel
echo.
echo =====================================================
echo Cancel.
echo.
goto End

:DoneAnswer
xcopy unattend.xml W:\Windows\Panther\
if exist unattend.xml del unattend.xml
echo.
echo =====================================================
echo Answer file added.
echo.
goto End

:End
if exist temp.txt del temp.txt