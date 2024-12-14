#!/bin/bash

# Combine PDF and images to PDF
# Also try to decrypt PDF

utilities=('qpdf' 'pdfunite')
for utility in ${utilities[@]}; do
    if ! command -v "$utility" 2>&1 >/dev/null; then
        kdialog --title "$utility" --icon "error" --passivepopup "Not found" 3
        exit 1
    fi
done

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
# IFS="$oldIFS"

firstFile=${array[0]}
path=${firstFile%/*}
nameNoExt=${firstFile%.*}

tempDir="/tmp/pdfunite_$RANDOM"

decrypt=FALSE
useTempDir=FALSE

for file in "${array[@]}"; do
    ext=${file##*.}

    #Check for images in list of files
    if [ "${ext,,}" != "pdf" ]; then useTempDir=TRUE; fi

    #Check encrypted pdf in list
    if [ "${ext,,}" = "pdf" ]; then
        if [[ `qpdf --show-encryption "$file"` != "File is not encrypted" ]]; then
            decrypt=TRUE
            useTempDir=TRUE
        fi
    fi
done

parameters=`kdialog --geometry 300x200 --title="Combine to PDF" --inputbox "Save to" "${nameNoExt}_combine"`

exit_status=$?; if [ $exit_status != 0 ]; then exit; fi

newName="${parameters%.*}.pdf"

if [ "$useTempDir" = TRUE ] || [ "$decrypt" = TRUE ]; then
    mkdir "$tempDir"

    for file in "${array[@]}"; do
        fileName=${file##*/}
        nameNoExt=${fileName%.*}
        ext=${file##*.}

        if [ "${ext,,}" = "pdf" ]; then
            if [ "$encrypted" = TRUE ]
                then qpdf --decrypt "$file" "$tempDir/$fileName.pdf"
                else cp "$file" "$tempDir/$fileName"
            fi

            else magick "$file" "$tempDir/$fileName.pdf"
        fi
    done

    pdfunite "${tempDir}/*.pdf" "$newName"
    rm -r "$tempDir"

    else pdfunite $1 "$newName"

fi

kdialog --title "Combine to PDF" --icon "checkbox" --passivepopup "Completed" 3
