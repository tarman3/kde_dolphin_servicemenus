#!/bin/bash

dir="$1"

agent_string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"

# link=`xclip -sel clip -o` # Get link from clipboard X11
link=`wl-paste`             # Get link from clipboard Wayland

if [[ "$link" != http* ]]; then
    kdialog --title "Downloading" --icon "error" --passivepopup "Clipboard does not contain link" 3
    exit
fi

fileName="${link##*/}"

sizeRemote=`HEAD -t 5 "$link" | grep '^Content-Length:' | sed s/"Content-Length: "//g`
echo $sizeRemote
sizeRemoteHuman=`echo $sizeRemote | perl -pe 's/(?<=\d)(?=(?:\d\d\d)+(?: |_|$))/ /g'`
echo $size

parameters=`yad --borders=20 --width=800 --title="wget - Download file" --item-separator="|" --form \
    --field="Link:RO" --field="File name:RO" --field="Size, bytes:RO" \
    --field="Continue downloading:CHK" --field="Custom User-Agent:CHK" --field="Dir to save:DIR" \
    \
    "$link"    "$fileName"    "$sizeRemoteHuman"    TRUE    FALSE    "$dir"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

continue=$( echo $parameters | awk -F '|' '{print $4}')
if [ "$continue" = TRUE ]
    then continue="--continue"
    else continue=""
fi

userAgent=$( echo $parameters | awk -F '|' '{print $5}')
if [ $userAgent ]; then user_agent="--user-agent=${agent_string}"; fi

dir=$( echo $parameters | awk -F '|' '{print $6}')

if [ $sizeRemote ]; then
    pathTmp="${dir}/${fileName}.wget-tmp"
    echo "$link" > "$pathTmp"
fi

konsole --hide-menubar -e "wget --no-verbose -o /tmp/wget-log --show-progress --random-wait \"${user_agent}\" $continue -P \"$dir\" \"$link\""

echo 2

sizeLocal=`stat -c %s "${dir}/${fileName}"`
echo $sizeLocal

if [ $sizeRemote ]; then
    if [ "$sizeLocal" = "$sizeRemote" ]; then
        rm --force "$pathTmp"
        kdialog --title "Downloading" --icon "checkbox" --passivepopup "Completed successfully" 3
    else
        kdialog --title "Downloading" --icon "error" --passivepopup "Not completed" 3
    fi

else
    kdialog --title "Downloading" --icon "question" --passivepopup "Completed ???" 3
fi
