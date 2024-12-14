#!/bin/bash

# https://milan.kupcevic.net/ghostscript-ps-pdf/

utilities=('yad' 'gs')
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

parameters=`yad --borders=10 --width=400 --height=210 --title="Compress PDF" \
    --list --column=Type --column=Description \
    screen "Screen-view-only quality, 72 dpi" \
    ebook "Low quality, 150 dpi" \
    printer "High quality, 300 dpi" \
    prepress "High quality, color preserving, 300 dpi"`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

preset=$( echo $parameters | awk -F '|' '{print $1}')


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Compress PDF" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    gs -dNOPAUSE  -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/$preset -sOutputFile="${file%.*}-$preset.pdf" "$file"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "PDF Compress" --icon "checkbox" --passivepopup "Completed" 3
