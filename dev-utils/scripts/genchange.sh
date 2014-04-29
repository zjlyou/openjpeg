#!/bin/sh

export LANG=C

# For more info on creating branch 2.0 and tag 2.0, see:
# https://code.google.com/p/openjpeg/source/detail?r=2230

# what is the last revision for 1.5
PREVREV=`svn info https://openjpeg.googlecode.com/svn/tags/version.2.0 | grep "Last Changed Rev" | cut -d: -f2| tr -d ' '`
# $ svn log   -v -r0:HEAD --stop-on-copy --limit 1 https://openjpeg.googlecode.com/svn/branches/openjpeg-1.5 
PREVREV=2230
LASTREV=`svn info https://openjpeg.googlecode.com/svn/branches/openjpeg-2.1 | grep "Last Changed Rev" | cut -d: -f2| tr -d ' '`
# generate a changelog somewhat compatible with previous convention:
svn2cl --group-by-day --include-actions -o CHANGES -i -r $LASTREV:$PREVREV --authors authors.txt https://openjpeg.googlecode.com/svn/branches/openjpeg-2.1
