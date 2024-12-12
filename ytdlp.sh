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

yt-dlp --playlist-items 1 --get-title --get-id --get-duration --list-formats "$link"

echo
echo -e "Enter ID, (default 18). E.g. 139+134 or 't' for download thumbnail"
read formats

if [ "$formats" = "" ]; then
    formats=18
    echo $formats
fi

if [[ `echo "$link" | grep 'list'` ]]
    then outputTemplate="%(playlist_index)s - %(title)s.%(ext)s"
    else outputTemplate="%(title)s.%(ext)s"
fi

echo
if [ "${formats,,}" = "t" ]; then
    yt-dlp --write-thumbnail --skip-download "$link"
elif [[ `echo "$formats" | grep '+t'` ]]; then
    yt-dlp --console-title  --continue --write-thumbnail --format "${formats/'+t'/}" "$link" --output "$outputTemplate"
else
    yt-dlp --console-title  --continue --format "$formats" "$link" --output "$outputTemplate"
fi

echo
read -p "Press Enter to exit"
