#!/usr/bin/env bash
for i in {1..99}; do 
    echo "echo -e \"\033[0;${i}mMSG: ${i}\033[0m\""; 
    echo -e "\033[0;${i}mMSG: ${i}\033[0m"; 
done
