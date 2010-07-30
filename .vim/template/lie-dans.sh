#!/bin/bash
#
# use with:  
#     find ../{doc,plugin} -name "searchIn*" -exec lie-dans.sh {} \;

rep=`dirname $1 |sed 's#.*/template\(.*\)#.\1/#g'`
# echo "`dirname $1` <-> $rep"
# echo cd `echo $1 | sed 's#\.\./\(.*\)/\(.*\)\.[^.]*$#\2/\1#'`
cd $rep
ln -s `echo $rep | sed 's#/[^/]\+#/..#g'`$1
