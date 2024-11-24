#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}
ext=${firstFile##*.}


duration=`mediainfo --Inform="Video;%Duration/String3%" $firstFile`
duration=${duration%.*}
echo $duration

parameters=`yad --borders=10 --title="Media Cut" --form --item-separator="|" --separator="," \
    --field=":LBL" --field="Start" --field="Finish" --field="E.g.:LBL" \
    --field="75:LBL" --field="1:15:LBL" --field="00:01:15:LBL"\
    "" "00:00:00" "$duration" ""`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

start=$(echo $parameters | awk -F ',' '{print $2}')
finish=$(echo $parameters | awk -F ',' '{print $3}')
sufix="${start/:/-}_${finish/:/-}"

if [ "$start" != "" ]; then start="-ss $start"; fi
if [ "$finish" != "" ]; then finish="-to $finish"; fi

options="$start $finish"

ffmpeg -i "$firstFile" -y -vcodec copy -acodec copy $start $finish -strict -2 "${firstFile%.*}_$sufix.$ext"

kdialog --title "Media Cut" --icon "checkbox" --passivepopup "Completed" 3
