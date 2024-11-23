#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=500 --title="Change images resolution" \
    --text-align=left --item-separator="|" --separator="," --form \
    --field="800 - Resize to 800 px width (keep aspect ratio):LBL" \
    --field="x600 - Resize to 600 px height (keep aspect ratio):LBL" \
    --field="800x600 - Resize with keep aspect ratio:LBL" \
    --field="100×50! - Resize without keep aspect ratio:LBL" \
    --field=" :LBL"    --field="Resolution" --field=" :LBL" --field="Add sufix to name:CHK" --field="Dir to save:DIR" \
        "" "" "" "" ""        "1368"                ""              "TRUE"                          "$path"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

resolution=$( echo $parameters | awk -F ',' '{print $6}')
sufix=$( echo $parameters | awk -F ',' '{print $8}')
dir=$( echo $parameters | awk -F ',' '{print $9}')

numberFiles=${#array[@]}
dbusRef=`kdialog --title "Resize Images" --progressbar "" $numberFiles`

for file in "${array[@]}"; do
    fileName="${file##*/}"
    if [ "$sufix" = TRUE ]
        then file_out="$dir/${fileName%.*}_$resolution.${fileName##*.}"
        else file_out="$dir/$fileName"
    fi

    magick "$file" -resize $resolution "$file_out"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"
done

qdbus $dbusRef close

kdialog --title "Resize Images" --icon "checkbox" --passivepopup "Completed" 3
