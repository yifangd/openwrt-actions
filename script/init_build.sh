#!/bin/sh

BUILD_TYPE="foss"  #foss nss
BUILD_VER="snapshot" #snapshot or release#

[ ! -z $1 ] && BUILD_TYPE=$1
[ ! -z $2 ] && BUILD_VER=$2

if [ $BUILD_TYPE = "foss" ]; then
    PR=38
else
    PR=39
fi

PATCH="https://patch-diff.githubusercontent.com/raw/arix00/openwrt-mx4300/pull/${PR}.diff"

wget $PATCH -O mx4300.diff

patch -p1 < mx4300.diff
