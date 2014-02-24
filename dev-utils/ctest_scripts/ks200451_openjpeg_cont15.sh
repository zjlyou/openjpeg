#!/bin/sh

cd $HOME/Dashboards/ctest_scripts && svn up

ctest -S ks200451-b15-continuous-debug-linux_gcc47.ctest -V -O cont_b15.log
