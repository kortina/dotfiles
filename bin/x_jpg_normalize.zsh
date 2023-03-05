#!/usr/bin/env zsh

# https://s3.amazonaws.com/4rk/screen-shot-2023-03-05-14.54.12-7ajq7yxi.png
for file in *.(JPG|JPEG|jpeg)
do
    echo "mv $file ${file:r}.jpg"
    mv $file ${file:r}.jpg
done