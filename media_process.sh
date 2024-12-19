#!/bin/bash

utilities=('yad' 'ffmpeg')
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

firstFile=${array[0]}
path=${firstFile%/*}
name=${firstFile##*/}
ext=${firstFile##*.}

videoSize=`ffprobe -v error -i "$firstFile" -show_entries stream=width,height -of default=noprint_wrappers=1:nokey=1`

if [ -n "$videoSize" ]; then
    width=`echo "$videoSize" | awk 'NR==1{print $1}'`
    height=`echo "$videoSize" | awk 'NR==2{print $1}'`
    scale=`echo "scale=2;$width/$height" | bc`
fi

parameters=`yad --borders=10 --width=800 --title="Media processing" \
    --text="File: $name \nResolution: $width"x"$height \nScale: $scale" \
    --button="Test 5 sec:2" --button="Cancel:1" --button="Ok:0" \
    --form --item-separator="|" --separator="," --field=:LBL \
    --field="Format:CB" --field="Bitrate (kbit):NUM" --field="Resoltion (e.g. 800x452, only even)" \
    --field="Crop W:H:X:Y, eg. 800:600:10:10:" \
    --field="Codec Video:CB" --field="Codec Audio:CB" --field="Rotate:CB" --field="Mirror:CB" \
    --field="Framerate" --field="FadeIn, sec" --field="FadeOut, sec" --field="CPU Core using:NUM" \
    --field="Advanced filters -vf" --field="Filters Help:LINK" \
    ""   "copy|^mkv|mov|mp4|avi|gif"   "4000|0..10000|500"   "" \
    ""    "^copy|^h264 MPEG-4/AVC|hevc H.265|vp8|vp9|av1|vvc H.266|mpeg2video"   "copy|^aac|mp3|mute" \
    "^No|CW|CCW"    "No|Horizontally|Vertically|HorVert"    ""    0    0    "1|0..12|1" \
    ""    "https://ffmpeg.org/ffmpeg-filters.html"`

exit_status=$?; if [ $exit_status != 0 ] && [ $exit_status != 2 ]; then exit; fi

format=$( echo $parameters | awk -F ',' '{print $2}')
if [ "$format" != "copy" ]; then ext=$format; fi

bitrate=$( echo $parameters | awk -F ',' '{print $3}')
optionBitrate="-b:v ${bitrate}k"

size=$( echo $parameters | awk -F ',' '{print $4}')
if [ -n "$size" ]; then
    optionSize="-s $size"
    sizePrefix="_$size"
fi

crop=$( echo $parameters | awk -F ',' '{print $5}')
if [ -n "$crop" ]; then
    filters="${filters}, crop=$crop"
    sufix="${sufix}_crop"
fi

videoCodec=$( echo $parameters | awk -F ',' '{print $6}')
if [ "$format" != "gif" ]; then optionVideoCodec="-vcodec ${videoCodec%% *}"; fi

audioCodec=$( echo $parameters | awk -F ',' '{print $7}')
if [ "$audioCodec" = "mute" ]
    then optionAudioCodec="-an"; sufix="${sufix}_nosound"
    else optionAudioCodec="-acodec $audioCodec"
fi

rotate=$( echo $parameters | awk -F ',' '{print $8}')
if [ "$rotate" = "CW" ]; then
    filters="${filters}, transpose=1"
    sufix="${sufix}_$rotate"
elif [ "$rotate" = "CCW" ]; then
    filters="${filters}, transpose=2"
    sufix="${sufix}_$rotate"
fi

if [ "${exit_status}" = 2 ]; then
    optionCut="-ss 00:00:05 -to 00:00:10"
    sufix="${sufix}_5sec"
fi

mirror=$( echo $parameters | awk -F ',' '{print $9}')
if [ "$mirror" = "Horizontally" ]; then
    filters="${filters}, hflip"
    sufix="${sufix}_hflip"
elif [ "$mirror" = "Vertically" ]; then
    filters="${filters}, vflip"
    sufix="${sufix}_vflip"
elif [ "$mirror" = "HorVert" ]; then
    filters="${filters}, hflip,vflip"
    sufix="${sufix}_hvflip"
fi

framerate=$( echo $parameters | awk -F ',' '{print $10}')
if [ "$framerate" != "" ]; then
    optionFramerate="-r $framerate"
    sufix="${sufix}_${framerate}fps"
fi

fadeInDuration=$( echo $parameters | awk -F ',' '{print $11}')
if [ "$fadeInDuration" != "" ] && [ "$fadeInDuration" != 0 ]; then sufix="${sufix}_fadeIn"; fi

fadeOutDuration=$( echo $parameters | awk -F ',' '{print $12}')
if [ "$fadeOutDuration" != "" ] && [ "$fadeOutDuration" != 0 ]; then sufix="${sufix}_fadeOut"; fi


threads=$( echo $parameters | awk -F ',' '{print $13}')
if [ "$threads" != 0 ]; then optionThreads="-threads $threads"; fi

advancedFilters=$( echo $parameters | awk -F ',' '{print $14}')
if [ "$advancedFilters" != "" ]; then filters="${filters}, $advancedFilters"; fi


for file in "${array[@]}"; do

    counter=$(($counter+1))

    if [ -z "$ext" ]; then ext=${file##*.}; fi

    duration=`ffprobe -v error -i "$file" -loglevel panic -show_entries format=duration -of default=noprint_wrappers=1:nokey=1`

    duration=${duration%%.*}
    durationM=$(($duration / 60))
    durationS=$(($duration - $durationM * 60))

    if [ -n "$optionCut" ];
        then durationProcess=5
        else durationProcess=$duration
    fi

    if [ "$fadeInDuration" != "" ] && [ "$fadeInDuration" != 0 ]; then
        fadeIn="fade=t=in:st=0:d=${fadeInDuration}"
        filters="${filters}, $fadeIn"
    fi

    if [ "$fadeOutDuration" != "" ] && [ "$fadeOutDuration" != 0 ]; then
        startFadeOut=$(($durationProcess-$fadeOutDuration))
        fadeOut="fade=t=out:st=${startFadeOut}:d=${fadeOutDuration}"
        filters="${filters}, $fadeOut"
    fi

    if [ "$durationM" != 0 ]
        then duration=$durationM" min "$durationS" sec"
        else duration=$durationS" sec"
    fi

    if [ "$filters" != "" ]; then filters="-vf \"${filters:2}\""; fi

    konsole --hide-menubar -qwindowtitle "Processing file $counter of $numberFiles - \"${file##*/}\" duration $duration" -e "ffmpeg -y -v error -stats $optionThreads $optionCut -i \"$file\" $optionBitrate  $optionVideoCodec $optionSize $optionAudioCodec $optionFramerate $filters -strict -2 \"${file%.*}${sizePrefix}_${bitrate}k${sufix}.${ext}\""

done

kdialog --title "Media processing" --icon "checkbox" --passivepopup "Completed" 3
