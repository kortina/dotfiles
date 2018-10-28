#!/usr/bin/env bash
lowercase=""

while getopts ":l" opt; do
    case "$opt" in
        l)
            # lowercase option
            lowercase="| tr A-Z a-z"
            ;;
        \?)
            echo "Invalid option: -$OPTARG" 
            echo "Usage: slugify.sh [-l]"
            echo "    -l: transform all letters to lowercase"
            ;;
    esac
done

cmd="cat - | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' $lowercase"
eval $cmd
