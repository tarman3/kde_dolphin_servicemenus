#!/bin/bash

utilities=('yad' 'montage')
for utility in ${utilities[@]}; do
    if ! command -v "$utility" 2>&1 >/dev/null; then
        kdialog --title "$utility" --icon "error" --passivepopup "Not found" 3
        exit 1
    fi
done

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
# IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}
name=${firstFile##*/}
nameNoExt=${name%.*}

for file in "${array[@]}"; do
    ext=${file##*.}
    if [ "${ext,,}" = 'jpg' ]; then break; fi
done

if [ "${ext,,}" = "png" ]
    then extForm="^png|jpg|webp|tiff|bmp"
    else extForm="^jpg|png|webp|tiff|bmp"
fi

parameters=`yad --borders=10 --width=400 --height=250 --title="Merge Images" \
    --item-separator="|" --separator="," --form  \
    --field="Direction:CB" --field="Space between images (px)" --field="Frame around images:CHK" \
    --field="Background color:CB" --field="Format:CB" --field="Lossy compress:CHK" \
    --field="Dir to save:DIR" --field="Help:LINK" \
    "^hor|vert" 5 FALSE "transparent|white|black" "$extForm" TRUE "$path" \
    "https://imagemagick.org/script/montage.php"`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

direction=$(echo $parameters | awk -F ',' '{print $1}')
space=$(echo $parameters | awk -F ',' '{print $2}')
frame=$(echo $parameters | awk -F ',' '{print $3}')
backgroundColor=$(echo $parameters | awk -F ',' '{print $4}')
ext=$(echo $parameters | awk -F ',' '{print $5}')
compress=$(echo $parameters | awk -F ',' '{print $6}')
dir=$( echo $parameters | awk -F ',' '{print $7}')

newPath="${dir}/${nameNoExt}_$direction.$ext"

numberFiles=${#array[@]}

if [ $direction = "vert" ]
    then opt1="+$space+$space"; opt2="1x${numberFiles}"
    else opt1="+$space+$space"; opt2="${numberFiles}x1"
fi

if [ "$frame" = TRUE ]
    then montage -background $backgroundColor -geometry $opt1 -tile $opt2 `echo "$1"` $ext: | montage - -background $backgroundColor -geometry $opt1 "$newPath"
    else montage -background $backgroundColor -geometry $opt1 -tile $opt2 `echo "$1"` $ext: | magick - -shave $space $newPath
fi

if [ "$compress" = TRUE ]; then
    if [ "${ext,,}" = 'png' ]; then pngquant --strip --force --quality=60-80 "$newPath" --output "$newPath"
    elif [ "${ext,,}" = 'jpg' ]; then jpegoptim --strip-all --overwrite --max=75 "$newPath"
    fi
fi

kdialog --title "Combine Images" --icon "checkbox" --passivepopup "Completed" 3
