#!/bin/bash

utilities=('meld')
for utility in ${utilities[@]}; do
    if ! command -v "$utility" 2>&1 >/dev/null; then
        kdialog --title "$utility" --icon "error" --passivepopup "Not found" 3
        exit 1
    fi
done

path1='/tmp/meld/arg1'
path2='/tmp/meld/arg2'

if [ -f "$path1" ]; then ARG1=$(cat "$path1"); fi
if [ -f "$path2" ]; then ARG2=$(cat "$path2"); fi

if [ "$ARG1" ]; then
    if [ "$ARG2" ];
        then meld "$ARG1" "$ARG2" "$1"
        else meld "$ARG1" "$1"
    fi

elif [ "$ARG2" ]; then
    meld "$ARG2" "$1"
fi

