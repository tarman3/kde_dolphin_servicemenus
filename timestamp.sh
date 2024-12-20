#!/bin/bash

utilities=('yad')
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

sufix=`date +%Y-%m-%d_%H-%M-%S`

parameters=`yad --width=300 --borders=20 --title="Add Time Stamp to file name" \
    --form --separator="," --item-separator="|" \
    --field="Sufix" --field="Method:CB" \
        "_$sufix"           'copy|move'`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

sufix=$( echo $parameters | awk -F ',' '{print $1}')
method=$( echo $parameters | awk -F ',' '{print $2}')


for file in "${array[@]}"; do

    if [ -f "$file" ] && [[ "$file" == *.* ]]
        then newname="${file%.*}${sufix}.${file##*.}"
        else newname="${file}${sufix}"
    fi

    if [ "$method" = 'move' ]
        then mv "$file" "$newname"
        else cp -r "$file" "$newname"
    fi

done

kdialog --title "Rename files" --icon "checkbox" --passivepopup "Completed" 3


