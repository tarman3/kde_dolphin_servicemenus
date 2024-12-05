#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

cutStart=$2
cutFinish=$3

fadeInDuration=1
fadeOutDuration=1

numberFiles=${#array[@]}
dbusRef=`kdialog --title "Media Cut Waste" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    ext=${file##*.}

    duration=`ffprobe -i "$file" -show_entries format=duration -v quiet -of csv="p=0"`
    duration=${duration%.*}

    finishTime=$(($duration-$cutFinish))

    startFadeOut=$(($finishTime-$cutStart-$fadeInDuration))
    fadeInOut="-vf fade=t=in:st=0:d=${fadeInDuration},fade=t=out:st=${startFadeOut}:d=${fadeOutDuration}"

    ffmpeg -v quiet -stats -ss $cutStart -to $finishTime -i "$file" -y $fadeInOut -strict -2 "${file%.*}_$cutStart-$finishTime.$ext"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Media Cut Waste" --icon "checkbox" --passivepopup "Completed" 3
