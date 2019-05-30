@Echo Off
rem {Copyright}
rem {License}
rem �������� ��������� ������ ���������� ���������� ������� OHW � Adf-����������� �������� ViewController
rem ���������:
rem	������� �������	Adf-��������� (jar)	: %1
rem	��������� ������� (temp)		: %2
rem	�������������� ����� (env)		: %4 (dev/test/prod)

setlocal EnableExtensions EnableDelayedExpansion
cls
1>nul chcp 1251
set module_name=%~nx0

rem ������ ���������� �������
rem ��������� ���������� � �����, �� �����������, ���������� ������ ���
:start_parse
set p_param=%~1
set p_key=%p_param:~0,3%
set p_value=%p_param:~4%

if "%p_param%" EQU "" goto end_parse

if "%p_key%" EQU "-ld" set adflib_dir=%p_value%
if "%p_key%" EQU "-td" set temp_dir=%p_value%
if "%p_key%" EQU "-en" set environment=%p_value%

shift
goto start_parse

:end_parse

chgcolor 08 & echo Victory ADF: Replace OHW baseURI {Current_Version}. {Copyright} {Current_Date}

if "%adflib_dir%" EQU "" call :exec_format %module_name% & endlocal & exit /b 1
if "%temp_dir%" EQU "" call :exec_format %module_name% & endlocal & exit /b 1
if "%environment%" EQU "" call :exec_format %module_name% & endlocal & exit /b 1

rem �������� �� ���������
rem ���� OHW ��� ���������� � �������������� ���������������� WebLogic
set OHW_base_URI_DEF=localhost:7101
set OHW_base_URI_DEV=sak-testwls01:7001
set OHW_base_URI_TEST=sak-testwls02:7001
set OHW_base_URI_PROD=sak-weblogic01:7001

rem ���������� ���� 
if "%environment%" EQU "dev" (
	set new_OHW_base_URI=%OHW_base_URI_DEV%
) else if "%environment%" EQU "test" (
	set new_OHW_base_URI=%OHW_base_URI_TEST%
) else if "%environment%" EQU "prod" (
	set new_OHW_base_URI=%OHW_base_URI_PROD%
)

rem � ���������� ���� � ���������
for /f %%i in ("%adflib_dir%") do Set adflib_dir=%%~dpni
if not exist "%adflib_dir%" (
	chgcolor 0C & echo error
	chgcolor 0C & echo ������� Adf-��������� �� ������! ���������, ����������, ��������� ������� �������.
	exit
)
for /f %%i in ("%temp_dir%") do Set temp_dir=%%~dpni

rem ��������� ��������:
rem Adf-���������
set tmp_adflib_dir=%temp_dir%\adflib
rem ����� ��������� (��������� ��� ����������� jar)
set tmp_manifest_dir=%temp_dir%\adflib\manifest

rem �������:
set jar=jar.exe
set svn="C:\Program Files\TortoiseSVN\bin\TortoiseProc.exe"

rem ���� ������� ��������� �������� �������� Adf-���������
set last_time_check_file=%temp_dir%\%environment%_last_time_check.tmp

echo.
chgcolor 08 & echo | set /p "dummyName=���������: " & chgcolor 0F & echo %environment%
chgcolor 08 & echo | set /p "dummyName=������� Adf-���������: " & chgcolor 0F & echo %adflib_dir%
chgcolor 08 & echo | set /p "dummyName=��������� �������: " & chgcolor 0F & echo %temp_dir%
chgcolor 08 & echo | set /p "dummyName=���� �� ���������: " & chgcolor 0F & echo %OHW_base_URI_DEF%
chgcolor 08 & echo | set /p "dummyName=���� ���������: " & chgcolor 0F & echo %new_OHW_base_URI%
chgcolor 08 & echo | set /p "dummyName=���� ��������� ����� �������: " & chgcolor 0F & echo %last_time_check_file%
echo.

rem �������� ���������� �������� ����� ���������
if not exist "%tmp_manifest_dir%" 1>nul MD "%tmp_manifest_dir%"

