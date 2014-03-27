#!/bin/sh

export LANG=C

# what is the last revision for 1.5
PREVREV=`svn info https://openjpeg.googlecode.com/svn/tags/version.2.0 | grep "Last Changed Rev" | cut -d: -f2| tr -d ' '`
# $ svn log   -v -r0:HEAD --stop-on-copy --limit 1 https://openjpeg.googlecode.com/svn/branches/openjpeg-1.5 
PREVREV=891
LASTREV=`svn info https://openjpeg.googlecode.com/svn/branches/openjpeg-2.0 | grep "Last Changed Rev" | cut -d: -f2| tr -d ' '`
# generate a changelog somewhat compatible with previous convention:
svn2cl --group-by-day --include-actions -o CHANGES -i -r $LASTREV:$PREVREV --authors authors.txt https://openjpeg.googlecode.com/svn/branches/openjpeg-2.0
