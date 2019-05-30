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

rem Определяем разрядность системы (http://social.technet.microsoft.com/Forums/windowsserver/en-US/cd44d6d3-bdfa-4970-b7db-e3ee746d6213/determine-x86-or-x64-from-registry?forum=winserverManagement)
%extd% /is64bit

set proc_arch=x86
if "%result%" EQU set proc_arch=x64


set utils_dir=utils_%proc_arch%
Set chcolor=%utils_dir%\chgcolor.exe
set compiler_dir=build\win_%proc_arch%

rem Установка компилятора AutoIt в зависимости от системной архитектуры процессора
rem Указываем путь к AutoIt (необходимо, так как компилятор вычисляет включаемые файлы в зависимочти от своего расположения)
set autoit_path=.\AutoIt3
if "%proc_arch%" EQU "x86" (
rem	set autoit_path=C:\Program Files\AutoIt3
	set autoit_compiler=!autoit_path!\Aut2Exe\Aut2exe.exe
) else (
rem	set autoit_path=C:\Progra~2\AutoIt3
	set autoit_compiler=!autoit_path!\Aut2Exe\Aut2exe_x64.exe
)

chgcolor 08 & echo Script To Exe Builder Windows 7 v.2.4 Copyright (c) 2013-2015 Borodulin Oleg (admin@bis.unimansys.com) 2013-12-16
echo.

rem http://www.f2ko.de/programs.php?lang=en&pid=b2e

rem Разбор параметров запуска
:start_parse
set p_param=%~1
set p_key=%p_param:~0,3%
set p_value=%p_param:~4%

if "%p_param%" EQU "" goto end_parse

if "%p_key%" EQU "-pn" set productname=%p_value%
if "%p_key%" EQU "-ds" set description=%p_value%
if "%p_key%" EQU "-sd" set rel_src_dir=%p_value%
if "%p_key%" EQU "-td" set rel_temp_dir=%p_value%
if "%p_key%" EQU "-bd" set rel_build_dir=%p_value%
if "%p_key%" EQU "-bf" set build_file=%p_value%
if "%p_key%" EQU "-ex" set exclude_files=%p_value%
if "%p_key%" EQU "-ma" set ma_version=%p_value%
if "%p_key%" EQU "-dt" set distrib_type=%p_value%
if "%p_key%" EQU "-cr" set cmd_replace=%p_value%
if "%p_key%" EQU "-ep" set encrypt_pass=%p_value%
rem переопределение системной архитектуры процессора
if "%p_key%" EQU "-pa" set proc_arch=%p_value%
if "%p_key%" EQU "-gr" set generate_release=%p_value%
if "%p_key%" EQU "-rt" set release_type=%p_value%
if "%p_key%" EQU "-lt" set license_type=%p_value%

shift
goto start_parse

:end_parse

rem Определяем структуру начальных каталогов и файлов сборки проекта

%extd% /lowercase %productname%

set lcase_productname=%result%
set rel_temp_dir=%rel_temp_dir%\%lcase_productname%
for /f %%i in ("%rel_temp_dir%") do Set abs_temp_dir=%%~dpni

set rel_build_dir=%rel_build_dir%\%lcase_productname%
for /f %%i in ("%rel_build_dir%") do Set abs_build_dir=%%~dpni

set build_file=%lcase_productname%_%build_file%
set ver_file=%lcase_productname%_version.txt
if not defined distrib_type set distrib_type=zip 
if not defined cmd_replace set cmd_replace=yes

Set company=Victory UMS
Set description=Пакет приложений веб-разработчика: Apache, MySQL, PHP, Zend Framework

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

Set fileversion=1.0.0.0

cd %~dp0

set release_build=false

if "%generate_release%" EQU "true" (
	if exist "%abs_build_dir%" goto release_build

	set release_build=true
	goto full_build
)

chgcolor 08 & echo ========================================
chgcolor 08 & echo | set /p "dummyName=Сборка проекта " & chgcolor 0E & echo %productname% v.%ma_version%.%mi_version%.%bi_version%.%bi_number%
chgcolor 08 & echo ========================================
echo.
chgcolor 0F & echo Выбор действия:
chgcolor 0F & echo 	1 - Перестроить проект полностью
chgcolor 0F & echo 	2 - Создать релиз проекта (%proc_arch%)
chgcolor 0F & echo 	3 - Избирательная сборка проекта (по умолчанию)
chgcolor 0F & echo 	4 - Создать архив файлов исходного кода проекта (GPL)
chgcolor 0F & echo 	5 - Выход
echo.

Choice /C 12345 /T 10 /D 3 /M "Что необходимо сделать"

if "%Errorlevel%" EQU "1" goto full_build
if "%Errorlevel%" EQU "2" goto release_build
if "%Errorlevel%" EQU "3" goto select_build
if "%Errorlevel%" EQU "4" goto source_build
if "%Errorlevel%" EQU "5" exit /b 1

:source_build
set source_build=true
goto select_build

:release_build
set release_build=true
goto select_build

:full_build
rem Если выбрана полная перестройка проекта
if exist "%abs_temp_dir%" 1>nul rd /S /Q "%abs_temp_dir%"
if exist "%abs_build_dir%" 1>nul rd /S /Q "%abs_build_dir%"

:select_build
rem Замер времени выполнения (http://stackoverflow.com/questions/739606/how-long-a-batch-file-takes-to-execute)
set STARTTIME=%TIME%
echo.
chgcolor 08 & echo | set /p "dummyName=Формирование файла сборки проекта (" & chgcolor 0F & echo | set /p "dummyName=%build_file%"
chgcolor 08 & echo | set /p "dummyName=)... "
rem http://www.computing.net/answers/programming/batch-file-to-clear-txt-file/12925.html
type nul > "%build_file%"

rem http://ss64.com/nt/forfiles.html
rem Для пакетных командных файлов
set cmd_build_mark=false
set cmd_compile_mark=false
FOR /f "tokens=1,2,3" %%a IN ('FORFILES /p "%rel_src_dir%" /m *.cmd /s /C "cmd /c echo @relpath @fdate @ftime"') DO (
	set src_file_path=%%~a
	set src_file_path=!src_file_path:~2!
	set build_file_path=!src_file_path:.cmd=.exe!
	set compile_mark=false

	rem http://superuser.com/questions/15214/command-line-batch-file-to-list-all-the-jar-files
	rem http://ss64.com/nt/syntax-args.html
	for %%i in ("%rel_src_dir%\!src_file_path!") do (
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
	if "!compile_mark!" EQU "true" echo exeicon.ico	!src_file_path!	%abs_build_dir%\!build_file_path!>>"%build_file%"
)
rem Для файлов автоматизации
FOR /f "tokens=1,2,3" %%a IN ('2^>nul FORFILES /p "%rel_src_dir%" /m *.au3 /s /C "cmd /c echo @relpath @fdate @ftime"') DO (
	set src_file_path=%%~a
	set src_file_path=!src_file_path:~2!
	set build_file_path=!src_file_path:.au3=.exe!
	set compile_mark=false

	for %%i in ("%rel_src_dir%\!src_file_path!") do (
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
	if "!compile_mark!" EQU "true" echo exe-icon.ico	!src_file_path!	%abs_build_dir%\!build_file_path!>>"%build_file%"
)

chgcolor 0A & echo Ok & echo.

if not exist "%abs_build_dir%" (
	chgcolor 08 & echo | set /p "dummyName=Создание структуры каталогов исполняемых файлов (" & chgcolor 0F & echo | set /p "dummyName=%abs_build_dir%"
	chgcolor 08 & echo | set /p "dummyName=)... "

	1>nul xcopy /E /EXCLUDE:%exclude_files% "%rel_src_dir%" "%abs_build_dir%"\
	chgcolor 0A & echo Ok & echo.
)

rem Копирование пакета во временную папку (синхронизация с обновлением по времени)
chgcolor 08 & echo | set /p "dummyName=Создание копии проекта во временном каталоге (" & chgcolor 0F & echo | set /p "dummyName=%abs_temp_dir%"
chgcolor 08 & echo | set /p "dummyName=)... "
rem xcopy /S ..\src\*.cmd temp\
1>nul Robocopy.exe "%rel_src_dir%" "%abs_temp_dir%" *.cmd *.au3 /s /COPY:DAT /PURGE /TIMFIX
chgcolor 0A & echo Ok & echo.

rem Читаем информацию об авторском праве (http://www.cyberforum.ru/cmd-bat/thread665872.html)
for /f "usebackq  delims=" %%i in (`find /n /v "" "GPL\Copyright.txt" ^| find "[1]"`) do (
    set copyright=%%i
)

set copyright=%copyright:~3%
Set productversion=%ma_version%.%mi_version%.%bi_version%.%bi_number%

rem Если были изменения в пакетных файлах
if "%cmd_compile_mark%" EQU "true" (
	rem http://code.google.com/p/win-iconv/
	rem http://hashcode.ru/questions/45585/%D0%BA%D0%BE%D0%B4%D0%B8%D1%80%D0%BE%D0%B2%D0%BA%D0%B0-%D0%BA%D0%B0%D0%BA-%D0%BA%D0%BE%D0%BD%D0%B2%D0%B5%D1%80%D1%82%D0%B8%D1%80%D0%BE%D0%B2%D0%B0%D1%82%D1%8C-%D0%B2%D1%81%D0%B5-%D1%84%D0%B0%D0%B9%D0%BB%D1%8B-%D0%B2-%D0%B4%D0%B8%D1%80%D0%B5%D0%BA%D1%82%D0%BE%D1%80%D0%B8%D0%B8-%D0%B8%D0%B7-windows-1251-%D0%B2-utf
	rem for /F "usebackq eol=; skip=1 tokens=1,2,3 delims=	" %%i in ("wamp_build.txt") do %utils_dir%\win_iconv.exe -t UTF-8 -f WINDOWS-1251 "temp\%%j" > "temp\%%j.txt"

	rem http://gnuwin32.sourceforge.net/packages/libiconv.htm
	rem for /F "usebackq eol=; skip=1 tokens=1,2,3 delims=	" %%i in ("wamp_build.txt") do %utils_dir%\libiconv\bin\iconv.exe -t UTF-8 -f WINDOWS-1251 "temp\%%j" > "temp\%%j.txt"

	chgcolor 08 & echo | set /p "dummyName=Предварительная обработка пакетных файлов... "
	for /F "usebackq eol=; tokens=1,2,3 delims=	" %%i in ("%build_file%") do (
		if "%%~xj" EQU ".cmd" %utils_dir%\uniconv\uniconv.exe cp1251 "%abs_temp_dir%\%%j" Unicode11:BOM:big-endian "%abs_temp_dir%\%%j-utf8.txt"
	)

	rem 1>nul del /S /Q "%abs_temp_dir%\*.cmd"
	rem если не отменено, то меняем все вызовы командных файлов и ссылки на них на соответствующие exe-файлы
	if NOT "%cmd_replace%" EQU "no" (
		%utils_dir%\fnr.exe --cl --dir "%abs_temp_dir%" --fileMask "*.txt"  --includeSubDirectories --find ".cmd" --replace ".exe"
	)

	rem добавляем сведения об авторском праве
	%utils_dir%\fnr.exe --cl --dir "%abs_temp_dir%" --fileMask "*.txt"  --includeSubDirectories --find "{Copyright}" --replace "%copyright%"

	rem добавляем сведения о дате построения проекта
	%utils_dir%\fnr.exe --cl --dir "%abs_temp_dir%" --fileMask "*.txt"  --includeSubDirectories --find "{Current_Date}" --replace "%DATE%"

	rem добавляем сведения о текущей версии проекта
	%utils_dir%\fnr.exe --cl --dir "%abs_temp_dir%" --fileMask "*.txt"  --includeSubDirectories --find "{Current_Version}" --replace "%productversion%"

	for /F "usebackq eol=; tokens=1,2,3 delims=	" %%i in ("%build_file%") do (
		if "%%~xj" EQU ".cmd" %utils_dir%\uniconv\uniconv.exe Unicode11:BOM:big-endian "%abs_temp_dir%\%%j-utf8.txt" cp1251 "%abs_temp_dir%\%%j-win1251.cmd"
	)

	chgcolor 0A & echo Ok & echo.


	rem for /F "usebackq eol=; skip=1 tokens=1,2,3 delims=	" %%i in ("wamp_build.txt") do %utils_dir%\libiconv\bin\iconv.exe -t WINDOWS-1251 -f UTF-8 "temp\%%j.txt" > "temp\%%j"
	rem for /F "usebackq eol=; skip=1 tokens=1,2,3 delims=	" %%i in ("wamp_build.txt") do %utils_dir%\win_iconv.exe -t WINDOWS-1251 -f UTF-8 "temp\%%j.txt" > "temp\%%j"

	chgcolor 08 & echo | set /p "dummyName=Удаление временных файлов... "
	1,2>nul del /S /Q "%abs_temp_dir%\*.txt"
	chgcolor 0A & echo Ok & echo.
)

rem Если была выбрана подготовка исходного кода согласно заданной лицензии 
if "%source_build%" EQU "true" (
	chgcolor 08 & echo | set /p "dummyName=Подготовка исходного кода проекта... "
	for /F "usebackq eol=; tokens=1,2,3 delims=	" %%i in ("%build_file%") do (
		if "%%~xj" EQU ".cmd" (
			%utils_dir%\uniconv\uniconv.exe cp1251 "%abs_temp_dir%\%%j" Unicode11:BOM:big-endian "%abs_temp_dir%\%%j-utf8.txt"

			1>nul copy /Y "GPL\License_cmd.txt" + "%abs_temp_dir%\%%j" "%abs_temp_dir%\%%j-src.cmd"
			%utils_dir%\uniconv\uniconv.exe cp1251 "%abs_temp_dir%\%%j-src.cmd" Unicode11:BOM:big-endian "%abs_temp_dir%\%%j-src-utf8.txt"
				
		)
	)

	%utils_dir%\fnr.exe --cl --dir "%abs_temp_dir%" --fileMask "*-src.cmd"  --includeSubDirectories --find "{Copyright}" --replace "%copyright%"

	%utils_dir%\fnr.exe --cl --dir "%abs_temp_dir%" --fileMask "*-src.cmd"  --includeSubDirectories --find "{Current_Date}" --replace "%DATE%"

	%utils_dir%\fnr.exe --cl --dir "%abs_temp_dir%" --fileMask "*-src.cmd"  --includeSubDirectories --find "{Current_Version}" --replace "%productversion%"
	%utils_dir%\uniconv\uniconv.exe Unicode11:BOM:big-endian "%abs_temp_dir%\%%j-src-utf8.txt" cp1251 "%abs_temp_dir%\%%j-src-win1251.cmd"

	chgcolor 0A & echo Ok & echo.
)

if not exist "%abs_build_dir%" (
	chgcolor 0С & echo Не найден каталог сборки проекта! Повторите сборку ещё раз...
	exit /b 2
)

chgcolor 08 & echo | set /p "dummyName=Обновление конфигурационных файлов проекта... "
1>nul Robocopy.exe "%rel_src_dir%" "%abs_build_dir%" *.cfg *.json /s /COPY:DAT /PURGE
chgcolor 0A & echo Ok & echo.

chgcolor 08 & echo | set /p "dummyName=Компиляция файлов сценариев в " & chgcolor 0F & echo | set /p "dummyName=%abs_build_dir%"
chgcolor 08 & echo :
rem "..\..\Bat_To_Exe_Converter\Windows (32 bit)\Bat_To_Exe_Converter.exe" -overwrite -bat "temp\setup.cmd" -save "%%k" -include "..\src\%utils_dir%\*.exe"

for /F "usebackq eol=; tokens=1,2,3 delims=	" %%i in ("%build_file%") do (
	chgcolor 08 & echo | set /p "dummyName= -  %%~nxj => " & chgcolor 0F & echo | set /p "dummyName=%%~nxk"
	chgcolor 08 & echo | set /p "dummyName=... "
	if exist "%%k" (
		1>nul del /Q "%%k"
	) else (
		1,2>nul del /Q "%%k"
	)
	rem  Компилируем в зависимости от типа файла
	set exec_builder_cli="%compiler_dir%\Bat_To_Exe_Converter.exe" -icon "icons\%%i" -bat "%abs_temp_dir%\%%j-win1251.cmd" -save "%%k" -overwrite -include "%chcolor%"
	if "%%~xj" EQU ".cmd" (
		rem если указан пароль
		if defined encrypt_pass set exec_builder_cli=!exec_builder_cli! -encrypt %encrypt_pass%
		!exec_builder_cli!	
		
	) else if "%%~xj" EQU ".au3" (
		if exist "%autoit_compiler%" (

			rem http://www.autoitscript.com/autoit3/docs/intro/compiler.htm
			"%autoit_compiler%" /in "%abs_temp_dir%\%%j" /out "%%k" /icon "icons\%%i" /%proc_arch% /console
		)
	)
	chgcolor 0A & echo Ok
)
echo.

if "%release_build%" == "true" (
	chgcolor 08 & echo | set /p "dummyName=Формирование релиза проекта версии " & chgcolor 0F & echo | set /p "dummyName=%productversion% %release_type% (%proc_arch%)"
	chgcolor 08 & echo | set /p "dummyName=... "
	if not "%release_type%" EQU "" (
		start "Формирование релиза %productname% v%productversion%..." /WAIT "%utils_dir%\7-zip\7z.exe" u -t%distrib_type% -mx9 -mmt=on -r -ssw ..\%lcase_productname%_%proc_arch%_v%productversion%-%release_type%.%distrib_type% -up1q0r2x1y2z1w2 -i@%lcase_productname%_%proc_arch%_inc_release.txt -xr@%lcase_productname%_%proc_arch%_exc_release.txt -scsUTF-8
	) else (
		start "Формирование релиза %productname% v%productversion%..." /WAIT "%utils_dir%\7-zip\7z.exe" u -t%distrib_type% -mx9 -mmt=on -r -ssw ..\%lcase_productname%_%proc_arch%_v%productversion%.%distrib_type% -up1q0r2x1y2z1w2 -i@%lcase_productname%_%proc_arch%_inc_release.txt -xr@%lcase_productname%_%proc_arch%_exc_release.txt -scsUTF-8
	)
	chgcolor 0A & echo Ok & echo.
)

set ENDTIME=%TIME%

rem Фиксация текущей версии проекта
type nul > "%ver_file%"
echo ma_version	"%ma_version%">>"%ver_file%"
echo mi_version	"%mi_version%">>"%ver_file%"
echo bi_number	"%bi_number%">>"%ver_file%"

rem формирование и вывод времени выполнения

chgcolor 08 & echo ========================================
rem output as time
chgcolor 08 & echo | set /p "dummyName=Начало выполнения в " & chgcolor 0F & echo %STARTTIME%
chgcolor 08 & echo | set /p "dummyName=Завершение выполнения в " & chgcolor 0F & echo %ENDTIME%

rem convert STARTTIME and ENDTIME to centiseconds
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
chgcolor 08 & echo | set /p "dummyName=Выполнено за " & chgcolor 0F & echo  | set /p "dummyName=%DURATION% "
chgcolor 08 & echo мс
rem echo %DURATIONH%:%DURATIONM%:%DURATIONS%,%DURATIONHS%

endlocal & exit /b 0

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
	Echo Ошибка формирования текущей даты.

GOTO:EOF

rem ---------------- EOF cfds.cmd ----------------