#!/bin/bash

utilities=('yad' 'pdfimages')
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
path=${firstFile%/*}

parameters=`yad --borders=10 --width=500 --title="Export images from PDF" \
    --form --item-separator="|" --separator="," \
    --field="First page:NUM" --field="Last page:NUM" --field="Amount pages:NUM" --field="All pages:CHK" \
                "1"                         "1"                     "1"                 FALSE`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

firstPage=$(echo $parameters | awk -F ',' '{print $2}')
lastPage=$(echo $parameters | awk -F ',' '{print $3}')
quantity=$(echo $parameters | awk -F ',' '{print $4}')
all=$(echo $parameters | awk -F ',' '{print $5}')


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Export images from PDF" --progressbar "1 of $numberFiles  =>  ${firstFile##*/}" $numberFiles`

for file in "${array[@]}"; do

    dirExport="${file%.*}_images"
    pathExport="${dirExport}/img"

    mkdir "$dirExport"

    if [ "$all" = TRUE ]
    then pdfimages -all -p "$file" "$pathExport"

    elif [ $quantity -ge 1 ] && [ $lastPage -le $firstPage ]
    then pdfimages -all -p -f $firstPage -l $(($firstPage+$quantity-1)) "$file" "$pathExport"

    elif [ $lastPage -gt $firstPage ]
    then pdfimages -all -p -f $firstPage -l $lastPage "$file" "$pathExport"

    else pdfimages -all -p -f $firstPage -l $firstPage "$file" "$pathExport"
    fi

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "$counter of $numberFiles  =>  ${file##*/}"
    if [ ! `qdbus | grep ${dbusRef% *}` ]; then exit; fi

done

qdbus $dbusRef close

kdialog --title "Export images from PDF" --icon "checkbox" --passivepopup "Completed" 3
