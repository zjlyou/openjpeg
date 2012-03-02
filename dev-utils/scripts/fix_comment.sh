#!/bin/sh
# MM: I am required to use gcc -pedantic flag to detect declaration and code mix (C90) which VS does not support
# however as soon as I activate -pedantic I get pollution from warning about C++ style comment
# this script fixes those
sed -i -e "s?//\(.*\)?/*\1 */?" $1
