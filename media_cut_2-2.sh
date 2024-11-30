#!/bin/bash

firstFile="$1"
path=${firstFile%/*}
ext=${firstFile##*.}


duration=`ffprobe -i "$firstFile" -show_entries format=duration -v quiet -of csv="p=0"`
duration=${duration%.*}

ffmpeg -v quiet -stats -i "$firstFile" -y -ss 2 -to $(($duration-2)) -strict -2 "${firstFile%.*}_2-2.$ext"

kdialog --title "Media Cut 2-2" --icon "checkbox" --passivepopup "Completed" 3
