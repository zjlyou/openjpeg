@rem update ourself:
cd C:/Dashboards/ctest_scripts && svn up

setlocal
@rem Use Visual Studio 2010:
call "%VS100COMNTOOLS%vsvars32.bat"

@rem loop over all hpdesk-*x86.ctest files:
set ctestlist=
for %%a in ("hpdesk-*nightly*x86.ctest") do call :concat "%%a"
ctest -S %ctestlist% -V -O %ctestlist%.log
endlocal

goto :EOF
:concat
set ctestlist=%ctestlist% %1
goto :EOF
