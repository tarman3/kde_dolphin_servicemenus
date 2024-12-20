#!/bin/bash

dir="$1"

echo "Proccessing $dir"
echo

cd "$dir"

if ! [ -d ".git" ]; then
    echo
    echo -e '\E[1;31m'"Not found $dir/.git"'\E[0m'
    echo
    read -p "Press ENTER to exit "
    exit 0
fi


# if [[ -z `git --no-pager diff` ]] && [[ -z `git ls-files --others --exclude-standard` ]]; then
if [[ -z `git status --porcelain` ]]; then
    echo
    echo -e '\E[1;31m'"git diff not found changes"'\E[0m'
    echo
    read -p "Press ENTER to exit "
    exit 0
fi

echo "Changes"
git --no-pager diff
echo

newFiles=`git ls-files --others --exclude-standard`
if [ "$newFiles" ]; then
    echo -e '\E[1;32m'"New files"'\E[0m'
    echo $newFiles
else
    echo -e '\E[1;32m'"No new files"'\E[0m'
fi

echo
read -p "Press ENTER to start "

echo
echo -e '\E[1;32m'"git add ."'\E[0m'
git add .

echo
read -p "Input commit title: " commit_text

echo
echo -e '\E[1;32m'"git commit -m \"${commit_text}\""'\E[0m'
git commit -m "${commit_text}"
echo

echo
echo -e 'Press Enter to execute \E[1;32m'"git push"'\E[0m '
read
git push
echo

echo
read -p "Press ENTER to exit "
