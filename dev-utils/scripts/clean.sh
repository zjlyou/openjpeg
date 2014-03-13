#!/bin/sh

#uncrustify  -c opj.cfg --no-backup --replace $1
# remove tabs
#sed -e 's/\t/  /g' $1 | uncrustify -o $1.bla -l c -c opj.cfg
sed -e 's/\t/  /g' $1 | uncrustify -o $1 -l c -c opj.cfg
