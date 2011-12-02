#!/bin/sh

cd $HOME/Dashboards/ctest_scripts && svn up

ctest -S macminig4-trunk-nightly-debug-linux_gcc41.ctest -V -O gcc41.log 
ctest -S macminig4-trunk-nightly-debug-linux_gcc43.ctest -V -O gcc43.log 
ctest -S macminig4-trunk-nightly-debug-linux_gcc44.ctest -V -O gcc44.log
