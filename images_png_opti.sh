#!/bin/bash

# https://optipng.sourceforge.net/

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=500 --title="PNG Optimization" \
    --item-separator="|" --separator="," --form \
    --field="Dir to save:DIR" --field="Add sufix to name:CHK" \
                "$path"                       TRUE`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

dir=$( echo $parameters | awk -F ',' '{print $1}')
sufix=$( echo $parameters | awk -F ',' '{print $2}')


numberFiles=${#array[@]}
dbusRef=`kdialog --title "PNG Optimization" --progressbar "" $numberFiles`

for file in "${array[@]}"; do
    fileName="${file##*/}"
    if [ "$sufix" = TRUE ]
        then file_out="$dir/${fileName%.*}_opti.${fileName##*.}"
        else file_out="$dir/$fileName"
    fi

    oxipng --strip all --alpha --scale16 "$file" --out "${file_out}"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "PNG Optimization" --icon "checkbox" --passivepopup "Completed" 3
