#!/bin/bash

audioFormat='aac'

utilities=('ffmpeg')
for utility in ${utilities[@]}; do
    if ! command -v "$utility" 2>&1 >/dev/null; then
        kdialog --title "$utility" --icon "error" --passivepopup "Not found" 3
        exit 1
    fi
done

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Extract Audio" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    amontAudioTracks=`ffprobe -v error -select_streams a -show_entries stream=index -of csv=p=0 "$file" | wc -w`
    if [ "$amontAudioTracks" -ge 1 ]
        then ffmpeg -v error -i "$file" -vn -acodec copy "${file%.*}.${audioFormat}"
        else echo 1; kdialog --title "${file##*/}" --icon "error" --passivepopup "Does not contain audio tracks" 3
    fi

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Extract Audio" --icon "checkbox" --passivepopup "Completed" 3
