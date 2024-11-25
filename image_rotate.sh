#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=350 --title="Rotate images" --text-align=center --item-separator="|" \
    --separator="!" --form \
    --field="Angle (+ CW, - CCW):NUM" --field=" :LBL" --field="Dir to save:DIR" --field="Add sufix to name:CHK" \
            "90|-360..360|1|1"          ""                  "$path"                     "TRUE"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

angle=$( echo $parameters | awk -F '!' '{print $1}')
angle=${angle/","/"."}

dir=$( echo $parameters | awk -F '!' '{print $3}')
sufix=$( echo $parameters | awk -F '!' '{print $4}')

numberFiles=${#array[@]}
dbusRef=`kdialog --title "Rotate Images" --progressbar "" $numberFiles`

for file in "${array[@]}"; do
    fileName="${file##*/}"
    if [ "$sufix" = TRUE ]
        then file_out="$dir/${fileName%.*}_$angle.${file##*.}"
        else file_out="$dir/$fileName"
    fi

    convert "$file" -rotate "$angle" "$file_out"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Rotate Images" --icon "checkbox" --passivepopup "Completed" 3
