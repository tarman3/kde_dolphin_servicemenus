#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}
name=${firstFile##*/}
ext=${firstFile##*.}

videoSize=`ffprobe -v error -i "$firstFile" -show_entries stream=width,height -of default=noprint_wrappers=1:nokey=1`
width=`echo "$videoSize" | awk 'NR==1{print $1}'`
height=`echo "$videoSize" | awk 'NR==2{print $1}'`
scale=`echo "scale=2;$width/$height" | bc`


parameters=`yad --borders=10 --width=600 --title="Media processing" \
    --text="File: $name \nResolution: $width"x"$height \nScale: $scale" --form --item-separator="|" --separator="," \
    \
    --field=:LBL --field="Format:CB" --field="Bitrate (kbit):NUM" --field="Resoltion (e.g. 800x452, only even)" \
    --field="Crop W:H:X:Y (Width : Height : X offset left corner : Y offset left corner):" \
    --field="Codec Video:CB" --field="Codec Audio:CB" --field="Rotate:CB" --field="Short test (5 sec):CHK" \
    --field="Mute:CHK" --field="Framerate" --field="CPU Core using:NUM" \
    \
    "" "copy|^mkv|mov|mp4|avi|gif" "4000|0..10000|500" "" \
    "" \
    "^copy|^h264 MPEG-4/AVC|hevc H.265|vp8|vp9|av1|vvc H.266|mpeg2video" "copy|^mp3|aac" "^No|CW|CCW" \
    FALSE FALSE "" "0|0..12|1"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi


format=$( echo $parameters | awk -F ',' '{print $2}')
if [ "$format" != "copy" ]; then ext=$format; fi

bitrate=$( echo $parameters | awk -F ',' '{print $3}')

size=$( echo $parameters | awk -F ',' '{print $4}')
if [ -n "$size" ]; then
    optionsize="-s $size"
    sizeprefix="_$size"
fi

crop=$( echo $parameters | awk -F ',' '{print $5}')
if [ -n "$crop" ]; then cropprefix="-filter:v crop=$crop"; fi

videocodec=$( echo $parameters | awk -F ',' '{print $6}')
if [[ "$videocodec" != "copy" ]] && [[ "$format" != "gif" ]]; then
    optionvideocodec="-vcodec ${videocodec%% *}"
fi

audiocodec=$( echo $parameters | awk -F ',' '{print $7}')
if [ "$audiocodec" != "copy" ]; then
    optionaudiocodec="-acodec $audiocodec"
fi

rotate=$( echo $parameters | awk -F ',' '{print $8}')
if [[ "$rotate" = "CW" ]]; then
    option_rotate="-vf transpose=1"
    prefix="_CW"
elif [ "$rotate" = "CCW" ]; then
    option_rotate="-vf transpose=2"
    prefix="_CCW"
fi

test=$( echo $parameters | awk -F ',' '{print $9}')
if [ "$test" = TRUE ]; then
    testcode="-ss 00:00:05 -to 00:00:10"
    prefix="${prefix}_5sec"
fi

nosound=$( echo $parameters | awk -F ',' '{print $10}')
if [ "$nosound" = TRUE ]; then
    optionaudiocodec="-an"
    prefix="${prefix}_nosound"
fi

framerate=$( echo $parameters | awk -F ',' '{print $11}')
if [ "$framerate" != "" ]; then
    optionFramerate="-r $framerate"
    prefix="${prefix}_${framerate}fps"
fi

threads=$( echo $parameters | awk -F ',' '{print $12}')
if [ $threads -gt 0 ]; then optionthreads="-threads $threads"; fi

# numberFiles=${#array[@]}
# dbusRef=`kdialog --title "Media Processing" --progressbar "" $numberFiles`

for file in "${array[@]}"; do

    counter=$(($counter+1))

    if [ -z "$ext" ]; then ext=${file##*.}; fi

    duration=`ffprobe -v error -i "$file" -loglevel panic -show_entries format=duration -of default=noprint_wrappers=1:nokey=1`

    duration=${duration%%.*}
    durationM=$(($duration / 60))
    durationS=$(($duration - $durationM * 60))

    if [ "$durationM" != "0" ]
        then duration=$durationM" мин "$durationS" сек"
        else duration=$durationS" сек"
    fi

    konsole --hide-menubar -qwindowtitle "Обработка файла $counter из $numberFiles- ${file##*/} длительностью $duration" -e "ffmpeg -v quiet -stats $optionthreads -i \"$file\" $optionthreads $cropprefix -y -b:v \"$bitrate\"k $option_rotate $optionvideocodec $optionsize $optionaudiocodec $optionFramerate $testcode -strict -2 \"${file%.*}\"$sizeprefix\"_$bitrate\"k\"$prefix.$ext\""

#     qdbus $dbusRef Set "" value $counter
#     qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"
#     if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

# qdbus $dbusRef close

kdialog --title "Export images from PDF" --icon "checkbox" --passivepopup "Completed" 3
