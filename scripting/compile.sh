#!/bin/bash -e
SMSDK=../../alliedmodders/sourcemod
SPCOMP=spcomp

cd "$(dirname "$0")"

test -e compiled || mkdir compiled

if [[ $# -ne 0 ]]; then
  for sourcefile in "$@"
  do
    smxfile="`echo $sourcefile | sed -e 's/\.sp$/\.smx/'`"
    echo -e "\nCompiling $sourcefile..."
    $SPCOMP $sourcefile -iinclude -i$SMSDK/plugins/include -ocompiled/$smxfile
  done
else
  for sourcefile in *.sp
  do
    smxfile="`echo $sourcefile | sed -e 's/\.sp$/\.smx/'`"
    echo -e "\nCompiling $sourcefile ..."
    $SPCOMP $sourcefile -iinclude -i$SMSDK/plugins/include -ocompiled/$smxfile
  done
fi
