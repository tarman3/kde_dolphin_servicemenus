#!/bin/bash

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

parameters=`yad --borders=10 --width=600 --title="Media processing" \
    --text="File: $name \nResolution: $width"x"$height \nScale: $scale" \
    --button="Test 5 sec:2" --button="Cancel:1" --button="Ok:0" \
    --form --item-separator="|" --separator="," --field=:LBL \
    --field="Format:CB" --field="Bitrate (kbit):NUM" --field="Resoltion (e.g. 800x452, only even)" \
    --field="Crop W:H:X:Y (Width : Height : X offset left corner : Y offset left corner):" \
    --field="Codec Video:CB" --field="Codec Audio:CB" --field="Rotate:CB" --field="Framerate" \
    --field="FadeIn, sec" --field="FadeOut, sec" --field="CPU Core using:NUM" \
    ""   "copy|^mkv|mov|mp4|avi|gif"   "4000|0..10000|500"   "" \
    ""    "^copy|^h264 MPEG-4/AVC|hevc H.265|vp8|vp9|av1|vvc H.266|mpeg2video"   "copy|^mp3|aac|mute" \
    "^No|CW|CCW"    ""    0    0    "1|0..12|1"`

exit_status=$?; if [ $exit_status != 0 ] && [ $exit_status != 2 ]; then exit; fi

format=$( echo $parameters | awk -F ',' '{print $2}')
if [ "$format" != "copy" ]; then ext=$format; fi

bitrate=$( echo $parameters | awk -F ',' '{print $3}')

size=$( echo $parameters | awk -F ',' '{print $4}')
if [ -n "$size" ]; then
    optionSize="-s $size"
    sizePrefix="_$size"
fi

crop=$( echo $parameters | awk -F ',' '{print $5}')
if [ -n "$crop" ]; then
    optionCrop="-filter:v crop=$crop"
    prefix="${prefix}_crop"
fi

videoCodec=$( echo $parameters | awk -F ',' '{print $6}')
if [ "$format" != "gif" ]; then optionVideoCodec="-vcodec ${videoCodec%% *}"; fi

audioCodec=$( echo $parameters | awk -F ',' '{print $7}')
if [ "$audiocodec" = "mute" ]
    then optionAudioCodec="-an"; prefix="${prefix}_nosound"
    else optionAudioCodec="-acodec $audioCodec"
fi

rotate=$( echo $parameters | awk -F ',' '{print $8}')
if [ "$rotate" = "CW" ]; then
    optionRotate="-vf transpose=1"
    prefix="${prefix}_$rotate"
elif [ "$rotate" = "CCW" ]; then
    optionRotate="-vf transpose=2"
    prefix="${prefix}_$rotate"
fi

if [ "${exit_status}" = 2 ]; then
    optionCut="-ss 00:00:05 -to 00:00:10"
    prefix="${prefix}_5sec"
fi

framerate=$( echo $parameters | awk -F ',' '{print $9}')
if [ "$framerate" != "" ]; then
    optionFramerate="-r $framerate"
    prefix="${prefix}_${framerate}fps"
fi

fadeInDuration=$( echo $parameters | awk -F ',' '{print $10}')
fadeOutDuration=$( echo $parameters | awk -F ',' '{print $11}')
if [ "$fadeInDuration" != 0 ] || [ "$fadeOutDuration" != 0 ]; then prefix="${prefix}_fade"; fi

threads=$( echo $parameters | awk -F ',' '{print $12}')
if [ "$threads" != 0 ]; then optionThreads="-threads $threads"; fi


# numberFiles=${#array[@]}
# dbusRef=`kdialog --title "Media Processing" --progressbar "" $numberFiles`

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

    if [ "$fadeInDuration" != 0 ] && [ "$fadeInDuration" != "" ]; then
        fadeIn="fade=t=in:st=0:d=${fadeInDuration},"
    fi
    if [ "$fadeOutDuration" != 0 ] && [ "$fadeOutDuration" != "" ]; then
        startFadeOut=$(($durationProcess-$fadeOutDuration))
        fadeOut="fade=t=out:st=${startFadeOut}:d=${fadeOutDuration}"
    fi
    if [ $fadeIn ] || [ $fadeOut ]; then fadeInOut="-vf $fadeIn$fadeOut"; fi


    if [ "$durationM" != 0 ]
        then duration=$durationM" min "$durationS" sec"
        else duration=$durationS" sec"
    fi

    konsole --hide-menubar -qwindowtitle "Processing file $counter of $numberFiles- ${file##*/} duration $duration" -e "ffmpeg -v quiet -stats $optionThreads $optionCut -i \"$file\" $optionCrop -y -b:v \"$bitrate\"k $optionRotate $optionVideoCodec $optionSize $optionAudioCodec $optionFramerate $fadeInOut -strict -2 \"${file%.*}\"$sizePrefix\"_$bitrate\"k\"$prefix.$ext\""

#     qdbus $dbusRef Set "" value $counter
#     qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"
#     if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

# qdbus $dbusRef close

kdialog --title "Export images from PDF" --icon "checkbox" --passivepopup "Completed" 3
