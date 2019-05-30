@ECHO OFF
REM BFCPEOPTIONSTART
REM Advanced BAT to EXE Converter www.BatToExeConverter.com
REM BFCPEEXE=D:\utils\releases\cfds\cfds.exe
REM BFCPEICON=C:\Program Files (x86)\Advanced BAT to EXE Converter v4.05\ab2econv405\icons\icon13.ico
REM BFCPEICONINDEX=1
REM BFCPEEMBEDDISPLAY=0
REM BFCPEEMBEDDELETE=1
REM BFCPEADMINEXE=0
REM BFCPEINVISEXE=0
REM BFCPEVERINCLUDE=1
REM BFCPEVERVERSION=1.0.0.0
REM BFCPEVERPRODUCT=Victory CfDS
REM BFCPEVERDESC=Command file Distribution System
REM BFCPEVERCOMPANY=Victory UMS
REM BFCPEVERCOPYRIGHT=2013-2016 Oleg Borodulin
REM BFCPEEMBED=D:\utils\bis\Distribution\build\win_x86\Bat_To_Exe_Converter.exe
REM BFCPEEMBED=D:\utils\bis\Distribution\utils_x86\uniconv\uniconv.exe
REM BFCPEEMBED=D:\utils\bis\Distribution\utils_x86\uniconv\btuc21d3.dll
REM BFCPEEMBED=D:\utils\bis\Distribution\utils_x86\7za.exe
REM BFCPEEMBED=D:\utils\bis\Distribution\utils_x86\fnr.exe
REM BFCPEOPTIONEND
@ECHO ON
@Echo Off
rem Copyright (C) 2013-2015 Oleg Borodulin (admin@bis.unimansys.com)

rem This program is free software: you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation, either version 3 of the License, or
rem (at your option) any later version.

rem This program is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
rem GNU General Public License for more details.

rem You should have received a copy of the GNU General Public License
rem along with this program.  If not, see <http://www.gnu.org/licenses/>.

setlocal enableextensions enabledelayedexpansion
cls
1>nul chcp 1251
set module_name=%~nx0

rem определяем подгружена ли утилита изменения цвета
if exist "%b2eincfilepath%\chgcolor.exe" (
	set ChangeColor_8_0="%b2eincfilepath%\chgcolor.exe" 08
	set ChangeColor_10_0="%b2eincfilepath%\chgcolor.exe" 0A
	set ChangeColor_11_0="%b2eincfilepath%\chgcolor.exe" 0B
	set ChangeColor_12_0="%b2eincfilepath%\chgcolor.exe" 0C
	set ChangeColor_14_0="%b2eincfilepath%\chgcolor.exe" 0E
	set ChangeColor_15_0="%b2eincfilepath%\chgcolor.exe" 0F
)

rem ChangeColor 8 0
%ChangeColor_8_0%
echo Victory CDS for Windows {Current_Version}. {Copyright} {Current_Date}
echo.

rem http://www.f2ko.de/programs.php?lang=en&pid=b2e

rem РАЗБОР ПАРАМЕТРОВ ЗАПУСКА:
:start_parse
set p_param=%~1
set p_key=%p_param:~0,3%
set p_value=%p_param:~4%

if "%p_param%" EQU "" goto end_parse

if "%p_key%" EQU "-if" set ini_file=%p_value%
if "%p_key%" EQU "-pn" set productname=%p_value%
if "%p_key%" EQU "-sd" set rel_src_dir=%p_value%
if "%p_key%" EQU "-td" set rel_temp_dir=%p_value%
if "%p_key%" EQU "-bd" set rel_build_dir=%p_value%
if "%p_key%" EQU "-bf" set build_file=%p_value%
if "%p_key%" EQU "-df" set desc_file=%p_value%
if "%p_key%" EQU "-vf" set ver_file=%p_value%
if "%p_key%" EQU "-rf" set resource_file=%p_value%
if "%p_key%" EQU "-ic" set icon_file=%p_value%
if "%p_key%" EQU "-ef" set exclude_file=%p_value%
if "%p_key%" EQU "-ma" set ma_version=%p_value%
if "%p_key%" EQU "-dt" set distrib_type=%p_value%
if "%p_key%" EQU "-cr" set cmd_replace=%p_value%
if "%p_key%" EQU "-ep" set encrypt_pass=%p_value%
if "%p_key%" EQU "-pa" set proc_arch=%p_value%
if "%p_key%" EQU "-gr" set generate_release=%p_value%
if "%p_key%" EQU "-rt" set release_type=%p_value%
if "%p_key%" EQU "-lt" set license_type=%p_value%

shift
goto start_parse

:end_parse

