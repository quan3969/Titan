@echo off
setLocal enableDelayedExpansion
rem For Windows Images install.
rem By Q3aN 241121
set ver=v05

rem Future feature:
rem 1. FFU backup and restore

set win_ltr=W
set sys_ltr=S
set rcy_ltr=R
set tmp_file="%~dp0tmp.txt"
set end_pause=0

echo.
echo =====================================================
echo ^>
echo ^> Welcome to WinInst %ver%

call :Find_Images
if %errorlevel% EQU 0 ( call :Get_Target_Image )
if %errorlevel% EQU 0 ( call :Get_Target_Disk )
if %errorlevel% EQU 0 ( call :Format_Disk %sel_disk% )
if %errorlevel% EQU 0 ( call :Appy_Image %sel_img% )
if %errorlevel% EQU 0 ( call :Answer_File %win_ltr% )
call :Do_Ending %errorlevel%

echo ^>
echo =====================================================
echo.

if "%end_pause%" EQU "1" ( pause )
endLocal
exit /b


rem ****************************************************************************
rem Do the ending and clean up job
rem %~1: Ending reason:
rem        0 - Success
rem        1 - Input invalid
rem        2 - No avaliable image
rem        3 - No avaliable disk
rem        4 - Disk where the script resides
rem        5 - Removable disk
:Do_Ending
if "%~1" EQU "0" ( echo ^>
    echo ^> Success
) else if "%~1" EQU "1" ( echo ^>
    echo ^> Fail: Input invalid
) else if "%~1" EQU "2" ( echo ^>
    echo ^> Fail: No avaliable image
) else if "%~1" EQU "3" ( echo ^>
    echo ^> Fail: No avaliable disk
) else if "%~1" EQU "4" ( echo ^>
    echo ^> Fail: This is the disk where this script resides
) else if "%~1" EQU "5" ( echo ^>
    echo ^> Fail: This is a removeable disk
) else ( echo ^>
    echo ^> Unknown error
)
if exist %tmp_file% del %tmp_file%
exit /b


rem ****************************************************************************
rem Add answer file to target disk
rem %~1: Target Volume
:Answer_File
if not exist %~1:\Windows exit /b
echo ^>
echo ^> Answer file avaliavle:
echo ^>  1. Audit Mode
echo ^>  2. Local User
echo ^>  3. Admin User
echo ^>
set /p "sel_answer=> Select to add: "
if not exist %~1:\Windows\Panther mkdir %~1:\Windows\Panther
if /i "%sel_answer%" EQU "1" call :Gen_Unattend_Audit "%~1:\Windows\Panther\unattend.xml"
if /i "%sel_answer%" EQU "2" call :Gen_Unattend_User "%~1:\Windows\Panther\unattend.xml"
if /i "%sel_answer%" EQU "3" call :Gen_Unattend_Admin "%~1:\Windows\Panther\unattend.xml"
exit /b


rem ****************************************************************************
rem Apply selected image to selected disk
rem %~1: Target Image path
:Appy_Image
set is_swm_img=1
set swm_name=%~1
set swm_name=!swm_name:~0,-4!
for /f "usebackq delims=" %%i in (`echo %~1 ^| find /v ".swm"`) do (
    set is_swm_img=0
)
if "%is_swm_img%" EQU "1" (
    dism /Apply-Image /ImageFile:"%swm_name%.swm" /SWMFile:"%swm_name%*.swm" /Index:1 /ApplyDir:%win_ltr%:\
) else (
    dism /Apply-Image /ImageFile:"%~1" /Index:1 /ApplyDir:%win_ltr%:\
)
bcdboot %win_ltr%:\Windows
echo ^>
echo ^> Apply completed!
exit /b


rem ****************************************************************************
rem Ask User to select target disk
rem SET sel_disk: Target Disk
rem Set errorlevel: 
rem        0 - Success
rem        1 - Input invalid
rem        3 - No avaliable disk
rem        4 - Disk where the script resides
rem        5 - Removable disk
:Get_Target_Disk
echo list disk > %tmp_file%
diskpart /s %tmp_file%
set disk_cnt=0
for /f "usebackq delims=" %%i in (`diskpart /s %tmp_file% ^| find /i "Online"`) do (
    set /a disk_cnt=disk_cnt+1
)
if %disk_cnt% EQU 0 exit /b 3
echo ^>
set /p "sel_disk=> Select Disk to install: "
rem check user input
if /i "%sel_disk%" EQU "" exit /b 1
for /f "delims=0123456789" %%i in ("%sel_disk%") do (
    if "%%i" NEQ "" exit /b 1
)
if %sel_disk% GEQ %disk_cnt% exit /b 1
echo sel disk %sel_disk% > %tmp_file%
echo detail disk >> %tmp_file%
for /f "usebackq tokens=3 delims= " %%i in (`diskpart /s %tmp_file% ^| find "Volume"`) do (
    if "%%i:" EQU "%~d0" exit /b 4
)
for /f "usebackq" %%i in (`diskpart /s %tmp_file% ^| find "Removable"`) do (
    exit /b 5
)
exit /b


