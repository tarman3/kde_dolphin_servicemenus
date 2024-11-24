#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
# IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}
ext=${firstFile##*.}
nameNoExt=${firstFile%.*}

parameters=`kdialog --title="Combine PDF" --inputbox "New name" "${nameNoExt}_combine"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi


newName="${parameters%.*}.pdf"

pdfunite $1 "$newName"

