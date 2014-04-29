@rem generate OpenJPEG release on Windows

@rem should I build only Part-1 ?
set PART1ONLY=false

if %PART1ONLY%==false set cmake_extra_options=-DBUILD_JPWL:BOOL=ON -DBUILD_MJ2:BOOL=ON -DBUILD_JPIP:BOOL=ON -DBUILD_THIRDPARTY:BOOL=ON

@rem get tmpdir:
set TMPDIR=%TMP%\openjpeg_release
@rem set TMPDIR=Z:\tmp\openjpeg_release

@rem use VCExpress 2005 for portability
call "%VS80COMNTOOLS%vsvars32.bat"

@rem User32.lib and al.
SET LIB=C:\Program Files\Microsoft SDKs\Windows\v6.0A\Lib;%LIB%
SET INCLUDE=C:\Program Files\Microsoft SDKs\Windows\v6.0A\Include;%INCLUDE%
@rem Another version:
SET LIB=C:\Program Files\Microsoft SDKs\Windows\v7.1\Lib;%LIB%
SET INCLUDE=C:\Program Files\Microsoft SDKs\Windows\v7.1\Include;%INCLUDE%
@rem Another version:
SET LIB=C:\Program Files\Microsoft Platform SDK for Windows Server 2003 R2\Lib;%LIB%
SET INCLUDE=C:\Program Files\Microsoft Platform SDK for Windows Server 2003 R2\Include;%INCLUDE%

@rem add svn to PATH
@rem When installing TortoiseSVN, you need to specifically install cmd line tools:
SET PATH=%PATH%;C:\Program Files\TortoiseSVN\bin

mkdir %TMPDIR%
cd %TMPDIR%
svn checkout -q http://openjpeg.googlecode.com/svn/tags/version.2.1 openjpeg > svn.log 2>&1

mkdir %TMPDIR%\openjpeg-build
cd %TMPDIR%\openjpeg-build
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo %cmake_extra_options% -DBUILD_THIRDPARTY:BOOL=ON ..\openjpeg > config.log 2>&1

@rem build gdcm
nmake > nmake.log 2>&1

@rem create NSIS installer
cpack -G NSIS > nsis.log 2>&1

@rem create binary zip
cpack -G ZIP > zip.log 2>&1

@rem create source zip
cpack -G ZIP --config CPackSourceConfig.cmake szip.log 2>&1
