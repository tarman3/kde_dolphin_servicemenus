#!/bin/bash

arg1="$1"

if [ -f  "$arg1" ]; then dir=${arg1%/*}
elif [ -d  "$arg1" ]; then dir="$arg1"
else
    kdialog --title "Downloading" --icon "error" --passivepopup "Can not get dir path" 3
    exit
fi

agent_string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36"

# link=`xclip -sel clip -o` # Get link from clipboard X11
link=`wl-paste`             # Get link from clipboard Wayland

if [[ "$link" != http* ]]; then
    kdialog --title "Downloading" --icon "error" --passivepopup "Clipboard does not contain link" 3
    exit
fi

fileName="${link##*/}"

sizeRemote=`HEAD -t 5 "$link" | grep '^Content-Length:' | sed s/"Content-Length: "//g`
sizeRemoteHuman=`echo $sizeRemote | perl -pe 's/(?<=\d)(?=(?:\d\d\d)+(?: |_|$))/ /g'`

parameters=`yad --borders=20 --width=800 --title="wget - Download file" \
    --form --item-separator="|" \
    --field="Link" --field="File name" --field="Size, bytes:RO" \
    --field="Continue downloading:CHK" --field="Custom User-Agent:CHK" --field="Dir to save:DIR" \
    "$link"    "$fileName"    "$sizeRemoteHuman"    TRUE    FALSE    "$dir"`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

fileName=$( echo $parameters | awk -F '|' '{print $2}')
continue=$( echo $parameters | awk -F '|' '{print $4}')
userAgent=$( echo $parameters | awk -F '|' '{print $5}')
dir=$( echo $parameters | awk -F '|' '{print $6}')

if [ "$continue" = TRUE ]; then continue='--continue'; else continue=''; fi

if [ $sizeRemote ]; then
    pathTmp="${dir}/${fileName}.wget-tmp"
    echo "$link" > "$pathTmp"
fi


if [ "$userAgent" ]
    then konsole --profile 'wget' --hide-menubar -e "wget --no-verbose -o /tmp/wget-log --show-progress --random-wait --user-agent=\"${agent_string}\" $continue -O \"$dir/$fileName\" $link"
    else konsole --profile 'wget' --hide-menubar -e "wget --no-verbose -o /tmp/wget-log --show-progress --random-wait $continue -O \"$dir/$fileName\" $link"
fi


sizeLocal=`stat -c %s "${dir}/${fileName}"`

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
