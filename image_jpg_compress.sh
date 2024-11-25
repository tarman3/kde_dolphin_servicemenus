#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=500 --title="Compress JPG" \
    --text-align=center --item-separator="|" --separator="," --form \
    --field="Quality:SCL" --field=" :LBL" --field="Dir to save:DIR" --field=" :LBL" --field="Add sufix to name:CHK" \
    "85"    ""    "$path"    "FALSE"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

quality=$( echo $parameters | awk -F ',' '{print $1}')
dir=$( echo $parameters | awk -F ',' '{print $3}')
sufix=$( echo $parameters | awk -F ',' '{print $5}')


numberFiles=${#array[@]}
dbusRef=`kdialog --progressbar "Compress JPG" $numberFiles`

for file in "${array[@]}"; do
    fileName="${file##*/}"
    if [ "$sufix" == TRUE ]
        then file_out="$dir/${fileName%.*}_$quality.${file##*.}"
        else file_out="$dir/$fileName"
    fi

    magick "$file" -quality $quality "${file_out}"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"

done

qdbus $dbusRef close

kdialog --title "Compress JPG" --icon "checkbox" --passivepopup "Completed" 3
