#!/bin/sh

. ./setenv.sh

MD="note.md"
mkdir release
cp bin/targets/qualcommax/ipq807x/openwrt-qualcommax-ipq807x-linksys_mx4300-* release/
cp bin/targets/qualcommax/ipq807x/openwrt-qualcommax-ipq807x-linksys_mx4300.manifest release/
cp bin/targets/qualcommax/ipq807x/openwrt-imagebuilder* release/
kernel=$(cat release/openwrt-qualcommax-ipq807x-linksys_mx4300.manifest | grep ^kernel)
checksum=$(sha256sum release/* | sed 's/release\///')
#echo $checksum

if grep -q "CONFIG_USE_APK=y" .config ; then
    errmsg="ERROR: unable to select packages"
    mdfile="foss-kmod-apk.md"
    warning="APK package manager"
    setenv pkg apk
else
    errmsg="pkg_hash_check_unresolved: cannot find dependency kernel"
    mdfile="foss-kmod-opkg.md"
    warning="OPKG package manager"
    setenv pkg opkg
fi

setenv build_id $(cat `find staging_dir -name banner` | grep OpenWrt | cut -d"," -f 2)

echo "- $warning

- $kernel

- sha256sum
\`\`\`
$checksum
\`\`\`" > $MD

if [ "$1" = "snapshot" ]; then
    echo "
- \"$errmsg\" [fix](https://github.com/${GITHUB_REPOSITORY}/blob/build/doc/$mdfile)" >> $MD
fi

