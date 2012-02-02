#!/bin/sh
#generate OpenJPEG release on *NIX (both Linux and MacOSX)
set -x

# get tmpdir:
TMPDIR=/tmp/openjpeg_release

isOSX="`uname -s | grep -i Darwin`"
if [ "$isOSX" != "" ]; then
osxVerFul=`system_profiler |grep 'System Version'| sed -e"s/^.*Mac OS X \([0-9.]*\) .*$/\1/"`
osxVerMajMin="`echo $osxVerFul | cut -d. -f1-2`"
fi

mkdir -p $TMPDIR
cd $TMPDIR
svn checkout http://openjpeg.googlecode.com/svn/branches/openjpeg-1.5 openjpeg
cd openjpeg
./bootstrap.sh

# Now is a good time to generate offline Changelog:
# what is the last revision for 1.4
PREVREV=`svn info https://openjpeg.googlecode.com/svn/tags/version.1.4 | grep "Last Changed Rev" | cut -d: -f2| tr -d ' '`
LASTREV=`svn info https://openjpeg.googlecode.com/svn/branches/openjpeg-1.5 | grep "Last Changed Rev" | cut -d: -f2| tr -d ' '`
# generate a changelog somewhat compatible with previous convention:
svn2cl --group-by-day --include-actions -o CHANGES -i -r $LASTREV:$PREVREV --authors authors.txt https://openjpeg.googlecode.com/svn/branches/openjpeg-1.5
cd ..

cmake_options="\
 -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo \
 -DBUILD_JPWL:BOOL=ON \
 -DBUILD_MJ2:BOOL=ON \
 -DBUILD_JPIP:BOOL=ON \
 -DBUILD_THIRDPARTY:BOOL=ON \
 "
# On apple let's build universal binaries
if [ "$isOSX" != "" ]; then
if [ "$osxVerMajMin" = "10.4" ]; then
cmake_options="$cmake_options -DCMAKE_OSX_ARCHITECTURES:STRING=ppc;i386 -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=10.4"
elif [ "$osxVerMajMin" = "10.7" ]; then
cmake_options="$cmake_options -DCMAKE_OSX_ARCHITECTURES:STRING=i386;x86_64 -DCMAKE_OSX_DEPLOYMENT_TARGET:STRING=10.6"
fi
fi

mkdir $TMPDIR/openjpeg-build
cd $TMPDIR/openjpeg-build
cmake -G"Unix Makefiles" $cmake_options ../openjpeg > config.log 2>&1

# build openjpeg
make -j2 > make.log 2>&1

# create TGZ installer
cpack -G TGZ > tgz.log 2>&1

if [ "$isOSX" != "" ]; then
# PackageMaker
cpack -G PackageMaker > packagemaker.log 2>&1
fi

# create source zip
cpack -G TGZ --config CPackSourceConfig.cmake > s-tgz.log 2>&1

