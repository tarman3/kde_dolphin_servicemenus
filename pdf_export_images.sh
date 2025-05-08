#!/bin/bash

utilities=('yad' 'pdfimages')
for utility in ${utilities[@]}; do
    if ! command -v "$utility" 2>&1 >/dev/null; then
        kdialog --title "$utility" --icon "error" --passivepopup "Not found" 3
        exit 1
    fi
done

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`kdialog --geometry 300x200 --title="Export images from PDF" \
    --inputbox "Pages number (1-3) or (5-) or (-3) or ( ) for all pages" ""`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

firstPage=${parameters%-*}
lastpage=${parameters##*-}
if [ -n "$firstPage" ]; then first="-f $firstPage"; fi
if [ -n "$lastPage" ]; then last="-f $lastPage"; fi


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Export images from PDF" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    dirExport="${file%.*}_images"
    pathExport="${dirExport}/img"

    mkdir -p "$dirExport"

    pdfimages $first $last -print-filenames -all -p "$file" "$pathExport"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Export images from PDF" --icon "checkbox" --passivepopup "Completed" 3
