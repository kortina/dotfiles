#!/bin/bash

argument=$1

# default caffeination time in seconds
default_caffeination=3600

function running() {
(pgrep -x "caffeinate" > /dev/null 2>&1)
echo "$?"
}

if [ "$argument" = "off" ]; then
if [ "$(running)" -eq 0 ]; then
killall caffeinate > /dev/null 2>&1
echo "Disabling Caffeination"
else
echo "Not Caffeinated!"
fi
else
if [[ "$argument" =~ ^[0-9]+$ ]]; then
duration=$(( $argument * 3600 ))
time_display=$argument
else
duration=$default_caffeination
time_display=$(( $default_caffeination / 3600 ))
fi
if [ "$(running)" -eq 1 ]; then
echo "Caffeinating for $time_display Hour(s)"
else
echo "Already Caffeinated! Re-Caffeinating for $time_display Hour(s)"
fi
killall caffeinate > /dev/null 2>&1
nohup caffeinate -t $duration &>/dev/null &
fi
