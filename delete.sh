#!/bin/bash

IFS=$';'
read -r -a array <<< "$1"

for file in ${array[@]}; do
    if [ -n "$file" ]; then
        srm -rll "$file"
    fi
done

kdialog --title "Secure delete" --icon "checkbox" --passivepopup "Completed" 3
