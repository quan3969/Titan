@echo off
for /f "usebackq delims=" %%d in (`dir /b ^| findstr /v "Generate.bat 0-Temp 1-Apps 2-Drivers 3-BIOS 4-Misc"`) do attrib "%%d" +s +h
del Hide.bat