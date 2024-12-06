#!/bin/bash

oldIFS="$IFS"
IFS=$';'

for file in $1; do

    if [ -f "$file" ] || [ -d "$file" ]
        then srm -rll "$file"
    fi

done

kdialog --title "Secure delete" --icon "checkbox" --passivepopup "Completed" 3
