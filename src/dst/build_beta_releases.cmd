@Echo Off
rem ������� ���������� ������������
1>nul del /Q ..\*beta*.zip
1>nul del /Q ..\*beta*.7z

rem ��������� ����� ������������
cmd /c build_bis_x64.cmd -gr:true -rt:beta
cmd /c build_bis_x86.cmd -gr:true -rt:beta
cmd /c build_oadf_x64.cmd -gr:true -rt:beta
cmd /c build_oadf_x86.cmd -gr:true -rt:beta
cmd /c build_wamp_x64.cmd -gr:true -rt:beta
cmd /c build_wamp_x86.cmd -gr:true -rt:beta
cmd /c build_wampz_x64.cmd -gr:true -rt:beta
cmd /c build_wampz_x86.cmd -gr:true -rt:beta