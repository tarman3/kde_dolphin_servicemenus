#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
# IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}
ext=${firstFile##*.}
nameNoExt=${firstFile%.*}

if [ $ext = "png" ] || [ $ext = "PNG" ]; then
    extForm="^png|jpg|tiff|bmp"
else
    extForm="^jpg|png|tiff|bmp"
fi

parameters=`yad --borders=10 --width=400 --title="Merge Images" --text-align=center \
    --item-separator="|" --separator="," --form  \
    --field=":LBL" --field="Direction:CB" --field="Space between images (px)" \
    --field="Frame:CHK" --field="Background color:CB" --field="Format:CB" \
    \
    "" "^vert|hor" "10" FALSE "transparent|white|black" "$extForm"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

direction=$(echo $parameters | awk -F ',' '{print $2}')
space=$(echo $parameters | awk -F ',' '{print $3}')
frame=$(echo $parameters | awk -F ',' '{print $4}')
backgroundColor=$(echo $parameters | awk -F ',' '{print $5}')
ext=$(echo $parameters | awk -F ',' '{print $6}')

newName="${nameNoExt}_$direction.$ext"

numberFiles=${#array[@]}

if [ $direction = "vert" ]
    then opt1="+$space+$space"; opt2="1x${numberFiles}"
    else opt1="+$space+$space"; opt2="${numberFiles}x1"
fi

if [ "$frame" = TRUE ]
    then montage -background $backgroundColor -geometry $opt1 -tile $opt2 `echo "$1"` "$newName"
    else montage -background $backgroundColor -geometry $opt1 -tile $opt2 `echo "$1"` $ext: | magick - -shave $space $newName
fi

kdialog --title "Combine Images" --icon "checkbox" --passivepopup "Completed" 3
