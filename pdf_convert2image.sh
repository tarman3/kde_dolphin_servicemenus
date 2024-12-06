#!/bin/bash

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=10 --width=500 --title="Convert PDF to image" \
    --form --item-separator="|" --separator="," \
    --field="First page:NUM" --field="Last page:NUM" --field="Amount pages:NUM" --field="All pages:CHK" \
    --field="dPI:NUM" --field="Format:CB" \
    "1" "1" "1" FALSE "150|50..2400|50" "^png|jpeg|tiff|svg"`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

firstPage=$( echo $parameters | awk -F ',' '{print $1}')
lastPage=$( echo $parameters | awk -F ',' '{print $2}')
quantity=$( echo $parameters | awk -F ',' '{print $3}')
all=$( echo $parameters | awk -F ',' '{print $4}')
dpi=$( echo $parameters | awk -F ',' '{print $5}')
format=$( echo $parameters | awk -F ',' '{print $6}')


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Compress PDF" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    if [ "$all" = TRUE ]
    then pages=""

    elif [ $quantity -ge 1 ] && [ $lastPage -le $firstPage ]
    then pages="-f $firstPage -l $(($firstPage+$quantity-1))"

    elif [ $lastPage -gt $firstPage ]
    then pages="-f $firstPage -l $lastPage"

    else pages="-f $firstPage -l $firstPage"
    fi

    pdftocairo -$format -r $dpi $pages "$file" "${file%.*}-${dpi}dpi"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "PDF Compress" --icon "checkbox" --passivepopup "Completed" 3
