#!/bin/sh -x

cwd=`pwd`
cd /tmp

# Let's compare trunk ABI to tag 2.0
svn co http://openjpeg.googlecode.com/svn/tags/version.2.0 opj20
#svn co http://openjpeg.googlecode.com/svn/trunk opj21
svn co https://openjpeg.googlecode.com/svn/branches/openjpeg-2.0 opj21

export CFLAGS='-fvisibility=hidden'
for i in `ls -d /tmp/opj??`; do
  cd $i;
  mkdir -p bin && cd bin;
  cmake -DBUILD_CODEC:BOOL=OFF ..;
  DESTDIR=/tmp/install/`basename $i` make install;
done

# check
cd $cwd
#abi-compliance-checker -l openjpeg -d1 abi_openjpeg_2.0.xml -d2 abi_openjpeg_2.1.xml
abi-compliance-checker -l openjpeg -d1 abi_openjpeg_2.0.xml -d2 abi_openjpeg_2.0.1.xml
