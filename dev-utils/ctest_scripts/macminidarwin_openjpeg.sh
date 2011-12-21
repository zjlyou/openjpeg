#!/bin/sh

cd $HOME/Dashboards/ctest_scripts && svn up

for i in `ls macminidarwin-*.ctest`; do
  ctest -S $i -V -O $i.log 
done
