#!/bin/bash

utilities=('srm')
for utility in ${utilities[@]}; do
    if ! command -v "$utility" 2>&1 >/dev/null; then
        kdialog --title "$utility" --icon "error" --passivepopup "Not found" 3
        exit 1
    fi
done

oldIFS="$IFS"
IFS=$';'

for file in $1; do

    if [ -f "$file" ] || [ -d "$file" ]
        then srm -rll "$file"
    fi

done

kdialog --title "Secure delete" --icon "checkbox" --passivepopup "Completed" 3
