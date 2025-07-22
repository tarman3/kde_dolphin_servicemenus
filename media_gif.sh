#!/bin/bash

oldIFS="$IFS"
IFS=$';'
# read -r -a array <<< "$1"
array=($1)
IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}

videoSize=`ffprobe -v error -i "$firstFile" -show_entries stream=width,height -of default=noprint_wrappers=1:nokey=1`

if [ -n "$videoSize" ]; then
    width=`echo "$videoSize" | awk 'NR==1{print $1}'`
fi

parameters=`yad --borders=20 --width=500 --title="Convert PNG to animated GIF" \
    --item-separator="|" --separator="," --form \
    --field="FPS" --field="Quality [1..100]" --field="Width (default 800x600)" \
     "10"               80             $width `

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

fps=$( echo $parameters | awk -F ',' '{print $1}')
quality=$( echo $parameters | awk -F ',' '{print $2}')
width=$( echo $parameters | awk -F ',' '{print $3}')

if [ "$width" != "" ]; then
    width="--width $width"
fi

numberFiles=${#array[@]}
dbusRef=`kdialog --title "Convert video to GIF" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    filename="${file##*/}"
    fileOut="${filename%.*}.gif"
    gifski $width --quality $quality --fps $fps --output "$fileOut" "$filename"
    echo $width --quality $quality --fps $fps --output "$fileOut" $filename > 1

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close
kdialog --title "PNG to GIF Optimization" --icon "checkbox" --passivepopup "Completed" 3
