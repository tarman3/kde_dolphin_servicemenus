#!/bin/bash

# old_ifs="$IFS"
# IFS=$';'
# read -r -a array <<< "$1"
# IFS="$old_ifs"

# firstFile=${array[0]}
# path=${firstFile%/*}

# for file in "${array[@]}"; do

#     if [ -n "$file" ]; then
#         srm -rll "$file"
#     fi
# done

# kdialog --title "Secure delete" --icon "checkbox" --passivepopup "Completed" 3
echo >> /tmp/test
echo $1 >> /tmp/test
echo --- >> /tmp/test

for file in "$@"; do
    echo $file >> /tmp/test
done
