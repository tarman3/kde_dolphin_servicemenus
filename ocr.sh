#!/bin/bash

# https://github.com/tesseract-ocr/tesseract
# https://tesseract-ocr.github.io/tessdoc/Data-Files-in-different-versions.html

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=10 --width=300 --title="Tesseract OCR" --text-align=center \
    --form --item-separator="|" --separator="," --field="Language:CB" "^rus+eng|rus|eng|ita|deu"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

language=$( echo $parameters | awk -F ',' '{print $1}')

numberFiles=${#array[@]}
dbusRef=`kdialog --title "OCR Tesseract" --progressbar "" $numberFiles`

for file in "${array[@]}"; do

    tesseract "$file" "${file%.*}-OCR_$language" -l $language

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"

done

qdbus $dbusRef close

kdialog --title "OCR Tesseract" --icon "checkbox" --passivepopup "Completed" 3