rem ****************************************************************************
rem Ask User to select target image
rem SET sel_img: save target image path
rem Set errorlevel: 
rem        0 - Success
rem        1 - Input invalid
:Get_Target_Image
echo ^>
set /p "sel_img=> Select to continue: "
rem check user input
if /i "%sel_img%" EQU "" exit /b 1
if /i "%sel_img%" EQU "0" exit /b 1
for /f "delims=0123456789" %%i in ("%sel_img%") do (
    if "%%i" NEQ "" exit /b 1
)
if %sel_img% GTR %img_cnt% exit /b 1
set img_cnt=0
for %%i in (%esd_wim_img%%swm_img%) do (
    set /a img_cnt=img_cnt+1
    if "%sel_img%" EQU "!img_cnt!" set sel_img=%%i
)
exit /b


rem ****************************************************************************
rem Find all images in "sources" and current folder, include sub-folder
rem SET esd_wim_img: Found *.esd, *.wim images
rem SET swm_img: Found *.swm images
rem Set errorlevel: 
rem        0 - Success
rem        2 - No avaliable image
:Find_Images
rem Find *.esd and *.wim
for %%i in (C D E F G H I J K L M N O P Q R X T U Y W X Y Z) do (
    for /f "usebackq delims=" %%x in (`dir %%i:\sources\*.esd %%i:\sources\*.wim /s/b 2^>nul ^| find /v "boot.wim"`) do (
        set esd_wim_img=!esd_wim_img! "%%x"
    )
)
for /f "usebackq delims=" %%i in (`dir /s/b *.esd *.wim 2^>nul ^| find /v "%~d0\sources\"`) do (
    set esd_wim_img=!esd_wim_img! "%%i"
)
rem Find *.swm
for %%i in (C D E F G H I J K L M N O P Q R X T U Y W X Y Z) do (
    for /f "usebackq delims=" %%x in (`dir %%i:\sources\*.swm /s/b 2^>nul`) do (
        set "swm_img_all=!swm_img_all! "%%x""
    )
)
for /f "usebackq delims=" %%i in (`dir /s/b *.swm 2^>nul ^| find /v "%~d0\sources\"`) do (
    set "swm_img_all=!swm_img_all! "%%i""
)
rem 1. format swm images path
rem 22631p3085.swm to 22631p308.swm
rem 22631p30852.swm to 22631p3085.swm
for %%i in (%swm_img_all%) do (
    set swm_cut=%%i
    set swm_cut=!swm_cut:~1,-6%!
    if exist "!swm_cut!.swm" set swm_img_cut=!swm_img_cut! "!swm_cut!.swm"
)
rem 2. remove duplicated delimited string
set swm_img= 
for %%a in (%swm_img_cut%) do (
    set "swm_img=!swm_img: %%a = !%%a "
)
rem Print all images
echo ^>
echo ^> Found below image:
set img_cnt=0
for %%i in (%esd_wim_img%%swm_img%) do (
    set /a img_cnt=img_cnt+1
    echo ^>  !img_cnt!. %%i
)
if %img_cnt% EQU 0 exit /b 2
exit /b


