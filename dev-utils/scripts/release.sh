#!/bin/sh
#generate OpenJPEG release on *NIX

# get tmpdir:
TMPDIR=/tmp/openjpeg_release

mkdir -p $TMPDIR
cd $TMPDIR
svn checkout http://openjpeg.googlecode.com/svn/branches/openjpeg-1.5 openjpeg

mkdir $TMPDIR/openjpeg-build
cd $TMPDIR/openjpeg-build
cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo ../openjpeg > config.log 2>&1

# build openjpeg
make -j2 > make.log 2>&1

# create NSIS installer
cpack -G TGZ > tgz.log 2>&1

# create source zip
cpack -G TGZ --config CPackSourceConfig.cmake > s-tgz.log 2>&1

