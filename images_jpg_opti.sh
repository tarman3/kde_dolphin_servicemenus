#!/bin/bash

utilities=('yad' 'jpegoptim')
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

parameters=`yad --borders=20 --width=500 --title="Compress JPG" --item-separator="|" --separator="," --form \
    --field="Type:CB" --field="Quality:SCL" --field=" :LBL" --field="Dir to save:DIR" \
    --field="Add sufix to name:CHK" \
    "lossy|lossless" "85"    ""    "$path"    TRUE`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

type=$( echo $parameters | awk -F ',' '{print $1}')
quality=$( echo $parameters | awk -F ',' '{print $2}')
dir=$( echo $parameters | awk -F ',' '{print $4}')
sufix=$( echo $parameters | awk -F ',' '{print $5}')


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Compress JPG" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    fileName="${file##*/}"
    if [ "$sufix" = TRUE ]; then
        if [ "$type" = "lossless" ]
            then file_out="$dir/${fileName%.*}_opti.${file##*.}"
            else file_out="$dir/${fileName%.*}_$quality.${file##*.}"
        fi

        else file_out="$dir/$fileName"
    fi

    if [ "$type" = "lossless" ]
        then jpegoptim --dest="$dir" --overwrite --force "$file" --stdout > "$file_out"
        else jpegoptim --dest="$dir" --overwrite --force --max=$quality "$file" --stdout >> "$file_out"
    fi

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Compress JPG" --icon "checkbox" --passivepopup "Completed" 3
