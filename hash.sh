#!/bin/bash

utilities=('yad')
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

parameters=`yad --borders=20 --width=300 --title="Hash Calculate" --item-separator="|" --separator="," \
    --form --field="Type:CB" --field="Save result in one file:CHK" --field="Open result in Editor:CHK" \
    --field="Save to /tmp:CHK"    "^md5|sha256|sha1|sha224|sha384|sha512"    TRUE    TRUE    TRUE`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

hashType=$( echo $parameters | awk -F ',' '{print $1}')
merge=$( echo $parameters | awk -F ',' '{print $2}')
open=$( echo $parameters | awk -F ',' '{print $3}')
tmp=$( echo $parameters | awk -F ',' '{print $4}')

if [ "$tmp" = TRUE ]
    then dir="/tmp"
    else dir="${firstFile%/*}"
fi


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Hash calculate" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    hash=$($hashType"sum" "$file" | awk '{print $1}')

    if [ "$merge" = TRUE ]; then
        path="${dir}/${firstFile##*/}.$hashType"
        echo -e "$hashType    $hash    $file" >> "$path"
    else
        path="${dir}/${file##*/}.$hashType"
        echo -e "$file\n$hashType\n$hash" > "$path"
    fi

    if [ "$open" = TRUE ]; then xdg-open "$path"; fi

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Hash calculate" --icon "checkbox" --passivepopup "Completed" 3
