#!/bin/sh

cd $HOME/Dashboards/ctest_scripts && svn up

for i in `ls ks200451-*.ctest`; do
  ctest -S $i -V -O $i.log 
done
