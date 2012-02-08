@rem generate OpenJPEG release on Windows

@rem get tmpdir:
set TMPDIR=%TMP%\openjpeg_release
@rem set TMPDIR=Z:\tmp\openjpeg_release

@rem use VCExpress 2005 for portability
call "%VS80COMNTOOLS%vsvars32.bat"

SET LIB=C:\Program Files\Microsoft SDKs\Windows\v7.1\Lib;%LIB%
SET LIB=C:\Program Files\Microsoft Platform SDK for Windows Server 2003 R2\Lib;%LIB%
SET INCLUDE=C:\Program Files\Microsoft SDKs\Windows\v7.1\Include;%INCLUDE%
SET INCLUDE=C:\Program Files\Microsoft Platform SDK for Windows Server 2003 R2\Include;%INCLUDE%
SET PATH=%PATH%;C:\Program Files/TortoiseSVN/bin/

mkdir %TMPDIR%
cd %TMPDIR%
svn checkout http://openjpeg.googlecode.com/svn/tags/version.1.5 openjpeg > svn.log 2>&1

mkdir %TMPDIR%\openjpeg-build
cd %TMPDIR%\openjpeg-build
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo -DBUILD_JPWL:BOOL=ON -DBUILD_MJ2:BOOL=ON -DBUILD_JPIP:BOOL=ON -DBUILD_THIRDPARTY:BOOL=ON ..\openjpeg > config.log 2>&1

@rem build gdcm
nmake > nmake.log 2>&1

@rem create NSIS installer
cpack -G NSIS > nsis.log 2>&1

@rem create binary zip
cpack -G ZIP > zip.log 2>&1

@rem create source zip
cpack -G ZIP --config CPackSourceConfig.cmake szip.log 2>&1
