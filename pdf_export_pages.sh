#!/bin/bash

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`kdialog --geometry 300x200 --title="Export pages from PDF" \
    --inputbox "Pages number (1-3,5,6) or (5-z)" "1"`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

numberFiles=${#array[@]}
dbusRef=`kdialog --title "Export pages from PDF" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`


for file in "${array[@]}"; do

    qpdf --decrypt --pages "$file" $parameters -- "$file" "${file%.*}_pages_${parameters}.pdf"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Export pages from PDF" --icon "checkbox" --passivepopup "Completed" 3
