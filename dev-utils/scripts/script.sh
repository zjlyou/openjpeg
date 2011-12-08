#!/bin/sh
# Convert a CDash HTML page into wiki formatting
# See: http://code.google.com/p/openjpeg/wiki/Release15

wget -O input.html "http://my.cdash.org/viewTest.php?onlyfailed&buildid=267948"
xsltproc --html process.xsl input.html > output.wiki
