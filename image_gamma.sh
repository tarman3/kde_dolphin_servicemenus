#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=500 --title="Change Gamma" --form --item-separator="|" --separator="," \
    --field="Gamma:NUM" --field=" :LBL" --field="Dir to save:DIR" --field="Add sufix to name:CHK" \
    "1.0|0.1..2.5|0.1|1"        ""                  "$path"                     TRUE`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

gamma=$( echo $parameters | awk -F ',' '{print $1}')
# gamma=${gamma/","/"."}

dir=$( echo $parameters | awk -F ',' '{print $3}')
sufix=$( echo $parameters | awk -F ',' '{print $4}')

numberFiles=${#array[@]}
dbusRef=`kdialog --title "Changing Gamma" --progressbar "" $numberFiles`

for file in "${array[@]}"; do

    filename="${file##*/}"
    if [ "$sufix" = TRUE ]
        then fileOut="$dir/${filename%.*}_gamma$gamma.${file##*.}"
        else fileOut="$dir/$filename"
    fi

    convert "$file" -gamma $gamma "$fileOut"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Change Gamma" --icon "checkbox" --passivepopup "Completed" 3
