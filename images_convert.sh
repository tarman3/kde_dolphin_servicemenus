#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=500 --title="Convert Images" --text-align=center \
    --item-separator="|" --separator="," --form \
    --field="Format:CB"  --field="Dir to save:DIR" "^jpg|png|bmp|tiff|gif|pdf" "$path"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

format=$( echo $parameters | awk -F ',' '{print $1}')
dir=$( echo $parameters | awk -F ',' '{print $2}')


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Convert Images" --progressbar "" $numberFiles`

for file in "${array[@]}"; do
    fileName="${file##*/}"
    mogrify -format $format -path "$dir" "$fileName"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Convert Images" --icon "checkbox" --passivepopup "Completed" 3
