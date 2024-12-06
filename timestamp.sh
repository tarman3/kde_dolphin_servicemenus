#!/bin/bash


oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"

sufix=`date +%Y-%m-%d_%H-%M-%S`

parameters=`yad --width=300 --borders=20 --title="Add Time Stamp to file name" \
    --form --separator="," --item-separator="|" \
    --field="Sufix" --field="Rewrite original:CHK" \
        "_$sufix"                  TRUE`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

sufix=$( echo $parameters | awk -F ',' '{print $1}')
rewrite=$( echo $parameters | awk -F ',' '{print $2}')


for file in "${array[@]}"; do

    newname="${file%.*}${sufix}.${file##*.}"

    if [ "$rewrite" = TRUE ]
        then mv "$file" "$newname"
        else cp "$file" "$newname"
    fi

done

kdialog --title "Rename files" --icon "checkbox" --passivepopup "Completed" 3


