#!/bin/sh
# Usage:
# ./script.sh "http://my.cdash.org/viewTest.php?onlyfailed&buildid=269778" table2.wiki  

# Convert a CDash HTML page into wiki formatting
# See: http://code.google.com/p/openjpeg/wiki/Release15
wget -O input.html "$1"
xsltproc --html process.xsl input.html > $2
