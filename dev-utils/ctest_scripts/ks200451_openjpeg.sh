#!/bin/sh
set -x

# Prepare JPIP server from yesterday builds:
# http://code.google.com/p/openjpeg/wiki/JPIP
cd $HOME/Dashboards/MyTests/openjpeg-b15-nightly-linux_gcc44-v1.5-debug
DESTDIR=/tmp/jpip-install make install
cd /tmp/jpip-install/usr/local/bin/
# get some data
wget -c http://www.openjpeg.org/jpip/data/16.jp2
# start server:
spawn-fcgi -f ./opj_server -p 3000

cd $HOME/Dashboards/ctest_scripts && svn up

# nightly
for i in `ls ks200451-*nightly*.ctest`; do
  ctest -S $i -V -O $i.log 
done

# exp
for i in `ls ks200451-*experimental*.ctest`; do
  ctest -S $i -V -O $i.log 
done

# close server
GET http://localhost/myFCGI?quitJPIP
