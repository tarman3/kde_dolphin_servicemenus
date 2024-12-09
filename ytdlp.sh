#!/bin/bash

arg1="$1"
if [ -f  "$arg1" ]; then dir=${arg1%/*}
elif [ -d  "$arg1" ]; then dir="$arg1"
else
    kdialog --title "yt-dlp" --icon "error" --passivepopup "Can not get dir path" 3
    exit
fi

cd "$dir"

# link=`xclip -sel clip -o` # Get link from clipboard X11
link=`wl-paste`             # Get link from clipboard Wayland
link=${link%%&*}
echo "$link"
echo
if [[ "$link" != http* ]]; then
    kdialog --title "Downloading" --icon "error" --passivepopup "Clipboard does not contain link" 3
    exit
fi

file_name1="%(title)s.%(ext)s"
file_name2="%\(title\)s.%\(ext\)s"

yt-dlp -F "$link"

echo
echo -e "Enter ID, e.g. 18 or 139+134"
read codes
echo

yt-dlp -f "$codes" "$link"
