#!/bin/sh

# what is the last revision for 1.4
PREVREV=`svn info https://openjpeg.googlecode.com/svn/tags/version.1.4 | grep "Last Changed Rev" | cut -d: -f2| tr -d ' '`
PREVREV=697
LASTREV=`svn info https://openjpeg.googlecode.com/svn/branches/openjpeg-1.5 | grep "Last Changed Rev" | cut -d: -f2| tr -d ' '`
# generate a changelog somewhat compatible with previous convention:
svn2cl --group-by-day --include-actions -o CHANGES -i -r $LASTREV:$PREVREV --authors authors.txt https://openjpeg.googlecode.com/svn/branches/openjpeg-1.5
