#!/bin/bash

oldIFS="$IFS"
IFS=$';'

for file in $1; do

    if [ -f "$file" ] || [ -d "$file" ]
        then sudo rm --recursive "$file"
    fi

done

kdialog --title "Delete as root" --icon "checkbox" --passivepopup "Completed" 3
