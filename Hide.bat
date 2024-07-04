@echo off
if exist UnHide.bat del UnHide.bat
for /f "usebackq delims=" %%d in (`dir /b/a ^| findstr /v "Generate.bat Archive"`) do attrib "%%d" +s +h

echo @echo off > Unhide.bat
echo for /f "usebackq delims=" %%%%d in (`dir /b/a ^^^| findstr /v "Generate.bat Archive"`) do attrib "%%%%d" -s -h >> Unhide.bat
echo if exist UnHide.bat del UnHide.bat >> Unhide.bat
