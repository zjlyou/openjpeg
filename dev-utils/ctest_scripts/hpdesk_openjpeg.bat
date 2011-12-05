@rem Use Visual Studio 2010:
call "%VS100COMNTOOLS%vsvars32.bat"


cd $HOME/Dashboards/ctest_scripts && svn up

@rem loop over all hpdesk-*.ctest files:
set ctestlist=
for %%a in ("hpdesk-*.ctest") do call :concat "%%a"
ctest -S %ctestlist% -V -O %ctestlist%.log

goto :EOF
:concat
set ctestlist=%ctestlist% %1
goto :EOF
