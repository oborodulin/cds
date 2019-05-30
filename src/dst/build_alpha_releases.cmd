@Echo Off
rem удаляем предыдущие дистрибутивы
1>nul del /Q ..\*alpha*.zip
1>nul del /Q ..\*alpha*.7z

rem формируем новые дистрибутивы
cmd /c build_bis_x64.cmd -gr:true -rt:alpha
cmd /c build_bis_x86.cmd -gr:true -rt:alpha
cmd /c build_oadf_x64.cmd -gr:true -rt:alpha
cmd /c build_oadf_x86.cmd -gr:true -rt:alpha
cmd /c build_wamp_x64.cmd -gr:true -rt:alpha
cmd /c build_wamp_x86.cmd -gr:true -rt:alpha
cmd /c build_wampz_x64.cmd -gr:true -rt:alpha
cmd /c build_wampz_x86.cmd -gr:true -rt:alpha