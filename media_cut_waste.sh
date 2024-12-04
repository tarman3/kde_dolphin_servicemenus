#!/bin/bash

firstFile="$1"
path=${firstFile%/*}
ext=${firstFile##*.}

cutStart=$2
cutFinish=$3

fadeInDuration=1
fadeOutDuration=1

duration=`ffprobe -i "$firstFile" -show_entries format=duration -v quiet -of csv="p=0"`
duration=${duration%.*}

finishTime=$(($duration-$cutFinish))

startFadeOut=$(($finishTime-$cutStart-$fadeInDuration))
fadeInOut="-vf fade=t=in:st=0:d=${fadeInDuration},fade=t=out:st=${startFadeOut}:d=${fadeOutDuration}"

ffmpeg -v quiet -stats -ss $cutStart -to $finishTime -i "$firstFile" -y $fadeInOut -strict -2 "${firstFile%.*}_$cutStart-$finishTime.$ext"

kdialog --title "Media Cut 2-2" --icon "checkbox" --passivepopup "Completed" 3