rem �������� ��������� ����� �������
if exist "%last_time_check_file%" (
	for /F "usebackq tokens=* delims=," %%n in ("%last_time_check_file%") do set last_time=%%n
	call :date_to_int last_int_time "!last_time!"
) else (
	set last_time=� ������ ���
	set last_int_time=0
)

chgcolor 08 & echo | set /p "dummyName=��������� ������ ����� ���������: " & chgcolor 0F & echo %last_time%

rem ��������� �������� ������� Adf-���������
echo.
chgcolor 0F & echo | set /p "dummyName=SVN: ���������� �������� Adf-���������... "
if exist %svn% (
	pushd %adflib_dir%
	%svn% /command:update /path:"%adflib_dir%\*" /closeonend:1
	popd
	chgcolor 0A & echo Ok
) else (
	chgcolor 0C & echo error
	chgcolor 0C & echo SVN: ������� Adf-��������� �� ������� - �� ������ SVN-������. ��������, ��� ������� ��������� ���������� ��������������.
)

rem ���� �� ������� �������� ViewController � �������� �������� Adf-��������� �������������� ����� (dev/test/prod)
echo.
chgcolor 08 & echo | set /p "dummyName=Adf-���������� �������� ViewController (" & chgcolor 0F & echo | set /p "dummyName=%adflib_dir%" & chgcolor 08 & echo )
chgcolor 08 & echo -----------------------------------------------------------
FOR /f "tokens=1,2" %%a IN ('2^>nul FORFILES /p %adflib_dir% /m "*-View.jar" /C "cmd /c echo @file @fdate_@ftime"') DO (
	set adflib_file=%%~a
	set adflib_time=%%~b
	rem �� ������� �������� _ �� ������ (��� �������������)
  	set adflib_time=!adflib_time:_= !
	                   
	rem �������� �������� ����� �������
	call :date_to_int adflib_int_time "!adflib_time!"

	chgcolor 0F & echo | set /p "dummyName=!adflib_file!	!adflib_time! (!adflib_int_time!)... "

	rem ���� Adf-���������� ���� �������� ����� ��������� ������ ����� � �������

	if %last_int_time% LSS !adflib_int_time! (
		
		rem �������� � ������� �� ��������� ������� Adf-����������
		for /f %%i in ("!adflib_file!") do Set adflib_name=%%~ni
		if not exist "%tmp_adflib_dir%\!adflib_name!" 1>nul MD "%tmp_adflib_dir%\!adflib_name!"

		pushd %tmp_adflib_dir%\!adflib_name!

		rem ���������� ����� META-INF\adf-settings.xml � ���������
		rem %zip% x %adflib_dir%\!adflib_file! -o%tmp_adflib_dir%\!adflib_name! -i@ohw_extract.txt -aoa
	
		rem ���������� ������ ����������
		%jar% xvf %adflib_dir%\!adflib_file! 2>nul
		rem pause
		rem ������� ����� ��������� �� ��������� �������
		if exist "%tmp_adflib_dir%\!adflib_name!\META-INF\MANIFEST.MF" (
			1>nul move /y %tmp_adflib_dir%\!adflib_name!\META-INF\MANIFEST.MF %tmp_manifest_dir%\MANIFEST.MF
                )
		rem pause
		rem ������ ����� �� ��������� ����������� ���������� ������ �������� �������� �������������� ����� (dev/test/prod)
		%b2eincfilepath%\fnr.exe --cl --dir "%tmp_adflib_dir%\!adflib_name!\META-INF" --fileMask "*.xml" --find "%OHW_base_URI_DEF%" --replace "%new_OHW_base_URI%"
		
		rem ���� ��������� dev ��� prod, �� ��� ������ ���� ������� ���������� �� ������������ � �������
		if "%environment%" EQU "dev" (
			%b2eincfilepath%\fnr.exe --cl --dir "%tmp_adflib_dir%\!adflib_name!\META-INF" --fileMask "*.xml" --find "%OHW_base_URI_PROD%" --replace "%new_OHW_base_URI%"
		) else if "%environment%" EQU "prod" (
			%b2eincfilepath%\fnr.exe --cl --dir "%tmp_adflib_dir%\!adflib_name!\META-INF" --fileMask "*.xml" --find "%OHW_base_URI_DEV%" --replace "%new_OHW_base_URI%"
		) else if "%environment%" EQU "test" (
			%b2eincfilepath%\fnr.exe --cl --dir "%tmp_adflib_dir%\!adflib_name!\META-INF" --fileMask "*.xml" --find "%OHW_base_URI_DEV%" --replace "%new_OHW_base_URI%"
		)

		rem pause
		rem ��������� �������
		rem %zip% u -tzip %adflib_dir%\!adflib_file! %tmp_adflib_dir%\!adflib_name!\* -mx0
		
		rem ����������� ������ Adf-���������� (http://grep.codeconsult.ch/2011/11/15/manifest-mf-must-be-the-first-resource-in-a-jar-file-heres-how-to-fix-broken-jars/)
		if exist "%tmp_manifest_dir%\MANIFEST.MF" (
			%jar% cvf0m %adflib_dir%\!adflib_file! %tmp_manifest_dir%\MANIFEST.MF . 2>nul
		) else (
			%jar% cvf0M %adflib_dir%\!adflib_file! . 2>nul
		)

		rem pause
		rem ������� �� ���������� �������� Adf-���������� � ������� ���, � ��� �� ���� ���������
		popd
		1>nul RD /S /Q "%tmp_adflib_dir%\!adflib_name!"
		if exist "%tmp_manifest_dir%\MANIFEST.MF" 1>nul del /Q "%tmp_manifest_dir%\MANIFEST.MF"
		rem pause
		chgcolor 0A & echo Ok	
	) else (
		chgcolor 0A & echo pass	
	)
)
chgcolor 08 & echo -----------------------------------------------------------

rem ��������� ����� ���������� ������ ����� �� ��������� ���������
type nul > "%last_time_check_file%"
echo %date% %time%>>"%last_time_check_file%"

rem ��������� ��������� � �������� Adf-���������
echo.
chgcolor 0F & echo | set /p "dummyName=SVN: �������� ��������� � �������� Adf-���������... "

if not exist %svn% goto svn_client_notfound

rem pushd %adflib_dir%
start "SVN: �������� ��������� � �������� Adf-���������" %svn% /command:commit /path:"%adflib_dir%\*" /logmsg:"�������� ����� ���������� ���������� ������� �������� ��������� (%environment%)" /closeonend:1
rem popd
chgcolor 0A & echo Ok
endlocal & exit /b 0

:svn_client_notfound
chgcolor 0C & echo error
chgcolor 0C & echo SVN: ��������� ������� � �������� Adf-��������� (%adflib_dir%) �� ������������� - �� ������ SVN-������. ��������, ��� ������� ��������� �������� ��������������.
endlocal & exit /b 2

rem ==========================================================================
rem ��������� exec_format - ������ ������� ������� �������
rem ==========================================================================
:exec_format
echo.
chgcolor 08 & echo ������ ������� �������:
chgcolor 08 & echo %~nx1 [^<�����^>...]
echo.
chgcolor 08 & echo �����:
chgcolor 0B & echo | set /p "dummyName=   -ld" & chgcolor 0F & echo :(�����������) ������� ������� Adf-��������� �������� ViewController (*-View.jar)
chgcolor 0B & echo | set /p "dummyName=   -td" & chgcolor 0F & echo :(�����������) ��������� �������
chgcolor 0B & echo | set /p "dummyName=   -en" & chgcolor 0F & echo :(�����������) ��������� [dev/test/prod]
exit /b 0

rem http://www.cyberforum.ru/cmd-bat/thread613576.html
:date_to_int 
set tmp.result=%~2

rem �������� �������� ���� � �����
set hours=%tmp.result:~11,2%
set minutes=%tmp.result:~14,2%
if "%tmp.result:~11,1%" EQU " " set hours=0%tmp.result:~12,1%
rem ���� ��� ����� ��-�� ����� �� 1 ������ �����
if "%tmp.result:~12,1%" EQU ":" (
	set hours=0%tmp.result:~11,1%
	set minutes=%tmp.result:~13,2%
)

set /a %1=%tmp.result:~8,2%%tmp.result:~3,2%%tmp.result:~0,2%%hours%%minutes%
exit /b 0

rem ---------------- EOF owh.cmd ----------------