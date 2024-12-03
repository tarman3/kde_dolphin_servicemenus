#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=500 --title="Compress JPG" \
    --text-align=center --item-separator="|" --separator="," --form \
    --field="Type:CB" --field="Quality:SCL" --field=" :LBL" --field="Dir to save:DIR" \
    --field="Add sufix to name:CHK" \
    "lossy|lossless" "85"    ""    "$path"    TRUE`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

type=$( echo $parameters | awk -F ',' '{print $1}')
quality=$( echo $parameters | awk -F ',' '{print $2}')
dir=$( echo $parameters | awk -F ',' '{print $4}')
sufix=$( echo $parameters | awk -F ',' '{print $5}')


numberFiles=${#array[@]}
dbusRef=`kdialog --progressbar "Compress JPG" $numberFiles`

for file in "${array[@]}"; do
    fileName="${file##*/}"
    if [ "$sufix" = TRUE ]; then
        if [ "$type" = "lossless" ]
            then file_out="$dir/${fileName%.*}_opti.${file##*.}"
            else file_out="$dir/${fileName%.*}_$quality.${file##*.}"
        fi

        else file_out="$dir/$fileName"
    fi

    # magick "$file" -quality $quality "${file_out}"
    if [ "$type" = "lossless" ]
        then jpegoptim --dest="$dir" --overwrite --force "$file" --stdout > "$file_out"
        else jpegoptim --dest="$dir" --overwrite --force --max=$quality "$file" --stdout >> "$file_out"
    fi

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Compress JPG" --icon "checkbox" --passivepopup "Completed" 3
