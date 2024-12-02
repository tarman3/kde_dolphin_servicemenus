#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}
ext=${firstFile##*.}


duration=`ffprobe -i "$firstFile" -show_entries format=duration -v quiet -of csv="p=0" -sexagesimal`
duration=${duration%.*}

parameters=`yad --width=300 --borders=10 --title="Media Cut" --form --item-separator="|" --separator="," \
    --field="Start" --field="Finish" --field="Re-encoding (slowly but precisely):CHK" \
       "0:00:00"       "$duration"                   TRUE`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

start=$(echo $parameters | awk -F ',' '{print $1}')
finish=$(echo $parameters | awk -F ',' '{print $2}')
reEncoding=$(echo $parameters | awk -F ',' '{print $3}')

sufix="${start/ /_}_${finish/ /_}"

if [ "$start" != "" ]; then start="-ss $start"; fi
if [ "$finish" != "" ]; then finish="-to $finish"; fi
options="$start $finish"

if [ "$reEncoding" = FALSE ]; then encode="-vcodec copy -acodec copy"; fi


ffmpeg -v quiet -stats -i "$firstFile" -y $encode $start $finish -strict -2 "${firstFile%.*}_$sufix.$ext"


kdialog --title "Media Cut" --icon "checkbox" --passivepopup "Completed" 3
