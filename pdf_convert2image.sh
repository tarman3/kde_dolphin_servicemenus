#!/bin/bash

old_ifs="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$old_ifs"

firstFile=${array[0]}
path=${firstFile%/*}

parameters=`yad --borders=10 --width=500 --title="Преобразовать PDF в изображения" --text="Введите параметры" \
    --form --item-separator="|" --separator="," \
    --field=":LBL" --field="First page:NUM" --field="Last page:NUM" --field="Amount pages:NUM" --field="All pages:CHK" \
    --field="dPI:NUM" --field="Format:CB" \
    "" "1" "1" "1" FALSE "150|50..2400|50" "^png|jpeg|tiff"`

exit_status=$?
if [ $exit_status != 0 ]; then exit; fi

firstpage=$( echo $parameters | awk -F ',' '{print $2}')
lastpage=$( echo $parameters | awk -F ',' '{print $3}')
quantity=$( echo $parameters | awk -F ',' '{print $4}')
all=$( echo $parameters | awk -F ',' '{print $5}')
dpi=$( echo $parameters | awk -F ',' '{print $6}')
format=$( echo $parameters | awk -F ',' '{print $7}')


numberFiles=${#array[@]}
dbusRef=`kdialog --title "Compress PDF" --progressbar "" $numberFiles`

for file in "${array[@]}"; do

    if [ "$all" = TRUE ]
    then pages=""

    elif [ $quantity -ge 1 ] && [ $lastpage -eq 1 ]
    then pages="-f $firstpage -l $(($firstpage+$quantity-1))"

    elif [ $lastpage -gt $firstpage ]
    then pages="-f $firstpage -l $lastpage"

    else pages="-f $firstpage -l $firstpage"
    fi

    pdftocairo -$format -r $dpi $pages "$file" "${file%.*}-${dpi}dpi"

    counter=$(($counter+1))
    qdbus $dbusRef Set "" value $counter
    qdbus $dbusRef setLabelText "Completed $counter of $numberFiles"

done

qdbus $dbusRef close

kdialog --title "PDF Compress" --icon "checkbox" --passivepopup "Completed" 3
