#!/bin/bash

fullpath="$1"
filename=$(basename "$fullpath")
if ! [[ "$filename" =~ vpk|zip|rar|7z|gz|xz ]]; then
    # ignore it
    exit
fi

PURGE_VPK=/app/purge-vpk.sh
unar_tmp=$(mktemp -d -t unar-XXXX)
echo "------ Received file: $filename"
if [ ${filename: -3} == "vpk" ]; then
    $PURGE_VPK "$fullpath"
elif unar -q -o $unar_tmp "$fullpath"; then
    rm -rf "$fullpath"
    
    find $unar_tmp -name '*.vpk' | while read vpk_file
    do
        $PURGE_VPK "$vpk_file"
    done
else
    echo "Extracting failed. Invalid format or disk full"
fi

echo "------ done! ------"
rm -rf $unar_tmp "$fullpath"
