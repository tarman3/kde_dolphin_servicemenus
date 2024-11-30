#!/bin/bash

dir="$1"

echo "Proccessing $dir"

cd "$dir"

if ! [ -d ".git" ]; then
    echo
    echo -e '\e[1;31m'"Not found $dir/.git"'\e[0m'
    echo
    read -p "Press ENTER to exit"
    exit 0
fi

echo
git --no-pager diff
echo
read -p "Press ENTER to download changes"

echo
echo -e '\e[1;32m'"git add ."'\e[0m'
git add .

echo
echo -e '\e[1;32m'"git commit --ammend"'\e[0m'
git commit --amend
echo

echo
echo -e '\e[1;32m'"git push --force"'\e[0m'
git push --force
echo

echo
read -p "Press ENTER to exit"