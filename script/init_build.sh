#!/bin/sh

BUILD_TYPE="foss"  #foss nss
BUILD_VER="snapshot" #snapshot or release#

[ ! -z $1 ] && BUILD_TYPE=$1
[ ! -z $2 ] && BUILD_VER=$2

if [ $BUILD_TYPE = "foss" ]; then
    #use official PR from testuser7
    PATCH="https://github.com/openwrt/openwrt/pull/16070.diff"
else
    #my PR for qosmio NSS patch, may subject to change
    PATCH="https://github.com/arix00/openwrt-mx4300/pull/39.diff"
fi

wget $PATCH -O mx4300.diff
patch -p1 < mx4300.diff
