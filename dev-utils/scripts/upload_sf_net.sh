#!/bin/sh -e

# Upload script, you need to hve build openjpeg first

# set -x

USER=malat,openjpeg.mirror

# decide to list all files already present (or not)
#rsync  "$USER@frs.sourceforge.net:/home/frs/project/o/op/openjpeg.mirror/"

files=$*

rsync -e ssh $files "$USER@frs.sourceforge.net:/home/frs/project/o/op/openjpeg.mirror/"
