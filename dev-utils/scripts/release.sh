#!/bin/sh
#generate OpenJPEG release on *NIX
set -x

# get tmpdir:
TMPDIR=/tmp/openjpeg_release

mkdir -p $TMPDIR
cd $TMPDIR
svn checkout http://openjpeg.googlecode.com/svn/branches/openjpeg-1.5 openjpeg

isOSX="`uname -s | grep -i Darwin`"
osxVerFul=`system_profiler |grep 'System Version'| sed -e"s/^.*Mac OS X \([0-9.]*\) .*$/\1/"`
cmake_options="\
 -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
 -DBUILD_JPWL:BOOL=ON \
 -DBUILD_MJ2:BOOL=ON \
 -DBUILD_JPIP:BOOL=OFF \
 -DBUILD_THIRDPARTY:BOOL=ON \
 "
# CMAKE_OSX_DEPLOYMENT_TARGET:STRING=10.5
if [ "$isOSX" != "" ]; then
cmake_options="$cmake_options -DCMAKE_OSX_ARCHITECTURES:STRING=ppc;ppc64;i386;x86_64"
fi

mkdir $TMPDIR/openjpeg-build
cd $TMPDIR/openjpeg-build
cmake -G"Unix Makefiles" $cmake_options ../openjpeg > config.log 2>&1

# build openjpeg
make -j2 > make.log 2>&1

# create TGZ installer
cpack -G TGZ > tgz.log 2>&1

if [ "$isOSX" != "" ]; then
# create Bundle (MacOSX) installer
cpack -G Bundle > bundle.log 2>&1
fi

# create source zip
cpack -G TGZ --config CPackSourceConfig.cmake > s-tgz.log 2>&1

