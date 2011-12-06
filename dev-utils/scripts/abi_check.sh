#!/bin/sh

cwd=`pwd`
cd /tmp

# Let's compare branch 1.5 ABI to tag 1.4
svn co http://openjpeg.googlecode.com/svn/tags/version.1.4 opj14
svn co http://openjpeg.googlecode.com/svn/branches/openjpeg-1.5 opj15

for i in `ls -d /tmp/opj??`; do
  cd $i;
  mkdir -p bin && cd bin;
  cmake -DBUILD_CODEC:BOOL=OFF ..;
  DESTDIR=/tmp/install/`basename $i` make install;
done

# check
cd $cwd
abi-compliance-checker -l openjpeg -d1 abi_openjpeg_1.4.xml -d2 abi_openjpeg_1.5.xml
