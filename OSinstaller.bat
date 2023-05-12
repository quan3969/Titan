@echo off 
:START_PROCESS
::echo.
::echo =====================================================
::echo Clean OS 自动安装脚本，支持生成应答文件。
::echo Presented with heart by Q3aN.
::echo 2021.06.02
::echo.
::echo =====================================================
::echo 将 esd/wim 镜像文件置于此目录下。更改下列名字：
set Image=install.esd

echo.
echo =====================================================
echo 即 将 安 装： %Image%
echo.
echo    请 注 意 ！！！
echo 此操作将格式化目标盘并重新分区。
echo.
echo =====================================================
set choice=
set /p choice=输入 ok 继续操作，输入 a 仅生成应答文件：
if /i "%choice%"=="ok" goto install
if /i "%choice%"=="a" goto answerOnly

goto notInstall

:install
echo list disk > temp.txt
diskpart /s temp.txt
del temp.txt
echo.
echo =====================================================
set choice=
set /p choice=输入目标盘(0/1.../5)：
if /i "%choice%"=="0" goto installNext
if /i "%choice%"=="1" goto installNext
if /i "%choice%"=="2" goto installNext
if /i "%choice%"=="3" goto installNext
if /i "%choice%"=="4" goto installNext
if /i "%choice%"=="5" goto installNext

goto notInstall

:installNext
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
del temp.txt
dism /Apply-Image /ImageFile:"%~dp0\%Image%" /Index:1 /ApplyDir:W:\
bcdboot W:\Windows
set createAnswer=0
goto answer

:answerOnly
set createAnswer=1
:answer
echo.
echo =====================================================
echo 应答文件：
echo   1. 进入审计模式
echo   2. 创建本地账户
echo   3. 创建管理员账户
echo   4. 设置 S Mode
echo.
echo =====================================================
set choice=
set /p choice=请选择(1/2/...)：
if /i "%choice%"=="1" goto audit
if /i "%choice%"=="2" goto user
if /i "%choice%"=="3" goto admin
if /i "%choice%"=="4" goto smode

goto notAnswer

:: 审计模式
:audit
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
goto answerNext

:: 本地账户
:user
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
goto answerNext

:: 管理员账户
:admin
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
goto answerNext

:: S Mode
:smode
echo ^<unattend xmlns="urn:schemas-microsoft-com:unattend"^> > unattend.xml
echo     ^<settings pass="offlineServicing"^> >> unattend.xml
echo         ^<component name="Microsoft-Windows-CodeIntegrity" processorArchitecture="amd64" publicKeyToken="31bf39567ab364e25" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"^> >> unattend.xml
echo             ^<SkuPolicyRequired^>1^</SkuPolicyRequired^> >> unattend.xml
echo         ^</component^> >> unattend.xml
echo     ^</settings^> >> unattend.xml
echo ^</unattend^> >> unattend.xml
goto answerNext

:answerNext
if /i "%createAnswer%"=="1" goto notDel 
xcopy unattend.xml W:\Windows\Panther\
del unattend.xml
echo.
echo =====================================================
echo 应答文件已添加，下次启动生效。
goto end

:notInstall
echo.
echo =====================================================
echo 操作取消。
echo.
goto end

:notDel
echo.
echo =====================================================
echo 应答文件已生成，添加至 .\Windows\Panther\ 生效。
goto end

:notAnswer
echo.
echo =====================================================
echo 未生成任何应答文件。
goto end

:end
