@Echo Off
cmd /c build_bis_x64.cmd -gr:true
cmd /c build_bis_x86.cmd -gr:true
cmd /c build_oadf_x64.cmd -gr:true
cmd /c build_oadf_x86.cmd -gr:true
cmd /c build_wamp_x64.cmd -gr:true
cmd /c build_wamp_x86.cmd -gr:true
cmd /c build_wampz_x64.cmd -gr:true
cmd /c build_wampz_x86.cmd -gr:true