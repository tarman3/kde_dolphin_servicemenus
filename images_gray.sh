#!/bin/bash

utilities=('yad' 'convert')
for utility in ${utilities[@]}; do
    if ! command -v "$utility" 2>&1 >/dev/null; then
        kdialog --title "$utility" --icon "error" --passivepopup "Not found" 3
        exit 1
    fi
done

oldIFS="$IFS"
IFS=$';'
# read -r -a array <<< "$1"
array=($1)
IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=500 --title="Change colors to Gray" \
    --form --item-separator="|" --separator="," \
    --field="Dir to save:DIR" --field="Add sufix to name:CHK" \
              "$path"                       TRUE`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

dir=$( echo $parameters | awk -F ',' '{print $1}')
sufix=$( echo $parameters | awk -F ',' '{print $2}')


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Convert colors to Gray" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    filename="${file##*/}"
    if [ "$sufix" = TRUE ]
        then fileOut="$dir/${filename%.*}_gray.${file##*.}"
        else fileOut="$dir/$filename"
    fi

    convert "$file" -colorspace "Gray" "$fileOut"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Changing colors to Gray" --icon "checkbox" --passivepopup "Completed" 3
