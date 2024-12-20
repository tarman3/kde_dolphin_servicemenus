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

firstFile=${array[0]}
path=${firstFile%/*}

sufix=`date +%Y-%m-%d_%H-%M-%S`

parameters=`yad --width=300 --borders=20 --title="Add Time Stamp to file name" \
    --form --separator="," --item-separator="|" \
    --field="Sufix" --field="Method:CB" --field="Dir to save:DIR" \
        "_$sufix"        'copy|move'               "$path"`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

sufix=$( echo $parameters | awk -F ',' '{print $1}')
method=$( echo $parameters | awk -F ',' '{print $2}')
dir=$( echo $parameters | awk -F ',' '{print $3}')


for file in "${array[@]}"; do
    name=${file##*/}
    if [ -f "$file" ] && [[ "$file" == *.* ]]
        then newName="${name%.*}${sufix}.${name##*.}"
        else newName="${name}${sufix}"
    fi

    if [ "$method" = 'move' ]
        then mv "$file" "${dir}/${newName}"
        else cp -r "$file" "${dir}/${newName}"
    fi

done

kdialog --title "Rename files" --icon "checkbox" --passivepopup "Completed" 3


