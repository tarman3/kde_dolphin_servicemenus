#!/bin/bash

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}
ext=${firstFile##*.}


duration=`ffprobe -i "$firstFile" -show_entries format=duration -v quiet -of csv="p=0" -sexagesimal`
duration=${duration%.*}

parameters=`yad --width=300 --borders=10 --title="Media Cut" --form --item-separator="|" --separator="," \
    --field="Start" --field="Finish" --field="Re-encoding (slowly but precisely):CHK" \
    --field="FadeIn, sec" --field="FadeOut, sec" \
    \
    "0:00:00"    "$duration"    TRUE    0    0`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

cutStart=$(echo $parameters | awk -F ',' '{print $1}')
cutFinish=$(echo $parameters | awk -F ',' '{print $2}')
reEncoding=$(echo $parameters | awk -F ',' '{print $3}')
fadeInDuration=$( echo $parameters | awk -F ',' '{print $4}')
fadeOutDuration=$( echo $parameters | awk -F ',' '{print $5}')

if [ "$fadeInDuration" != "" ] || [ "$fadeOutDuration" != "" ]; then

    old_ifs="$IFS"
    IFS=$':'
    read -r -a arrayF <<< "$cutFinish"
    read -r -a arrayS <<< "$cutStart"
    IFS="$old_ifs"

    number=${#arrayS[@]}
    if [ $number -eq 1 ]; then cutStartS=$cutStart
    elif [ $number -eq 2 ]; then cutStartS=$((10#$arrayS[0]*60+10#$arrayS[1]))
    elif [ $number -eq 3 ]; then cutStartS=$((10#${arrayS[0]}*3600+10#${arrayS[1]}*60+10#${arrayS[2]}))
    fi

    number=${#arrayF[@]}
    if [ $number -eq 1 ]; then cutFinishS=$cutFinish
    elif [ $number -eq 2 ]; then cutFinishS=$((10#$arrayF[0]*60+10#$arrayF[1]))
    elif [ $number -eq 3 ]; then cutFinishS=$((10#${arrayF[0]}*3600+10#${arrayF[1]}*60+10#${arrayF[2]}))
    fi

    if [ "$fadeInDuration" != "" ] && [ "$fadeInDuration" != 0 ]; then
        fadeIn="fade=t=in:st=0:d=${fadeInDuration},"
    fi

    if [ "$fadeOutDuration" != "" ] && [ "$fadeOutDuration" != 0 ]; then
        startFadeOut=$(($cutFinishS-$cutStartS-$fadeOutDuration))
        fadeOut="fade=t=out:st=${startFadeOut}:d=${fadeOutDuration}"
    fi

    if [ $fadeIn ] || [ $fadeOut ]; then fadeInOut="-vf $fadeIn$fadeOut"; fi

fi

sufix="${cutStart/ /_}_${cutFinish/ /_}"

if [ "$cutStart" != "" ]; then start="-ss $cutStart"; fi
if [ "$cutFinish" != "" ]; then finish="-to $cutFinish"; fi
options="$start $finish"

if [ "$reEncoding" = FALSE ] && [ -z "$fadeInOut" ]; then encode="-vcodec copy -acodec copy"; fi


ffmpeg -v quiet -stats $start $finish -i "$firstFile" -y $encode $fadeInOut -strict -2 "${firstFile%.*}_$sufix.$ext"


kdialog --title "Media Cut" --icon "checkbox" --passivepopup "Completed" 3
