#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=500 --title="Change colors to Gray" --form --item-separator="|" --separator="," \
    --field=":LBL" --field=" :LBL" --field="Dir to save:DIR" --field="Add sufix to name:CHK" \
        ""      ""                          "$path" TRUE`
exit_status=$?
if [ $exit_status != 0 ]; then exit; fi


dir=$( echo $parameters | awk -F ',' '{print $3}')
sufix=$( echo $parameters | awk -F ',' '{print $4}')

numberFiles=${#array[@]}
dbusRef=`kdialog --title "Changing colors to Gray" --progressbar "" $numberFiles`

for file in "${array[@]}"; do

    filename="${file##*/}"
    if [ "$sufix" = TRUE ]
        then fileOut="$dir/${filename%.*}_gray.${file##*.}"
        else fileOut="$dir/$filename"
    fi

    convert "$file" -colorspace "Gray" "$fileOut"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"
done

qdbus $dbusRef close

kdialog --title "Changing colors to Gray" --icon "checkbox" --passivepopup "Completed" 3
