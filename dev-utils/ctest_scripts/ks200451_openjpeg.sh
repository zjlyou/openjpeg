#!/bin/sh

cd $HOME/Dashboards/ctest_scripts && svn up

for i in `ls ks200451-*nightly*.ctest`; do
  ctest -S $i -V -O $i.log 
done

# Prepare JPIP server:
# http://code.google.com/p/openjpeg/wiki/JPIP
cd $HOME/Dashboards/MyTests/openjpeg-b15-nightly-linux_gcc44-v1.5-debug
DESTDIR=$HOME/Dashboards/MyTests/jpip-install make install
cd $HOME/Dashboards/MyTests/jpip-install/usr/local/bin/
spawn-fcgi -f ./opj_server -p 3000 -n
GET http://localhost/myFCGI?quitJPIP
