#!/bin/bash

files="$@"

file="$1"
newName="${file%.*}.gif"

width=`identify -ping -format '%w' "$1"`

parameters=`yad --borders=20 --width=500 --title="Convert PNG to animated GIF" \
    --item-separator="|" --separator="," --form \
    --field="FPS" --field="Quality [1..100]" --field="Width (default 800x600)" \
     "0.5"               80             $width `

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

fps=$( echo $parameters | awk -F ',' '{print $1}')
quality=$( echo $parameters | awk -F ',' '{print $2}')
width=$( echo $parameters | awk -F ',' '{print $3}')

if [ "$width" != "" ]; then
    width="--width $width"
fi

gifski $width --quality $quality --fps $fps --output "$newName" $files

kdialog --title "PNG to GIF Optimization" --icon "checkbox" --passivepopup "Completed" 3
