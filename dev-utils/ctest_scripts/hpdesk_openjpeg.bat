@rem update ourself:
cd C:/Dashboards/ctest_scripts && svn up

@rem Use Visual Studio 2010:
call "%VS100COMNTOOLS%vsvars32.bat"

@rem loop over all hpdesk-*x86.ctest files (nightly only)
@echo off
for %%f in (hpdesk-*nightly*x86.ctest) do ctest -S %%f -V -O %%f.log
