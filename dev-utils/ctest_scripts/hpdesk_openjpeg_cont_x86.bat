@rem update ourself:
cd C:/Dashboards/ctest_scripts && svn up

@rem Use Visual Studio 2010:
call "%VS100COMNTOOLS%vsvars32.bat"

ctest -S hpdesk-trunk-continuous-debug-win7_vs2010_x86.ctest -V -O cont_trunk_x86.log
