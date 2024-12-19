#!/bin/bash

audioFormat='aac'

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Extract Audio" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    amontAudioTracks=`ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$file" | wc -w`
    if [ "$amontAudioTracks" -ge 1 ]; then
        ffmpeg -v error -i "$file" -vn -acodec copy "${file%.*}.${audioFormat}"
    fi

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Extract Audio" --icon "checkbox" --passivepopup "Completed" 3
