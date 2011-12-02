#!/bin/sh

cd $HOME/Dashboards/ctest_scripts && svn up

ctest -S ks200451-trunk-nightly-debug-linux_gcc44.ctest -V -O gcc44.log
