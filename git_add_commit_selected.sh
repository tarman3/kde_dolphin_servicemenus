#!/bin/bash

oldIFS="$IFS"
IFS=$';'
read -r -a array <<< "$1"
IFS="$oldIFS"

firstFile=${array[0]}
dir=${firstFile%/*}


echo "Proccessing with files:"
echo '-----------------------'
for file in "${array[@]}"; do
    echo -e '\E[1;32m'"$file"'\e[0m'
done
echo
echo

cd "$dir"

if ! [ -d ".git" ]; then
    echo
    echo -e '\e[1;31m'"Not found $dir/.git"'\e[0m'
    echo
    read -p "Press ENTER to exit "
    exit 0
fi

# if [[ -z `git --no-pager diff` ]] && [[ -z `git ls-files --others --exclude-standard` ]]; then
if [[ -z `git status --porcelain` ]]; then
    echo
    echo -e '\e[1;31m'"git diff not found changes"'\e[0m'
    echo
    read -p "Press ENTER to exit "
    exit 0
fi

echo "Changes:"
echo '--------'
git --no-pager diff

echo
echo "New files"
git ls-files --others --exclude-standard
echo

read -p "Press ENTER to start "

echo

for file in "${array[@]}"; do
    echo -e '\E[1;32m'"git add $file"'\e[0m'
    git add "$file"
done

echo
# echo -n "Input commit title: "'\e[0m'
# read commit_text
read -p "Input commit title: " commit_text

echo
echo -e '\E[1;32m'"git commit -m \"${commit_text}\""'\e[0m'
git commit -m "${commit_text}"
echo

echo
echo -e 'Press Enter to execute \E[1;32m'"git push"'\e[0m '
read
git push
echo

echo
read -p "Press ENTER to exit "
