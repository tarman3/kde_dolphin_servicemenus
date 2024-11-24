#!/bin/bash

# https://milan.kupcevic.net/ghostscript-ps-pdf/

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

# parameters=`yad --borders=10 --width=300 --title="Compress PDF" --text-align=center \
#     --form --item-separator="|" --separator="," --field="Language:CB" "^screen|ebook|printer|prepress"`

parameters=`yad --borders=10 --width=400 --height=210 --title="Compress PDF" --list --column=Type --column=Description \
    screen "Screen-view-only quality, 72 dpi" \
    ebook "Low quality, 150 dpi" \
    printer "High quality, 300 dpi" \
    prepress "High quality, color preserving, 300 dpi"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

# preset=$( echo $parameters | awk -F ',' '{print $1}')
preset=$( echo $parameters | awk -F '|' '{print $1}')

numberFiles=${#array[@]}
dbusRef=`kdialog --title "Compress PDF" --progressbar "" $numberFiles`

for file in "${array[@]}"; do

    gs -dNOPAUSE  -dBATCH -sDEVICE=pdfwrite -dPDFSETTINGS=/$preset -sOutputFile="${file%.*}-$preset.pdf" "$file"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"

done

qdbus $dbusRef close

kdialog --title "PDF Compress" --icon "checkbox" --passivepopup "Completed" 3