rem УТОЧНЕНИЕ ПАРАМЕТРОВ СИСТЕМЫ:
rem Определяем разрядность системы (http://social.technet.microsoft.com/Forums/windowsserver/en-US/cd44d6d3-bdfa-4970-b7db-e3ee746d6213/determine-x86-or-x64-from-registry?forum=winserverManagement)
set sys_arch=x86

set KEY_NAME="HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
set VALUE_NAME=PROCESSOR_ARCHITECTURE

FOR /F "usebackq skip=1 tokens=1-3" %%A IN (`REG QUERY %KEY_NAME% /v %VALUE_NAME% 2^>nul`) DO (
    set ValueName=%%A
    set ValueType=%%B
    set ValueValue=%%C
)
if defined ValueName (
    if not "%proc_arch%" EQU "%ValueValue%" set sys_arch=x64
)
if not defined proc_arch set proc_arch=%sys_arch%

rem Определяем структуру начальных каталогов и файлов сборки проекта

if not defined productname goto undef_productname

rem MakeLower %productname%

if defined b2eprogramfilename %extd% /lowercase %productname%

set lcase_productname=%result%

if not defined rel_temp_dir set rel_temp_dir=%TEMP% 
set rel_temp_dir=%rel_temp_dir%\%lcase_productname%
for /f %%i in ("%rel_temp_dir%") do Set abs_temp_dir=%%~dpni

if not defined rel_src_dir goto undef_rel_src_dir
for /f %%i in ("%rel_src_dir%") do Set abs_src_dir=%%~dpni

if not defined rel_build_dir goto undef_rel_build_dir
set rel_build_dir=%rel_build_dir%\%lcase_productname%
for /f %%i in ("%rel_build_dir%") do Set abs_build_dir=%%~dpni

if defined icon_file if not exist "%icon_file%" (
				set icon_file=
			) else (
				for /f %%i in ("%icon_file%") do Set icon_file=%%~dpnxi
			)
if not defined distrib_type set distrib_type=zip 
if not defined cmd_replace set cmd_replace=yes

if not defined build_file set build_file=.\%lcase_productname%_build.txt
for /f %%i in ("%build_file%") do Set build_file=%%~dpnxi

if not defined desc_file set desc_file=.\%lcase_productname%_description.txt
for /f %%i in ("%desc_file%") do Set desc_file=%%~dpnxi

if not defined ver_file set ver_file=.\%lcase_productname%_version.txt
for /f %%i in ("%ver_file%") do Set ver_file=%%~dpnxi

if not defined resource_file set resource_file=.\%lcase_productname%_%proc_arch%_resources.txt
for /f %%i in ("%resource_file%") do Set resource_file=%%~dpnxi

if not defined exclude_file set exclude_file=.\%lcase_productname%_exc_copy.txt
for /f %%i in ("%exclude_file%") do Set exclude_file=%%~dpnxi

for /f %%i in (".\aB2Econv_%proc_arch%.txt") do Set aB2Econv_file=%%~dpnxi

rem установка файла инициализации по умолчанию
if not defined ini_file (
	if exist ".\%lcase_productname%.ini" (
		set ini_file=.\%lcase_productname%.ini
	) else (
		set ini_file=.\cdfs.ini
	)
)
for /f %%i in ("%ini_file%") do Set ini_file=%%~dpnxi

rem ФОРМИРУЕМ ВЕРСИЮ РЕЛИЗА:
rem Получаем информацию о предыдущей версии проекта
if not exist "%ver_file%" (
	if "%ma_version%" == ""	Set ma_version=1
	Set mi_version=0
	Set bi_number=0
) else (
	for /F "usebackq tokens=1,2 delims=	" %%i in ("%ver_file%") do (
		if "%%i" == "ma_version" (
			if "%ma_version%" == ""	set ma_version=%%~j
		)
		if "%%i" == "mi_version" set mi_version=%%~j
		if "%%i" == "bi_number" set bi_number=%%~j
	)
)

rem Получаем текущую дату в формате ISO в качестве версии сборки
CALL :GetISODate 
Set bi_version=%ISODate%

rem Наращиваем номер сборки проекта
set /a bi_number=%bi_number%+1

Set productversion=%ma_version%.%mi_version%.%bi_version%.%bi_number%
set file_version=%ma_version%.%mi_version%.%bi_number%.0

rem ВЫВОД ПАРАМЕТРОВ СБОРКИ:
rem ChangeColor 8 0
%ChangeColor_8_0%
echo ========================================
rem ChangeColor 14 0 
%ChangeColor_14_0%
echo Параметры сборки проекта:
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo ========================================
echo | set /p "dummyName=Приложение: " 
rem ChangeColor 15 0
%ChangeColor_15_0%
echo %productname% (%proc_arch%) v.%productversion%

if exist "%ini_file%" (
rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=Файл инициализации: "
rem ChangeColor 15 0 
%ChangeColor_15_0%
	echo %ini_file%
)
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Каталог исходных файлов: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %abs_src_dir%
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Каталог сборки: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %abs_build_dir%
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Временный каталог: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %abs_temp_dir%
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Файл сборки: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %build_file%

if exist "%resource_file%" (
rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=Файл ресурсов: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
	echo %resource_file%
)
if exist "%desc_file%" (
rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=Файл описания: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
	echo %desc_file%
)
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Файл версии: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %ver_file%
if exist "%exclude_file%" (
rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=Файл исключений: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
	echo %exclude_file%
)
echo.

rem РАЗБОР ФАЙЛА ИНИЦИАЛИЗАЦИИ:
if exist "%ini_file%" (
	for /F "usebackq eol=; tokens=1,2 delims==" %%i in ("%ini_file%") do (
		if /i "%%i" EQU "cmd_conv_%proc_arch%" set cmd_compiler=%%j
		if /i "%%i" EQU "cp_conv_%proc_arch%" set converter=%%j
	
		rem Установка компилятора AutoIt в зависимости от системной архитектуры процессора
		rem Указываем путь к AutoIt (необходимо, так как компилятор вычисляет включаемые файлы в зависимочти от своего расположения)
		if /i "%%i" EQU "au3_conv_%proc_arch%" set autoit_compiler=%%j
		if /i "%%i" EQU "replacer_%proc_arch%" set replacer=%%j
		if /i "%%i" EQU "installer_%proc_arch%" set installer=%%j
	
		rem получение параметров командной строки приложений системы
		rem по конвертеру:
		if /i "%%i" EQU "encoding_cp1251" set encoding_cp1251=%%j
		if /i "%%i" EQU "encoding_unicode" set encoding_unicode=%%j

		rem по поиску и замене:
		if /i "%%i" EQU "rep_pcli" set rep_pcli=%%j
		if /i "%%i" EQU "rep_dir" set rep_dir=%%j
		if /i "%%i" EQU "rep_mask" set rep_mask=%%j
		if /i "%%i" EQU "rep_fnd" set rep_fnd=%%j
		if /i "%%i" EQU "rep_rep" set rep_rep=%%j
		if /i "%%i" EQU "tpl_start_symb" set tpl_start_symb=%%j
		if /i "%%i" EQU "tpl_end_symb" set tpl_end_symb=%%j

		rem по компилятору командных файлов
		if /i "%%i" EQU "cmd_in" set cmd_in=%%j
		if /i "%%i" EQU "cmd_out" set cmd_out=%%j
		if /i "%%i" EQU "cmd_enc" set cmd_enc=%%j
		if /i "%%i" EQU "cmd_owr" set cmd_owr=%%j
		if /i "%%i" EQU "cmd_cmp" set cmd_cmp=%%j
		if /i "%%i" EQU "cmd_ico" set cmd_ico=%%j
		if /i "%%i" EQU "cmd_x64" set cmd_x64=%%j
		if /i "%%i" EQU "cmd_inc" set cmd_inc=%%j

		rem по компилятору AutoIt
		if /i "%%i" EQU "au3_in" set au3_in=%%j
		if /i "%%i" EQU "au3_out" set au3_out=%%j
		if /i "%%i" EQU "au3_ico" set au3_ico=%%j
		if /i "%%i" EQU "au3_type" set au3_type=%%j

		rem по инсталлятору
		if /i "%%i" EQU "ins_add" set ins_add=%%j
		if /i "%%i" EQU "ins_type" set ins_type=%%j
		if /i "%%i" EQU "ins_pcli" set ins_pcli=%%j
		if /i "%%i" EQU "ins_inc" set ins_inc=%%j
		if /i "%%i" EQU "ins_exc" set ins_exc=%%j

		rem информация по лицензии и авторским правам
		if /i "%%i" EQU "cmd_license" set cmd_license=%%j
		if /i "%%i" EQU "au3_license" set au3_license=%%j
		if /i "%%i" EQU "gnu_license" set gnu_license=%%j
	)
) else (
rem ChangeColor 14 0 
%ChangeColor_14_0%
	echo Файл инициализации не найден! Используются приложения системы и их параметры по умолчанию...
)
rem echo "%cmd_cmp%"
if not defined cmd_compiler set cmd_compiler="%MYFILES%\Bat_To_Exe_Converter.exe"
if not defined converter set converter="%MYFILES%\uniconv.exe"
if not defined replacer set replacer="%MYFILES%\fnr.exe"
if not defined installer set installer="%MYFILES%\7za.exe"

for /f %%i in ("%cmd_compiler%") do Set cmd_compiler_file=%%~ni
for /f %%i in ("%converter%") do Set converter_file=%%~ni
for /f %%i in ("%replacer%") do Set replacer_file=%%~ni
for /f %%i in ("%installer%") do Set installer_file=%%~ni

rem КОНТРОЛЬ ОБЯЗАТЕЛЬНЫХ ПАРАМЕТРОВ КОМАНДНОЙ СТРОКИ
rem по конвертеру
if /i "%converter_file%" EQU "uniconv" (
	if not defined encoding_cp1251 set encoding_cp1251=cp1251
	if not defined encoding_unicode set encoding_unicode=Unicode11:BOM:big-endian
) else (
	if not defined encoding_cp1251 goto undef_encoding_cp1251
	if not defined encoding_unicode goto undef_encoding_unicode
)
rem по поиску и замене
if /i "%replacer_file%" EQU "fnr" (
	if not defined rep_pcli set rep_pcli=--cl --includeSubDirectories
	if not defined rep_dir set rep_dir=--dir
	if not defined rep_mask set rep_mask=--fileMask
	if not defined rep_fnd set rep_fnd=--find
	if not defined rep_rep set rep_rep=--replace
) else (
	if not defined rep_dir goto undef_rep_dir
	if not defined rep_mask goto undef_rep_mask
	if not defined rep_fnd goto undef_rep_fnd
	if not defined rep_rep goto undef_rep_rep
)
if not defined tpl_start_symb set tpl_start_symb={
if not defined tpl_end_symb set tpl_end_symb=}

rem по компилятору командных файлов
if /i "%cmd_compiler_file%" EQU "Bat_To_Exe_Converter" (
	if not defined cmd_in set cmd_in=-bat
	if not defined cmd_out set cmd_out=-save
) else (
	if not defined cmd_in goto undef_cmd_in
	if not defined cmd_out goto undef_cmd_out
)
rem по компилятору AutoIt
if not defined au3_in set au3_in=/in
if not defined au3_out set au3_out=/out
if not defined au3_ico set au3_ico=/icon
if not defined au3_type set au3_type=/console

rem по инсталлятору
if /i "%installer_file%" EQU "7za" (
	if not defined ins_add set ins_add=u
	if not defined ins_type set ins_type=-t
	if not defined ins_inc set ins_inc=-i@
	if not defined ins_exc set ins_exc=-xr@
	if not defined ins_pcli set ins_pcli=-mx9 -mmt=on -up1q0r2x1y2z1w2 -r -ssw -scsUTF-8
)

rem ВЫВОД ПУТЕЙ К ПРИЛОЖЕНИЯМ СИСТЕМЫ:
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo ========================================
rem ChangeColor 14 0 
%ChangeColor_14_0%
echo Пути к внешним приложениям системы:
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo ========================================
echo | set /p "dummyName=Компилятор командных файлов: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %cmd_compiler%
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Компилятор AutoIt: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %autoit_compiler%
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Конвертер кодировок файлов: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %converter%
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Утилита поиска и замены строк в файлах: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %replacer%
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Инсталлятор: " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %installer%
echo.

cd %~dp0

if /i "%generate_release%" EQU "true" (
	rem Замер времени выполнения (http://stackoverflow.com/questions/739606/how-long-a-batch-file-takes-to-execute)
	set STARTTIME=%TIME%
	if not exist "%abs_build_dir%" call :FullBuild
	call :ReleaseBuild
	goto end_time
)

Choice /T 20 /D N /M "Продолжить сборку проекта"
if "%Errorlevel%" EQU "2" endlocal & exit /b 1

rem ВЫВОД МЕНЮ СБОРКИ ПРОЕКТА:
:menu
cls
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo ========================================
echo | set /p "dummyName=Сборка проекта " 
rem ChangeColor 14 0
%ChangeColor_14_0%
echo %productname% v.%ma_version%.%mi_version%.%bi_version%.%bi_number%
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo ========================================
echo.
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo Выбор действия:
echo 	1 - Перестроить проект полностью
echo 	2 - Создать релиз проекта (%proc_arch%)
echo 	3 - Избирательная сборка проекта (по умолчанию)
rem echo 	4 - Создать архив файлов исходного кода проекта (GPL)
echo 	4 - Показать параметры запуска системы
echo 	5 - Выход
echo.

Choice /C 12345 /T 10 /D 3 /M "Что необходимо сделать"

if "%Errorlevel%" EQU "1" (
	rem Замер времени выполнения (http://stackoverflow.com/questions/739606/how-long-a-batch-file-takes-to-execute)
	set STARTTIME=%TIME%
	call :FullBuild
)
if "%Errorlevel%" EQU "2" (
	set STARTTIME=%TIME%
	call :SelectBuild
	call :ReleaseBuild
)
if "%Errorlevel%" EQU "3" (
	set STARTTIME=%TIME%
	call :SelectBuild
)
rem if "%Errorlevel%" EQU "4" (
rem set STARTTIME=%TIME%
rem set source_build=true
rem call :SelectBuild
rem )
if "%Errorlevel%" EQU "4" (
	call :PrintExecFormat %module_name%
rem ChangeColor 15 0 
%ChangeColor_15_0%
	echo.
	pause
	goto menu
)
if "%Errorlevel%" EQU "5" endlocal & exit /b 0

:end_time
set ENDTIME=%TIME%

rem формирование и вывод времени выполнения

rem ChangeColor 8 0 
%ChangeColor_8_0%
echo ========================================
rem output as time
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Начало выполнения в " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %STARTTIME%
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Завершение выполнения в " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %ENDTIME%

rem convert STARTTIME and ENDTIME to centiseconds
set STARTTIME=%STARTTIME: =0%
set ENDTIME=%ENDTIME: =0%
set /A STARTTIME=(1%STARTTIME:~0,2%-100)*360000 + (1%STARTTIME:~3,2%-100)*6000 + (1%STARTTIME:~6,2%-100)*100 + (1%STARTTIME:~9,2%-100)
set /A ENDTIME=(1%ENDTIME:~0,2%-100)*360000 + (1%ENDTIME:~3,2%-100)*6000 + (1%ENDTIME:~6,2%-100)*100 + (1%ENDTIME:~9,2%-100)

rem calculating the duratyion is easy
set /A DURATION=%ENDTIME%-%STARTTIME%

rem we might have measured the time inbetween days
if %ENDTIME% LSS %STARTTIME% set /A DURATION=%STARTTIME%-%ENDTIME%

rem now break the centiseconds down to hors, minutes, seconds and the remaining centiseconds
set /A DURATIONH=%DURATION% / 360000
set /A DURATIONM=(%DURATION% - %DURATIONH%*360000) / 6000
set /A DURATIONS=(%DURATION% - %DURATIONH%*360000 - %DURATIONM%*6000) / 100
set /A DURATIONHS=(%DURATION% - %DURATIONH%*360000 - %DURATIONM%*6000 - %DURATIONS%*100)

rem some formatting
if %DURATIONH% LSS 10 set DURATIONH=0%DURATIONH%
if %DURATIONM% LSS 10 set DURATIONM=0%DURATIONM%
if %DURATIONS% LSS 10 set DURATIONS=0%DURATIONS%
if %DURATIONHS% LSS 10 set DURATIONHS=0%DURATIONHS%

rem outputing
rem echo STARTTIME: %STARTTIME% ms
rem echo ENDTIME: %ENDTIME% ms
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Выполнено за " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo  | set /p "dummyName=%DURATION% "
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo мс
rem echo %DURATIONH%:%DURATIONM%:%DURATIONS%,%DURATIONHS%

rem Если генерация релиза, то выходим
if /i "%generate_release%" EQU "true" endlocal & exit /b 0

rem ChangeColor 15 0 
%ChangeColor_15_0%
echo.
pause
goto menu

:undef_productname	
rem ChangeColor 12 0 
%ChangeColor_12_0%
echo Не указано наименование (идентификатор) проекта 1>&2
call :PrintExecFormat %module_name%
endlocal & exit /b 2

:undef_rel_src_dir
rem ChangeColor 12 0 
%ChangeColor_12_0%
echo Не указан каталог исходных файлов проекта 1>&2
call :PrintExecFormat %module_name%
endlocal & exit /b 2

:undef_rel_build_dir
rem ChangeColor 12 0 
%ChangeColor_12_0%
echo Не указан каталог сборки проекта 1>&2
call :PrintExecFormat %module_name%
endlocal & exit /b 2
rem ---------------- EOF main.cmd ----------------

rem ==========================================================================
rem Процедура FullBuild - полная перестройка проекта
rem ==========================================================================
:FullBuild
rem Если выбрана полная перестройка проекта
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo.
Choice /T 20 /D N /M "Удалить полностью каталог сборки (%abs_build_dir%) и временный каталог (%abs_temp_dir%)"
if "%Errorlevel%" EQU "2" endlocal & exit /b 1

if exist "%abs_temp_dir%" 1>nul rd /S /Q "%abs_temp_dir%"
if exist "%abs_build_dir%" 1>nul rd /S /Q "%abs_build_dir%"
call :SelectBuild
exit /b 0

rem ==========================================================================
rem Процедура SelectBuild - избирательная сборка проекта (по умолчанию)
rem ==========================================================================
:SelectBuild
echo.
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Формирование файла сборки проекта (" 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo | set /p "dummyName=%build_file%"
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=)... "
rem http://www.computing.net/answers/programming/batch-file-to-clear-txt-file/12925.html
type nul > "%build_file%"

rem http://ss64.com/nt/forfiles.html
rem Для пакетных командных файлов
set cmd_build_mark=false
set cmd_compile_mark=false
FOR /f "tokens=1,2,3" %%a IN ('2^> nul FORFILES /p "%abs_src_dir%" /m *.cmd /s /C "cmd /c echo @relpath @fdate @ftime"') DO (
	set src_file_path=%%~a

	rem если это файл не каталога src\build
	if /i not "!src_file_path:~2,5!" EQU "build" (
		set src_file_path=!src_file_path:~2!
		set build_file_path=!src_file_path:.cmd=.exe!
		set compile_mark=false

		rem http://superuser.com/questions/15214/command-line-batch-file-to-list-all-the-jar-files
		rem http://ss64.com/nt/syntax-args.html
		for %%i in ("%abs_src_dir%\!src_file_path!") do (
			set src_file_time=%%~ti
			set src_file_size=%%~zi
		)
		rem если исходный файл не найден во временном каталоге
		if not exist "%abs_temp_dir%\!src_file_path!" (
			set compile_mark=true
			set cmd_compile_mark=true

			set cmd_build_mark=true
			set /a mi_version=%mi_version%+1
			set bi_number=1
		) else (
			rem если исходный файл найден во временном каталоге
			for %%i in ("%abs_temp_dir%\!src_file_path!") do (
				if not "!src_file_time!" EQU "%%~ti" (
					rem echo время !src_file_path!: "!src_file_time!" не равно "%%~ti" %%~ai
				 	set compile_mark=true
					set cmd_compile_mark=true
					rem set /a mi_version=%mi_version%+1
				)
				if not "!src_file_size!" EQU "%%~zi" (
					rem echo размер !src_file_path!: "!src_file_time!" не равно "%%~ti" %%~ai
			 		set compile_mark=true
					set cmd_compile_mark=true
					rem set /a mi_version=%mi_version%+1
				)
			)
		)
		rem Если взведён признак компиляции, то добавляем имя файла
		if /i "!compile_mark!" EQU "true" (
			set out_file=%abs_build_dir%\!build_file_path!
			set find_resource=false

			rem если компилируемый файл является ресурсом
			if exist "%resource_file%" (
				for /F "usebackq eol=; tokens=1,2 delims=	" %%o in ("%resource_file%") do (
					if /i "!build_file_path!" EQU "%%~p" (
						set out_file=%abs_temp_dir%\!build_file_path! 
						set find_resource=true
					)
				)
			)
			rem если файл является ресурсом
			if /i "!find_resource!" EQU "true" (
				rem пишем данные по нему в начало файла построения
				echo %icon_file%	!src_file_path!	!out_file!>"%build_file%.tmp"
				type "%build_file%">>"%build_file%.tmp"
				move /y "%build_file%.tmp" "%build_file%" 1>nul
			) else (
				echo %icon_file%	!src_file_path!	!out_file!>>"%build_file%"
			)
		)
	)
)
rem Для файлов автоматизации
FOR /f "tokens=1,2,3" %%a IN ('2^>nul FORFILES /p "%abs_src_dir%" /m *.au3 /s /C "cmd /c echo @relpath @fdate @ftime"') DO (
	set src_file_path=%%~a

	rem если это файл не каталога src\build
	if /i not "!src_file_path:~2,5!" EQU "build" (
		set src_file_path=!src_file_path:~2!
		set build_file_path=!src_file_path:.au3=.exe!
		set compile_mark=false

		for %%i in ("%abs_src_dir%\!src_file_path!") do (
			set src_file_time=%%~ti
			set src_file_size=%%~zi
		)
		rem если исходный файл не найден во временном каталоге
		if not exist "%abs_temp_dir%\!src_file_path!" (
			set compile_mark=true
			if "%cmd_build_mark%" EQU "false" (
				set /a mi_version=%mi_version%+1
				set bi_number=1
			)
		) else (
			rem если исходный файл найден во временном каталоге
			for %%i in ("%abs_temp_dir%\!src_file_path!") do (
				if not "!src_file_time!" EQU "%%~ti" set compile_mark=true
				if not "!src_file_size!" EQU "%%~zi" set compile_mark=true
			)
		)
		rem Если взведён признак компиляции, то добавляем имя файла
		if "!compile_mark!" EQU "true" (
			set out_file=%abs_build_dir%\!build_file_path!

			rem если компилируемый файл является ресурсом
			if exist "%resource_file%" (
				for /F "usebackq eol=; tokens=1,2 delims=	" %%o in ("%resource_file%") do (
					if /i "!build_file_path!" EQU "%%~p" (
						set out_file=%abs_temp_dir%\!build_file_path! 
						rem goto find_resource
					)
				)
			)
:find_resource
			echo %icon_file%	!src_file_path!	!out_file!>>"%build_file%"
		)
	)
)

rem ChangeColor 10 0 
%ChangeColor_10_0%
echo Ok & echo.

if not exist "%abs_build_dir%" (
rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=Создание структуры каталогов исполняемых файлов (" 
rem ChangeColor 15 0 
%ChangeColor_15_0%
	echo | set /p "dummyName=%abs_build_dir%"
rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=)... "

	1>nul xcopy /E /EXCLUDE:%exclude_file% "%abs_src_dir%" "%abs_build_dir%"\
rem ChangeColor 10 0 
%ChangeColor_10_0%
	echo Ok & echo.
)
rem exit
rem Копирование пакета во временную папку (синхронизация с обновлением по времени)
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Создание копии проекта во временном каталоге (" 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo | set /p "dummyName=%abs_temp_dir%"
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=)... "
rem xcopy /S ..\src\*.cmd temp\
1>nul Robocopy.exe "%abs_src_dir%" "%abs_temp_dir%" *.cmd *.au3 /s /XD "build" /COPY:DAT /PURGE /TIMFIX
rem ChangeColor 10 0 
%ChangeColor_10_0%
echo Ok & echo.

rem Читаем описание проекта и информацию об авторском праве (http://www.cyberforum.ru/cmd-bat/thread665872.html)
if exist "%desc_file%" (
rem	for /f "usebackq  delims=" %%i in (`find /n /v "" "GPL\Copyright.txt" ^| find "[1]"`) do (
	for /f "usebackq eol=; tokens=1,2 delims==" %%i in ("%desc_file%") do (
		if /i "%%i" EQU "copyright" set copyright=%%j
		if /i "%%i" EQU "product" set product=%%j
		if /i "%%i" EQU "description" set description=%%j
		if /i "%%i" EQU "company" set company=%%j
	)
)

rem Если были изменения в пакетных файлах
if "%cmd_compile_mark%" EQU "true" (
	rem http://code.google.com/p/win-iconv/
	rem http://hashcode.ru/questions/45585/%D0%BA%D0%BE%D0%B4%D0%B8%D1%80%D0%BE%D0%B2%D0%BA%D0%B0-%D0%BA%D0%B0%D0%BA-%D0%BA%D0%BE%D0%BD%D0%B2%D0%B5%D1%80%D1%82%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D1%82%D1%8C-%D0%B2%D1%81%D0%B5-%D1%84%D0%B0%D0%B9%D0%BB%D1%8B-%D0%B2-%D0%B4%D0%B8%D1%80%D0%B5%D0%BA%D1%82%D0%BE%D1%80%D0%B8%D0%B8-%D0%B8%D0%B7-windows-1251-%D0%B2-utf
	rem for /F "usebackq eol=; skip=1 tokens=1,2,3 delims=	" %%i in ("wamp_build.txt") do %utils_dir%\win_iconv.exe -t UTF-8 -f WINDOWS-1251 "temp\%%j" > "temp\%%j.txt"

	rem http://gnuwin32.sourceforge.net/packages/libiconv.htm
	rem for /F "usebackq eol=; skip=1 tokens=1,2,3 delims=	" %%i in ("wamp_build.txt") do %utils_dir%\libiconv\bin\iconv.exe -t UTF-8 -f WINDOWS-1251 "temp\%%j" > "temp\%%j.txt"
	
rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=Предварительная обработка пакетных файлов... "
	for /F "usebackq eol=; tokens=1,2,3 delims=	" %%i in ("%build_file%") do (
		if /i "%%~xj" EQU ".cmd" %converter% %encoding_cp1251% "%abs_temp_dir%\%%j" %encoding_unicode% "%abs_temp_dir%\%%j-utf8.txt"
	)

	rem 1>nul del /S /Q "%abs_temp_dir%\*.cmd"
	rem если не отменено, то меняем все вызовы командных файлов и ссылки на них на соответствующие exe-файлы
	if /i NOT "%cmd_replace%" EQU "no" (
		%replacer% %rep_pcli% %rep_dir% "%abs_temp_dir%" %rep_mask% "*.txt" %rep_fnd% ".cmd" %rep_rep% ".exe"
	)
	rem добавляем сведения об авторском праве
	%replacer% %rep_pcli% %rep_dir% "%abs_temp_dir%" %rep_mask% "*.txt" %rep_fnd% "%tpl_start_symb%Copyright%tpl_end_symb%" %rep_rep% "%copyright%"

	rem добавляем сведения о дате построения проекта
	%replacer% %rep_pcli% %rep_dir% "%abs_temp_dir%" %rep_mask% "*.txt" %rep_fnd% "%tpl_start_symb%Current_Date%tpl_end_symb%" %rep_rep% "%DATE%"

	rem добавляем сведения о текущей версии проекта
	%replacer% %rep_pcli% %rep_dir% "%abs_temp_dir%" %rep_mask% "*.txt" %rep_fnd% "%tpl_start_symb%Current_Version%tpl_end_symb%" %rep_rep% "%productversion%"

	for /F "usebackq eol=; tokens=1,2,3 delims=	" %%i in ("%build_file%") do (
		if /i "%%~xj" EQU ".cmd" %converter% %encoding_unicode% "%abs_temp_dir%\%%j-utf8.txt" %encoding_cp1251% "%abs_temp_dir%\%%j-win1251.cmd"
	)
rem ChangeColor 10 0 
%ChangeColor_10_0%
	echo Ok & echo.


	rem for /F "usebackq eol=; skip=1 tokens=1,2,3 delims=	" %%i in ("wamp_build.txt") do %utils_dir%\libiconv\bin\iconv.exe -t WINDOWS-1251 -f UTF-8 "temp\%%j.txt" > "temp\%%j"
	rem for /F "usebackq eol=; skip=1 tokens=1,2,3 delims=	" %%i in ("wamp_build.txt") do %utils_dir%\win_iconv.exe -t WINDOWS-1251 -f UTF-8 "temp\%%j.txt" > "temp\%%j"

rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=Удаление временных файлов... "
	1,2>nul del /S /Q "%abs_temp_dir%\*.txt"
rem ChangeColor 10 0 
%ChangeColor_10_0%
	echo Ok & echo.
)
rem exit
rem Если была выбрана подготовка исходного кода согласно заданной лицензии 
if /i "%source_build%" EQU "true" (
rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=Подготовка исходного кода проекта... "
	for /F "usebackq eol=; tokens=1,2,3 delims=	" %%i in ("%build_file%") do (
		if /i "%%~xj" EQU ".cmd" (
			%converter% %encoding_cp1251% "%abs_temp_dir%\%%j" %encoding_unicode% "%abs_temp_dir%\%%j-utf8.txt"

			1>nul copy /Y "GPL\License_cmd.txt" + "%abs_temp_dir%\%%j" "%abs_temp_dir%\%%j-src.cmd"
			%converter% %encoding_cp1251% "%abs_temp_dir%\%%j-src.cmd" %encoding_unicode% "%abs_temp_dir%\%%j-src-utf8.txt"
				
		)

		%replacer% %rep_pcli% %rep_dir% "%abs_temp_dir%" %rep_mask% "*-src.cmd" %rep_fnd% "%tpl_start_symb%Copyright%tpl_end_symb%" %rep_rep% "%copyright%"
	
		%replacer% %rep_pcli% %rep_dir% "%abs_temp_dir%" %rep_mask% "*-src.cmd" %rep_fnd% "%tpl_start_symb%Current_Date%tpl_end_symb%" %rep_rep% "%DATE%"

		%replacer% %rep_pcli% %rep_dir% "%abs_temp_dir%" %rep_mask% "*-src.cmd" %rep_fnd% "%tpl_start_symb%Current_Version%tpl_end_symb%" %rep_rep% "%productversion%"
		%converter% %encoding_unicode% "%abs_temp_dir%\%%j-src-utf8.txt" %encoding_cp1251% "%abs_temp_dir%\%%j-src-win1251.cmd"
	)
rem ChangeColor 10 0 
%ChangeColor_10_0%
	echo Ok & echo.
)

if not exist "%abs_build_dir%" (
rem ChangeColor 12 0 
%ChangeColor_12_0%
	echo Не найден каталог сборки проекта! Повторите, пожалуйста, сборку ещё раз 1>&2
	endlocal & exit /b 3
)

rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Обновление конфигурационных файлов проекта... "
1>nul Robocopy.exe "%abs_src_dir%" "%abs_build_dir%" *.cfg *.ini *.json /s /XD "build" /COPY:DAT /PURGE
rem ChangeColor 10 0 
%ChangeColor_10_0%
echo Ok & echo.

rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=Компиляция файлов сценариев в " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo | set /p "dummyName=%abs_build_dir%"
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :
rem "..\..\Bat_To_Exe_Converter\Windows (32 bit)\Bat_To_Exe_Converter.exe" -overwrite -bat "temp\setup.cmd" -save "%%k" -include "..\src\%utils_dir%\*.exe"

for /F "usebackq eol=; tokens=1,2,3 delims=	" %%i in ("%build_file%") do (
rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName= -  %%~nxj => " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
	echo | set /p "dummyName=%%~nxk"
rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=... "
	if exist "%%k" (
		1>nul del /Q "%%k"
	) else (
		1,2>nul del /Q "%%k"
	)
	rem  Компилируем в зависимости от типа файла
	set exec_builder_cli=%cmd_compiler%
	if /i "%%~xj" EQU ".cmd" (
		rem  Определяем компилятор командных файлов
		if /i "%cmd_compiler_file%" EQU "Bat_To_Exe_Converter" (
			set exec_builder_cli=!exec_builder_cli! %cmd_in% "%abs_temp_dir%\%%j-win1251.cmd" %cmd_out% "%%k" 
			rem включаем ресурсы
			if exist "%resource_file%" (
				for /F "usebackq eol=; tokens=1,2 delims=	" %%a in ("%resource_file%") do (
					if /i "%%~nxk" EQU "%%~a" (
						set res_file_path=%%~b
						if "!res_file_path:~1,1!" EQU ":" (
							if exist "%%~b" set exec_builder_cli=!exec_builder_cli! %cmd_inc% "%%~b" 
						) else (
							if exist "%abs_temp_dir%\%%~b" set exec_builder_cli=!exec_builder_cli! %cmd_inc% "%abs_temp_dir%\%%~b" 
						)
					)
				)
			)
			rem -fileversion "%file_version%" (почему-то не работает)
			if defined cmd_owr set exec_builder_cli=!exec_builder_cli! %cmd_owr%
			rem добавляем иконку
			if exist "%%i" set exec_builder_cli=!exec_builder_cli! %cmd_ico% "%%i"
			rem описательная информация по приложению
			if defined copyright set exec_builder_cli=!exec_builder_cli! -copyright "%copyright%" 
			if defined product set exec_builder_cli=!exec_builder_cli! -productname "%product%" 
			if defined description set exec_builder_cli=!exec_builder_cli! -description "%description%" 
			if defined company set exec_builder_cli=!exec_builder_cli! -company  "%company%" 
			rem если указан пароль
			if defined encrypt_pass set exec_builder_cli=!exec_builder_cli! %cmd_enc% %encrypt_pass%
			rem upx-сжатие
			if defined cmd_cmp set exec_builder_cli=!exec_builder_cli! %cmd_cmp%
			rem 64-бит
			if defined cmd_x64 set exec_builder_cli=!exec_builder_cli! %cmd_x64%
		) else if /i "%cmd_compiler_file%" EQU "Bat_To_Exe_Converter" (
			if exist "%aB2Econv_file%" (
				1>nul copy /y "%aB2Econv_file%" /B + "%abs_temp_dir%\%%j-win1251.cmd" /B "%abs_temp_dir%\%%j-win1251.tmp" /B
				set in_file="%abs_temp_dir%\%%j-win1251.tmp"
			) else (
rem ChangeColor 14 0 
%ChangeColor_14_0%
				echo Не найден файл параметров компиляции %aB2Econv_file%! Компиляция без параметров...
				set in_file="%abs_temp_dir%\%%j-win1251.cmd"
			)
			set exec_builder_cli=!exec_builder_cli! !in_file! "%%k"
		)
		rem компиляция
		!exec_builder_cli!	
		
	) else if /i "%%~xj" EQU ".au3" (
		if exist "%autoit_compiler%" (
			rem http://www.autoitscript.com/autoit3/docs/intro/compiler.htm
			set autoit_builder_cli=%autoit_compiler% %au3_in% "%abs_temp_dir%\%%j" %au3_out% "%%k" /%proc_arch% %au3_type%
			rem добавляем иконку
			if exist "%%i" set autoit_builder_cli=!autoit_builder_cli! %au3_ico% "%%i"
			!autoit_builder_cli!
		) else (
rem ChangeColor 12 0 
%ChangeColor_12_0%
			echo Не найден компилятор AutoIt! Укажите, пожалуйста, правильный путь в файле инициализации %ini_file% 1>&2
			endlocal & exit /b 4
		)
	)
rem ChangeColor 10 0 
%ChangeColor_10_0%
	echo Ok
)
echo.

rem Удаление временных файлов
1,2>nul del /S /Q "%abs_temp_dir%\*-win1251.cmd" "%abs_temp_dir%\*.tmp"

rem ФИКСАЦИЯ ТЕКУЩЕЙ ВЕРСИИ ПРОЕКТА
type nul > "%ver_file%"
echo ma_version	"%ma_version%">>"%ver_file%"
echo mi_version	"%mi_version%">>"%ver_file%"
echo bi_number	"%bi_number%">>"%ver_file%"

exit /b 0

rem ==========================================================================
rem Процедура ReleaseBuild - создание релиза проекта
rem ==========================================================================
:ReleaseBuild
if /i not "%release_type%" EQU "" (
	set release_file=%lcase_productname%_%proc_arch%_v%productversion%-%release_type%.%distrib_type%
) else (
	set release_file=%lcase_productname%_%proc_arch%_v%productversion%.%distrib_type%
)
for /f %%i in ("%abs_build_dir%\..\%release_file%") do Set release_file=%%~dpnxi

rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=Формирование релиза проекта версии " 
rem ChangeColor 15 0 
%ChangeColor_15_0%
	echo | set /p "dummyName=%release_file%"
rem ChangeColor 8 0 
%ChangeColor_8_0%
	echo | set /p "dummyName=... "
	if /i "%distrib_type%" EQU "zip" (
		rem контроль списков файлов включения и исключения из релиза
		for /f %%i in (".\%lcase_productname%_%proc_arch%_inc_release.txt") do Set inc_file=%%~dpnxi
		if not exist "!inc_file!" (
rem ChangeColor 12 0 
%ChangeColor_12_0%
			echo Не найден файл списка включения в релиз !inc_file! 1>&2
			goto release_exit
		) 
		for /f %%i in (".\%lcase_productname%_%proc_arch%_exc_release.txt") do Set exc_file=%%~dpnxi
		if not exist "!exc_file!" (
rem ChangeColor 12 0 
%ChangeColor_12_0%
			echo Не найден файл списка исключения из релиза !exc_file! 1>&2
			goto release_exit
		) 
		start "Формирование релиза %productname% v%productversion%..." /WAIT %installer% %ins_add% %ins_type%%distrib_type% %ins_pcli% %release_file% %ins_inc%"!inc_file!" %ins_exc%"!exc_file!"
	)
rem ChangeColor 10 0 
%ChangeColor_10_0%
	echo Ok & echo.
:release_exit
exit /b 0

rem ==========================================================================
rem Процедура PrintExecFormat - печать формата запуска системы
rem ==========================================================================
:PrintExecFormat
echo.
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo Формат запуска системы дистрибуции командных файлов:
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo %~nx1 [^<ключи^>...]
echo.
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo Ключи:
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -if" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :файл инициализации системы (по умолчанию cfds.ini)
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -pn" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=:" 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo | set /p "dummyName=(обязательно) " 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo наименование (идентификатор) проекта
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -sd" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=:" 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo | set /p "dummyName=(обязательно) " 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo каталог исходных файлов проекта (возможен относительный путь)
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -td" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :временный каталог системы (возможен относительный путь). По умолчанию %TEMP%
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -bd" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo | set /p "dummyName=:" 
rem ChangeColor 15 0 
%ChangeColor_15_0%
echo | set /p "dummyName=(обязательно) " 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo каталог сборки проекта (возможен относительный путь)
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -bf" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :файл сборки проекта
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -ef" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :файл исключений сборки проекта
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -df" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :файл описания проекта
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -vf" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :файл версий проекта
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -rf" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :файл ресурсов приложения
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -ic" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :файл пиктограммы приложения
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -ma" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :мажорный номер версии приложения
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -dt" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :тип дистрибутива [zip, 7z, exe, msi] (по умолчанию "zip")
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -cr" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :признак замены всех вызовов командных файлов (*.cmd) на вызовы исполняемых (*.exe) [yes, no] (по умолчанию "yes")
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -ep" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :пароль криптования исполняемого модуля
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -pa" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :признак архитектуры компилируемого приложения [x86, x64] (по умолчанию "%proc_arch%")
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -gr" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :признак генерации релиза [true, false] (по умолчанию "false")
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -rt" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :тип релиза [alpha, beta, dev, prod и т.д] (по умолчанию "ничего")
rem ChangeColor 11 0 
%ChangeColor_11_0%
echo | set /p "dummyName=   -lt" 
rem ChangeColor 8 0 
%ChangeColor_8_0%
echo :тип лицензии [GPL или др.] (по умолчанию "ничего")
exit /b 0

rem ==========================================================================
rem Функция GetTemporaryName()
rem ==========================================================================
:GetTemporaryName
    setlocal enableextensions enabledelayedexpansion

:NextName
    set sTempName=%temp%\temp%random%.tmp

    if exist "%sTempName%" goto :NextName

    set sProcName=%~0

    endlocal & set %sProcName:~4%=%sTempName%
exit /b 0

rem ==========================================================================
rem Функция GetISODate()
rem http://ss64.com/nt/syntax-getdate.html
rem ==========================================================================
:GetISODate
	setlocal enableextensions enabledelayedexpansion
	:: Check WMIC is available
	WMIC.EXE Alias /? >NUL 2>&1 || GOTO get_date_error

	:: Use WMIC to retrieve date and time
	FOR /F "skip=1 tokens=1-6" %%G IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') DO (
		IF "%%~L"=="" goto s_done
		Set _yyyy=%%L
		Set _mm=00%%J
		Set _dd=00%%G
		Set _hour=00%%H
		SET _minute=00%%I
	)
:s_done

	:: Pad digits with leading zeros
	Set _mm=%_mm:~-2%
      	Set _dd=%_dd:~-2%
      	Set _hour=%_hour:~-2%
      	Set _minute=%_minute:~-2%

	Set _isodate=%_yyyy%%_mm%%_dd%
	:: Display the date/time in ISO 8601 format:
	rem Set _isodate=%_yyyy%-%_mm%-%_dd% %_hour%:%_minute%
	rem Echo %_isodate%

	set sProcName=%~0
    	endlocal & set %sProcName:~4%=%_isodate%
GOTO:EOF

:get_date_error
rem ChangeColor 12 0 
%ChangeColor_12_0%
	echo Ошибка формирования текущей даты 1>&2

GOTO:EOF

rem ---------------- EOF cfds.cmd ----------------