rem ****************************************************************************
rem Generate scirpt file dp_script.txt for diskpart in current folder
rem Use dp_script.txt to format a selected disk
rem %~1: Target Disk number
:Format_Disk
set is_win_disk=0
set inst_target=
echo sel disk %sel_disk% > %tmp_file%
echo detail disk >> %tmp_file%
for /f "usebackq tokens=2,3 delims= " %%i in (`diskpart /s %tmp_file% ^| find "NTFS" ^| find /v "Hidden"`) do (
    if exist "%%j:\Windows\system32\winver.exe" (
        set is_win_disk=1
        set win_vol=%%i
        set win_ltr=%%j
    )
)
if /i "%is_win_disk%" EQU "1" (
    echo ^>
    echo ^> Windows OS found in this disk, install image with:
    echo ^>  1. Full disk
    echo ^>  2. Windows partition only
    echo ^>
    set /p "inst_target=> Select to continue: "
)
if /i "%inst_target%" EQU "2" (
    echo sel vol %win_vol% > %tmp_file%
    echo format quick fs=ntfs >> %tmp_file%
    diskpart /s %tmp_file%
    exit /b
)
if "%is_win_disk%" EQU "1" if "%inst_target%" NEQ "1" (
    exit /b 1
)
echo select disk %~1 > %tmp_file%
echo clean >> %tmp_file%
echo convert gpt >> %tmp_file%
echo create partition efi size=260 >> %tmp_file%
echo format quick fs=fat32 label="System" >> %tmp_file%
echo assign letter="%sys_ltr%" >> %tmp_file%
echo create partition msr size=16 >> %tmp_file%
echo create partition primary >> %tmp_file%
echo shrink minimum=500 >> %tmp_file%
echo format quick fs=ntfs label="Windows" >> %tmp_file%
echo assign letter="%win_ltr%" >> %tmp_file%
echo create partition primary >> %tmp_file%
echo format quick fs=ntfs label="Recovery" >> %tmp_file%
echo assign letter="%rcy_ltr%" >> %tmp_file%
echo set id="de94bba4-06d1-4d40-a16a-bfd50179d6ac" >> %tmp_file%
echo gpt attributes=0x8000000000000001 >> %tmp_file%
echo list volume >> %tmp_file%
echo exit >> %tmp_file%
diskpart /s %tmp_file%
exit /b


rem ****************************************************************************
rem Generate Unattend file to enable Administrator account
rem %~1 Output File
:Gen_Unattend_Admin
echo ^<?xml version="1.0" encoding="utf-8"?^> > %~1
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^> >> %~1
echo     ^<settings pass="oobeSystem"^> >> %~1
echo         ^<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> %~1
echo             ^<AutoLogon^> >> %~1
echo                 ^<Enabled^>true^</Enabled^> >> %~1
echo                 ^<LogonCount^>5^</LogonCount^> >> %~1
echo                 ^<Username^>Administrator^</Username^> >> %~1
echo                 ^<Domain^>^</Domain^> >> %~1
echo             ^</AutoLogon^> >> %~1
echo             ^<OOBE^> >> %~1
echo                 ^<SkipMachineOOBE^>true^</SkipMachineOOBE^> >> %~1
echo             ^</OOBE^> >> %~1
echo         ^</component^> >> %~1
echo     ^</settings^> >> %~1
echo ^</unattend^> >> %~1
echo ^>
echo ^> Answer file added: %~1
exit /b


rem ****************************************************************************
rem Generate Unattend file to enable Local account
rem %~1 Output File
:Gen_Unattend_User
echo ^<?xml version="1.0" encoding="utf-8"?^> > "%~1"
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^> >> "%~1"
echo     ^<settings pass="oobeSystem"^> >> "%~1"
echo         ^<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> "%~1"
echo             ^<OOBE^> >> "%~1"
echo                 ^<HideEULAPage^>true^</HideEULAPage^> >> "%~1"
echo                 ^<HideOEMRegistrationScreen^>true^</HideOEMRegistrationScreen^> >> "%~1"
echo                 ^<HideOnlineAccountScreens^>true^</HideOnlineAccountScreens^> >> "%~1"
echo                 ^<HideWirelessSetupInOOBE^>true^</HideWirelessSetupInOOBE^> >> "%~1"
echo                 ^<ProtectYourPC^>3^</ProtectYourPC^> >> "%~1"
echo             ^</OOBE^> >> "%~1"
echo         ^</component^> >> "%~1"
echo         ^<component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> "%~1"
echo             ^<SystemLocale^>en-US^</SystemLocale^> >> "%~1"
echo         ^</component^> >> "%~1"
echo     ^</settings^> >> "%~1"
echo ^</unattend^> >> "%~1"
echo ^>
echo ^> Answer file added: %~1
exit /b


rem ****************************************************************************
rem Generate Unattend file to make system boot to Audit mode
rem %~1 Output File
:Gen_Unattend_Audit
echo ^<?xml version="1.0" encoding="utf-8"?^> > "%~1"
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^> >> "%~1"
echo     ^<settings pass="oobeSystem"^> >> "%~1"
echo         ^<component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> "%~1"
echo             ^<Reseal^> >> "%~1"
echo                 ^<Mode^>Audit^</Mode^> >> "%~1"
echo             ^</Reseal^> >> "%~1"
echo         ^</component^> >> "%~1"
echo     ^</settings^> >> "%~1"
echo ^</unattend^> >> "%~1"
echo ^>
echo ^> Answer file added: %~1
exit /b
