#!/bin/bash
cd "$(dirname "$0")"

SMSDK=../../alliedmodders/sourcemod
SPCOMP=spcomp

test -e compiled || mkdir compiled

if [[ $# -ne 0 ]]; then
  for i in "$@";
  do
    smxfile="`echo $i | sed -e 's/\.sp$/\.smx/'`";
    echo -e "Compiling $i...";
    $SPCOMP $i -iinclude -i$SMSDK/plugins/include -ocompiled/$smxfile
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
      exit 1;
    fi
  done
else
  for sourcefile in *.sp
  do
    smxfile="`echo $sourcefile | sed -e 's/\.sp$/\.smx/'`"
    echo -e "Compiling $sourcefile ..."
    $SPCOMP $sourcefile -iinclude -i$SMSDK/plugins/include -ocompiled/$smxfile
    RETVAL=$?
    if [ $RETVAL -ne 0 ]; then
      exit 1;
    fi
  done
fi
