#!/bin/bash -e
cd "$(dirname "$0")"

SMSDK=../../alliedmodders/sourcemod
SPCOMP=spcomp

###
### You shouldn't need to edit below this line.
###
git_count() {
  git rev-list --all --count
}

VERSION=`cat VERSION`
MAJOR=`echo $VERSION | cut -d. -f1`
MINOR=`echo $VERSION | cut -d. -f2`
REVISION=`echo $VERSION | cut -d. -f3`
BUILD_STRING="git$(git_count)"
eval "echo \"$(cat include/nyxtools_version.tpl)\"" > include/nyxtools_version.inc

test -e compiled || mkdir compiled

if [[ $# -ne 0 ]]; then
  for sourcefile in "$@"
  do
    smxfile="`echo $sourcefile | sed -e 's/\.sp$/\.smx/'`"
    echo -e "\nCompiling $sourcefile..."
    $SPCOMP $sourcefile -iinclude -i$SMSDK/plugins/include -ocompiled/$smxfile -E
  done
else
  for sourcefile in *.sp
  do
    smxfile="`echo $sourcefile | sed -e 's/\.sp$/\.smx/'`"
    echo -e "\nCompiling $sourcefile ..."
    $SPCOMP $sourcefile -iinclude -i$SMSDK/plugins/include -ocompiled/$smxfile -E
  done
fi
