#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
# IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}
ext=${firstFile##*.}
namenoext=${firstFile%.*}

if [ $ext = "png" ] || [ $ext = "PNG" ]; then
    extForm="^png|jpg|tiff|bmp"
else
    extForm="^jpg|png|tiff|bmp"
fi

parameters=`yad --borders=10 --width=600 --title="Merge Images" --text-align=center \
    --item-separator="|" --separator="," --form  \
    --field=":LBL" --field="Direction:CB" --field="Space px" --field="Format:CB" \
    "" "^vert|hor" "0" "$extForm"`

exit_status=$?
if [ $exit_status = 1 ]; then exit; fi

direction=$(echo $parameters | awk -F ',' '{print $2}')
space=$(echo $parameters | awk -F ',' '{print $3}')
ext=$(echo $parameters | awk -F ',' '{print $4}')

newName="${namenoext}_$direction.$ext"

numberFiles=${#array[@]}

if [ $direction = "vert" ]; then
    montage -geometry +0+$space -tile 1x$numberFiles `echo "$1"` "$newName"
    echo VERT
fi

if [ $direction = "hor" ]; then
    montage -geometry +$space+0 -tile "$numberFiles"x1 `echo "$1"` "$newName"
fi

kdialog --title "Combine Images" --icon "checkbox" --passivepopup "Completed" 3
