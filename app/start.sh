#!/bin/sh
if [ -e /in -a -e /out ]; then 
    iwatch -e close_write -c "/app/handle-upload.sh %f" /in
else
    echo "Please bind '/in' and '/out' directory!"
fi

