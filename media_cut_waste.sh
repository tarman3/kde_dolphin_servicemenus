#!/bin/bash

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}

cutStart=$2
cutFinish=$3

fadeInDuration=$4
fadeOutDuration=$5


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Media Cut Waste" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    ext=${file##*.}

    duration=`ffprobe -i "$file" -show_entries format=duration -v quiet -of csv="p=0"`
    duration=${duration%.*}

    finishTime=$(($duration-$cutFinish))

    if [ "$fadeInDuration" != "" ] && [ "$fadeInDuration" != 0 ]; then
        filters="${filters},fade=t=in:st=0:d=${fadeInDuration}"
        sufix="${sufix}_fadeIn"
    fi

    if [ "$fadeOutDuration" != "" ] && [ "$fadeOutDuration" != 0 ]; then
        startFadeOut=$(($finishTime-$cutStart-$fadeOutDuration))
        filters="${filters},fade=t=out:st=${startFadeOut}:d=${fadeOutDuration}"
        sufix="${sufix}_fadeOut"
    fi

    if [ "$filters" != "" ]; then filters="-vf ${filters:1}"; fi

    ffmpeg -y -v error -stats -ss $cutStart -to $finishTime -i "$file" $filters -strict -2 "${file%.*}_$cutStart-$finishTime$sufix.$ext"


    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Media Cut Waste" --icon "checkbox" --passivepopup "Completed" 3
