#!/bin/bash

utilities=('enconv')
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

parameters=`kdialog --geometry 300 --title="Change text files encoding" --radiolist "Encoding" \
            UTF-8 UTF-8 on    CP1251 CP1251 off`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

encoding=$( echo $parameters | awk -F ',' '{print $1}')


for file in "${array[@]}"; do

   enconv -L russian -x $encoding "$file"

done

kdialog --title "Change text files encoding" --icon "checkbox" --passivepopup "Completed" 3
