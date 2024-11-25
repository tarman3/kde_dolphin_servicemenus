#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=500 --title="Reduce colors to 8bit" \
    --text-align=center --item-separator="|" --separator="," --form \
    --field="Dir to save:DIR" --field="Add sufix to name:CHK" \
    "$path"    "FALSE"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

dir=$( echo $parameters | awk -F ',' '{print $1}')
sufix=$( echo $parameters | awk -F ',' '{print $2}')


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Compress PNG" --progressbar "" $numberFiles`

for file in "${array[@]}"; do
    fileName="${file##*/}"
    if [ "$sufix" = TRUE ]
        then file_out="$dir/${fileName%.*}_8bit.${fileName##*.}"
        else file_out="$dir/$fileName"
    fi

    magick "$file" "png8:${file_out}"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"
done

qdbus $dbusRef close

kdialog --title "Compress PNG" --icon "checkbox" --passivepopup "Completed" 3
