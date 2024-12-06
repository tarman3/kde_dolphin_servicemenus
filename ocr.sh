#!/bin/bash

# https://github.com/tesseract-ocr/tesseract
# https://tesseract-ocr.github.io/tessdoc/Data-Files-in-different-versions.html

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`kdialog --geometry 300x200 --title="OCR - Tesseract" --checklist "Select languages:" \
                deu "Deutch" off    eng "English" off    ita "Italian" off    rus "Russian" on`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

languages=$( echo $parameters | awk -F ',' '{print $1}')
languages=`echo $languages | sed -r 's/" "/+/g' | sed -r 's/[" ]//g'`


numberFiles=${#array[@]}
dbusRef=`kdialog --title "OCR Tesseract" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    tesseract "$file" "${file%.*}-OCR_$languages" -l $languages

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "OCR Tesseract" --icon "checkbox" --passivepopup "Completed" 3
