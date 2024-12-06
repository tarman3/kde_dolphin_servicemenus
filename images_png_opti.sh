#!/bin/bash

# https://optipng.sourceforge.net/

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=500 --title="PNG Optimization" \
    --item-separator="|" --separator="," --form \
    --field="Type:CB" --field="Remove metadata:CHK" --field="Dir to save:DIR" \
    --field="Add sufix to name:CHK" \
     "lossy|lossless"               TRUE                        "$path"                       TRUE`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

type=$( echo $parameters | awk -F ',' '{print $1}')
meta=$( echo $parameters | awk -F ',' '{print $2}')
dir=$( echo $parameters | awk -F ',' '{print $3}')
sufix=$( echo $parameters | awk -F ',' '{print $4}')

if [ "$meta" = TRUE ]; then
    meta_oxi='--strip all'
    meta_quant='--strip'
fi


numberFiles=${#array[@]}
dbusRef=`kdialog --title "PNG Optimization" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    fileName="${file##*/}"

    if [ "$sufix" = TRUE ]
        then file_out="$dir/${fileName%.*}_opti.${fileName##*.}"
        else file_out="$dir/$fileName"
    fi

    if [ "$type" = "lossless" ]
        then oxipng ${meta_oxi} --alpha --scale16 "$file" --out "${file_out}"
        else pngquant ${meta_quant} --force --quality=60-80 "$file" --output "${file_out}"
    fi

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "PNG Optimization" --icon "checkbox" --passivepopup "Completed" 3
