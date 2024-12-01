#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=20 --width=300 --title="Hash Calculate" --item-separator="|" --separator="," \
    --form --field="Type:CB" --field="Save hash in one file:CHK" --field="Open result in Editor:CHK" \
    "^md5|sha256|sha1|sha224|sha384|sha512" TRUE TRUE`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

hashType=$( echo $parameters | awk -F ',' '{print $1}')
merge=$( echo $parameters | awk -F ',' '{print $2}')
open=$( echo $parameters | awk -F ',' '{print $3}')

numberFiles=${#array[@]}
dbusRef=`kdialog --title "Hash calculate" --progressbar "" $numberFiles`

for file in "${array[@]}"; do

    hash=$($hashType"sum" "$file" | awk '{print $1}')

    if [ "$merge" = TRUE ]
        then echo -e "$hashType    $hash    $file" >> "$firstFile.$hashType"
        else echo -e "$file\n$hashType\n$hash" > "$file.$hashType"
    fi

    if [ "$merge" = TRUE ] && [ "$open" = TRUE ]; then xdg-open "$firstFile.$hashType"
    elif [ "$merge" = FALSE ] && [ "$open" = TRUE ]; then xdg-open "$file.$hashType"
    fi

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Hash calculate" --icon "checkbox" --passivepopup "Completed" 3
