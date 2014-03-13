#!/bin/sh

# now run the dashboards:
cd $HOME/Dashboards/ctest_scripts && svn up

# nightly
for i in `ls macminig4-*nightly*.ctest`; do
  ctest -S $i -V -O $i.log 
done
