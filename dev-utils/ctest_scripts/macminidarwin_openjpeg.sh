#!/bin/sh

cd $HOME/Dashboards/ctest_scripts && svn up

#export MACOSX_DEPLOYMENT_TARGET=10.4

for i in `ls macminidarwin-*.ctest`; do
  ctest -S $i -V -O $i.log 
done
