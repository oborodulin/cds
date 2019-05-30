@Echo Off
1>nul copy /y aB2Econv_x86.txt /B + ..\cfds.cmd /B cfds_x86.tmp /B
"C:\Program Files (x86)\Advanced BAT to EXE Converter v2.94\ab2econv294\aB2Econv.exe" cfds_x86.tmp D:\utils\releases\cfds\cfds_x86.exe
1>nul copy /y ..\cfds.ini D:\utils\releases\cfds\
