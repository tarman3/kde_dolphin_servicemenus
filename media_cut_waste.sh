#!/bin/bash

firstFile="$1"
path=${firstFile%/*}
ext=${firstFile##*.}

cutStart=$2
cutFinish=$3

duration=`ffprobe -i "$firstFile" -show_entries format=duration -v quiet -of csv="p=0"`
duration=${duration%.*}

finishTime=$(($duration-$cutFinish))

ffmpeg -v quiet -stats -i "$firstFile" -y -ss $cutStart -to $finishTime -strict -2 "${firstFile%.*}_$cutStart-$finishTime.$ext"

kdialog --title "Media Cut 2-2" --icon "checkbox" --passivepopup "Completed" 3
