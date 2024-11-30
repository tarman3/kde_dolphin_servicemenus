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
    --field="Start" --field="Finish" --field="Cut 2 sec from Start and Fisnis:CHK" --field="Re-encoding (slowly but precisely):CHK" \
       "0:00:00"       "$duration"             FALSE              TRUE`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

start=$(echo $parameters | awk -F ',' '{print $1}')
finish=$(echo $parameters | awk -F ',' '{print $2}')
cut2x2=$(echo $parameters | awk -F ',' '{print $3}')
reEncoding=$(echo $parameters | awk -F ',' '{print $4}')

lengthS=`echo $start | awk '{n=split($0, array, ":")} END{print n }'`
if [ $lengthS -eq 3 ]; then
    startS=$(echo $start | awk -F ':' '{print $3}')
    startM=$(echo $start | awk -F ':' '{print $2}')
    startH=$(echo $start | awk -F ':' '{print $1}')
elif [ $lengthS -eq 2 ]; then
    startS=$(echo $start | awk -F ':' '{print $2}')
    startM=$(echo $start | awk -F ':' '{print $1}')
    startH=0
else
    startS=$(echo $start | awk -F ':' '{print $1}')
    startM=0
    startH=0
fi
startS=$(($startS+$startM*60+$startH*3600))

lengthF=`echo $finish | awk '{n=split($0, array, ":")} END{print n }'`
if [ $lengthF -eq 3 ]; then
    finishS=$(echo $finish | awk -F ':' '{print $3}')
    finishM=$(echo $finish | awk -F ':' '{print $2}')
    finishH=$(echo $finish | awk -F ':' '{print $1}')
elif [ $lengthF -eq 2 ]; then
    finishS=$(echo $finish | awk -F ':' '{print $2}')
    finishM=$(echo $finish | awk -F ':' '{print $1}')
    finishH=0
else
    finishS=$(echo $finish | awk -F ':' '{print $1}')
    finishH=0
    finishM=0
fi
finishS=$(($finishS+$finishM*60+$finishH*3600))

if [ "$cut2x2" = TRUE ]; then
    startS=$(($startS+2))
    finishS=$(($finishS-2))
fi

if [ "$startS" != "" ]; then start="-ss $startS"; fi
if [ "$finishS" != "" ]; then finish="-to $finishS"; fi


options="$start $finish"
sufix="${start/ /_}${finish/ /_}"

if [ "$reEncoding" = FALSE ]; then encode="-vcodec copy -acodec copy"; fi


ffmpeg -v quiet -stats -i "$firstFile" -y $encode $start $finish -strict -2 "${firstFile%.*}_$sufix.$ext"

kdialog --title "Media Cut" --icon "checkbox" --passivepopup "Completed" 3
