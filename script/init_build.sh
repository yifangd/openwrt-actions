#!/bin/sh

type="foss"  #foss nss
ver="snapshot" #snapshot or release#
sync="n" #sync with latest??
tag="" #commit hash

[ ! -z $1 ] && type=$1
[ ! -z $2 ] && ver=$2
[ ! -z $3 ] && sync=$3
[ ! -z $4 ] && tag=$4

if [ $type = "foss" ]; then    
    #official MX4300 PR from testuser7
    #https://github.com/openwrt/openwrt/pull/16070
    PATCH="https://github.com/openwrt/openwrt/pull/16070.diff"
elif [ $type = "nss" ]; then
    #qosmio NSS patch
    #https://github.com/qosmio/openwrt-ipq
    case $ver in
        "snapshot")   
            PATCH="https://github.com/openwrt/openwrt/compare/main...qosmio:openwrt-ipq:main-nss-mx4300.diff"
            NSSBRANCH="main-nss-mx4300"
            ;;
        "24.10"*)
            PATCH="https://github.com/openwrt/openwrt/compare/openwrt-24.10...qosmio:openwrt-ipq:24.10-nss-mx4300.diff"
            NSSBRANCH="24.10-nss-mx4300"
            ;;
    esac
fi

[ -z $PATCH ] && echo "Unsupported $type $ver" && exit 1

if [ "$ver" = "snapshot" ]; then
  buildinfo="https://downloads.openwrt.org/snapshots/targets/qualcommax/ipq807x/version.buildinfo"
else
  buildinfo="https://downloads.openwrt.org/releases/$ver/targets/qualcommax/ipq807x/version.buildinfo"
fi

    
if [ ! -z $tag ]; then
    git reset --hard $tag
    sync="n"
fi    

if [ $sync = "y" ]; then
    #use published build version instead.
    git reset --hard $(wget $buildinfo -O - | cut -d '-' -f 2)
fi

echo $PATCH
curl -L $PATCH -o mx4300.diff
patch -p1 < mx4300.diff

#1. support both 24.10-snapshot and (tagged) release
#2. Handle package/firmware/ipq-wifi/Makefile in *possible* patch failure.
if [ $type = "nss" ]; then
  if [ -f "feeds.conf.default.rej" ]; then
    echo "##append qosmio's src-git to feeds.conf.default"
    curl -L "https://raw.githubusercontent.com/qosmio/openwrt-ipq/refs/heads/${NSSBRANCH}/feeds.conf.default" | grep qosmio >> feeds.conf.default
    rm feeds.conf.default.rej
    cat feeds.conf.default
  fi
  if [ -f "package/firmware/ipq-wifi/Makefile.rej" ]; then
    echo "##use package/firmware/ipq-wifi/Makefile from qosmio"
    curl -L https://raw.githubusercontent.com/qosmio/openwrt-ipq/refs/heads/${NSSBRANCH}/package/firmware/ipq-wifi/Makefile -o package/firmware/ipq-wifi/Makefile
    rm package/firmware/ipq-wifi/Makefile.rej
    #cat package/firmware/ipq-wifi/Makefile
  fi
fi

#err exit with unhandled failed patch
rej=$(find . -name "*.rej"  | wc -l)
if [ ! $rej = "0" ]; then
    exit 1
fi
