#!/bin/bash

arg1="$1"
if [ -f  "$arg1" ]; then dir=${arg1%/*}
elif [ -d  "$arg1" ]; then dir="$arg1"
else dir="$HOME"
fi

cd "$dir"

# link=`xclip -sel clip -o` # Get link from clipboard X11
link=`wl-paste`             # Get link from clipboard Wayland
link=${link%%&*}
echo "$link"
echo
if [[ "$link" != http* ]]; then
    kdialog --title "yt-dlp" --icon "error" --passivepopup "Clipboard does not contain link" 3
    exit
fi

file_name1="%(title)s.%(ext)s"
file_name2="%\(title\)s.%\(ext\)s"

if [[ `echo "$link" | grep 'list'` ]]
    then yt-dlp --playlist-items -1 --print '' --print '%(playlist_title)s' --print '%(playlist_count)s' \
    --print '' --print '%(title)s' --print '%(duration_string)s' --list-formats "$link"

    else yt-dlp --playlist-items -1 --print '' --print '%(title)s' --print '%(duration_string)s' \
    --list-formats "$link"
fi

echo
echo -e "Enter ID (default 18). E.g. 139+134 or 't' for download thumbnail"
read formats

if [ "$formats" = "" ]; then
    formats=18
    echo $formats
fi

if [[ `echo "$link" | grep 'list'` ]]; then
    outputTemplate="%(playlist_index)s - %(title)s.%(ext)s"
    echo
    read -p "Input playlist items [START]:[STOP][:STEP] (1:3,7,-5::2): " playlistItems
else
    outputTemplate="%(title)s.%(ext)s"
fi

if [ "$playlistItems" != "" ]; then playlistItems="--playlist-items $playlistItems"; fi

echo
if [ "${formats,,}" = "t" ]; then
    yt-dlp --write-thumbnail --skip-download "$link"
elif [[ `echo "$formats" | grep '+t'` ]]; then
    yt-dlp --console-title  --continue --write-thumbnail $playlistItems --format "${formats/'+t'/}" "$link" --output "$outputTemplate"
else
    yt-dlp --console-title  --continue $playlistItems --format "$formats" "$link" --output "$outputTemplate"
fi

echo
read -p "Press Enter to exit"
