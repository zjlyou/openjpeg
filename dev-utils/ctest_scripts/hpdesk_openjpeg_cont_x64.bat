@rem update ourself:
cd C:/Dashboards/ctest_scripts && svn up

@rem Use Visual Studio 2010 for x64
call "c:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\vcvarsall.bat" amd64

ctest -S hpdesk-b15-continuous-debug-win7_vs2010_x64.ctest -V -O cont_b15_x64.log
