@echo off 
:START_PROCESS
::echo.
::echo =====================================================
::echo Clean OS �Զ���װ�ű���֧������Ӧ���ļ���
::echo Presented with heart by Q3aN.
::echo 2021.06.02
::echo.
::echo =====================================================
::echo �� esd/wim �����ļ����ڴ�Ŀ¼�¡������������֣�
set Image=install.esd

echo.
echo =====================================================
echo �� �� �� װ�� %Image%
echo.
echo    �� ע �� ������
echo �˲�������ʽ��Ŀ���̲����·�����
echo.
echo =====================================================
set choice=
set /p choice=���� ok �������������� a ������Ӧ���ļ���
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
set /p choice=����Ŀ����(0/1.../5)��
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
echo Ӧ���ļ���
echo   1. �������ģʽ
echo   2. ���������˻�
echo   3. ��������Ա�˻�
echo   4. ���� S Mode
echo.
echo =====================================================
set choice=
set /p choice=��ѡ��(1/2/...)��
if /i "%choice%"=="1" goto audit
if /i "%choice%"=="2" goto user
if /i "%choice%"=="3" goto admin
if /i "%choice%"=="4" goto smode

goto notAnswer

:: ���ģʽ
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

:: �����˻�
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

:: ����Ա�˻�
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
echo Ӧ���ļ�����ӣ��´�������Ч��
goto end

:notInstall
echo.
echo =====================================================
echo ����ȡ����
echo.
goto end

:notDel
echo.
echo =====================================================
echo Ӧ���ļ������ɣ������ .\Windows\Panther\ ��Ч��
goto end

:notAnswer
echo.
echo =====================================================
echo δ�����κ�Ӧ���ļ���
goto end

:end
