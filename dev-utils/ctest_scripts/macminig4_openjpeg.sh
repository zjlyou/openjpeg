#!/bin/sh

cd $HOME/Dashboards/ctest_scripts && svn up

for i in `ls macminig4-*.ctest`; do
  ctest -S $i -V -O $i.log 
done

# Update git clone on github:
cd $HOME/Dashboards/git/trunk
git svn rebase
git push --mirror mathieu
