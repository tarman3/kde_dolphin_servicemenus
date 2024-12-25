#!/bin/bash

oldIFS="$IFS"
IFS=$';'

for file in $1; do

    if [ -f "$file" ] || [ -d "$file" ]
        then sudo rm --force --recursive --verbose "$file"
    fi

done

echo
read -p "Press Enter to exit"

# kdialog --title "Delete as root" --icon "checkbox" --passivepopup "Completed" 3
