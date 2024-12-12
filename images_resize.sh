#!/bin/bash

# https://imagemagick.org/script/command-line-processing.php#geometry

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=500 --title="Change images resolution" \
    --item-separator="|" --separator="," --form \
    --field="Resolution (800 or x600 or 800x600 or 50%)" --field="Keep aspect ratio:CHK" \
    --field="Add sufix to name:CHK" --field="Dir to save:DIR" \
    "1368"    TRUE    TRUE    "$path"`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

resolution=$( echo $parameters | awk -F ',' '{print $1}')
keepAspectRatio=$( echo $parameters | awk -F ',' '{print $2}')
sufix=$( echo $parameters | awk -F ',' '{print $3}')
dir=$( echo $parameters | awk -F ',' '{print $4}')

if [ "$keepAspectRatio" = FALSE ]; then optionRatio='!'; fi


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Resize Images" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    fileName="${file##*/}"
    if [ "$sufix" = TRUE ]
        then file_out="$dir/${fileName%.*}_$resolution.${fileName##*.}"
        else file_out="$dir/$fileName"
    fi

    magick "$file" -resize ${resolution}${optionRatio} "$file_out"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Resize Images" --icon "checkbox" --passivepopup "Completed" 3
