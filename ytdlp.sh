#!/bin/bash

utilities=('yad' 'yt-dlp')
for utility in ${utilities[@]}; do
    if ! command -v "$utility" 2>&1 >/dev/null; then
        kdialog --title "$utility" --icon "error" --passivepopup "Not found" 3
        exit 1
    fi
done

arg1="$1"
if [ -f  "$arg1" ]; then dir=${arg1%/*}
elif [ -d  "$arg1" ]; then dir="$arg1"
else dir="$HOME"
fi

echo "Save to: $dir"
cd "$dir"

arg2="$2"
if [ "$arg2" != "" ]; then
    link="$arg2"
else
    # link=`xclip -sel clip -o` # Get link from clipboard X11
    link=`wl-paste`             # Get link from clipboard Wayland
fi

link=${link%%&*}
echo "Link:    $link"
echo
if [[ "$link" != http* ]]; then
    kdialog --title "yt-dlp" --icon "error" --passivepopup "Clipboard does not contain link" 3
    exit
fi

if [[ `echo "$link" | grep 'list'` ]]
    then yt-dlp --playlist-items -1 --print '' --print '%(playlist_title)s' --print '%(playlist_count)s' \
    --print '' --print '%(title)s' --print '%(duration_string)s' --list-formats "$link"

    else yt-dlp --playlist-items -1 --print '' --print '%(title)s' --print '%(duration_string)s' \
    --list-formats "$link"
fi

echo
echo -e "Enter ID (18 or 139+134 or 18+t for download thumbnail), default 18:"
read formats

if [ "$formats" = "" ]; then
    formats=18
    echo $formats
fi

if [[ `echo "$link" | grep 'list'` ]]; then
    outputTemplate="%(playlist_index)s - %(title)s.%(ext)s"
    echo
    read -p "Press Enter to download all or Input playlist items [START]:[STOP][:STEP] (1:3,7,-5::2): " playlistItems
else
    outputTemplate="%(title)s.%(ext)s"
fi

if [ "$playlistItems" != "" ]; then playlistItems="--playlist-items $playlistItems"; fi

echo
if [ "${formats,,}" = "t" ]; then
    yt-dlp --write-thumbnail --skip-download "$link"
elif [[ `echo "$formats" | grep '+t'` ]]; then
    yt-dlp --console-title --retries 100 --retry-sleep 30 --continue --write-thumbnail $playlistItems --format "${formats/'+t'/}" "$link" --output "$outputTemplate"
else
    yt-dlp --console-title --retries 100 --retry-sleep 30 --continue $playlistItems --format "$formats" "$link" --output "$outputTemplate"
fi

kdialog --title "yt-dlp" --icon "checkbox" --passivepopup "Completed" 3

echo
read -p "Press Enter to exit"
