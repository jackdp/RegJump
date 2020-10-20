@echo off

set PATH=%JP_MyToolsDir%;%JP_ToolsDir%;%PATH%

rem --------------- common -----------------
set AppName=RegJump
set AppVer=1.0
set AppDate=2020.10.20
set AppFullName=%AppName% %AppVer%
set AppName_=RegJump
set AppExe=RegJump.exe
set AppUrl=http://www.pazera-software.com/products/regjump/
set README=RegJump_README.txt

::set ArchiveSrc=%AppFullName%_Project.7z


rem ----------------- Windows 32 bit ---------------------
set AppExe32Compiled=RegJump.32.exe
set PortableFileZip32=%AppName_%_win32.zip
set CreatePortableZip32=7z a -tzip -mx=9 %PortableFileZip32% %AppExe% %README%


rem ----------------- Windows 64 bit ---------------------
set AppExe64Compiled=RegJump.64.exe
set PortableFileZip64=%AppName_%_win64.zip
set CreatePortableZip64=7z a -tzip -mx=9 %PortableFileZip64% %AppExe% %README%


