#!/bin/sh

# now run the dashboards:
cd $HOME/Dashboards/ctest_scripts && svn up

for i in `ls macminig4-*.ctest`; do
  ctest -S $i -V -O $i.log 
done
