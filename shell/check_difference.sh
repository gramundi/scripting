#!/bin/bash

#This just to make a check beetwen the trunk and repo


now=$(date +%Y%m%d%H%M%S)

if [ $# -ne 2 ]; then
    echo $0: usage: myscript [path_to_app] [path_to_app]
    exit 1
fi

diff -qr $1 $2 | sort > awr_differences_$now.txt


#This will do the diff recursively and esclude some pattrens
#diff -qr app ./../../../public_html/appshare/awr-trunk/app/ -X exclude.pats | sort > awr_trunk_prod_differences.txt
