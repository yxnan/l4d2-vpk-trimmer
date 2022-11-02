#!/bin/bash

VPK=/app/rvpk

vpk_tmp=$(mktemp -d -t vpk-XXXX)

vpk_src=$(realpath "$1")
vpk_name="$(basename "$vpk_src")"
vpk_src_canon="${vpk_src}_dir.vpk"
vpk_dist="/out/$vpk_name"
vpk_dist_canon="${vpk_dist}_dir.vpk"

clean_and_exit () {
    echo "$2"
    rm -rf $vpk_tmp
    exit $1
}

echo "> Processing $vpk_name"
mv "$vpk_src" "$vpk_src_canon"
$VPK unpack "$vpk_src_canon" -o "$vpk_tmp" || clean_and_exit 1 "! Vpk unpack failed, please intervene manually"
mv "$vpk_src_canon" "$vpk_src"

cd $vpk_tmp || exit 1
shopt -s extglob
eval 'rm -rf !( |maps|modes|missions|models|scripts|scenes|particles)'
find ' ' -type f -not -name 'addoninfo.txt' -delete
[ -e models ] && find models \( -name "*.vvd" -o -name "*.vtx" \) -exec rm {} +

if [ -e missions ]; then
    mission_file=$(ls missions/*.txt)
    campaign_name=$(basename -s .txt $mission_file)
fi

$VPK pack -V 1 "$vpk_dist_canon" "$vpk_tmp"
mv "$vpk_dist_canon" "$vpk_dist"

if [ -e "$vpk_dist" ]; then
    vpk_oldsize="$(ls -lh "$vpk_src" | tr -s ' ' | cut -d' ' -f5)"
    vpk_size="$(ls -lh "$vpk_dist" | tr -s ' ' | cut -d' ' -f5)"
    [ -z "$campaign_name" ] || echo "  Campaign installed: $campaign_name"
    clean_and_exit 0 "  Size: $vpk_oldsize -> $vpk_size"
else
    clean_and_exit 1 "  Failed. Can't write to output directory"
fi

