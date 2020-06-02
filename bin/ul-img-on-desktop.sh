#!/usr/bin/env bash
# insert the .s3s. bit into filename
# so s3screenshots.py uploads it

_main() {
    cd "$HOME/Desktop"
    orig=`basename "$1"`
    # get the extension
    extension="${orig##*.}"                     
    # get the name w/o the extension
    name="${orig%.*}"                       
    new="${name}.s3s.${extension}"
    # create new file instead of mv so s3screenshots.py sees it
    cp "$orig" "$new"   
    # DO NOT: remove orig file (s3screenshots removes the new one)
    # rm "$orig"                                  
}

# input URL should be EITHER:
# first arg to this script, OR:
# URL in STDIN
if [ $# = 0 ]
then
    while IFS= read -r line; do
        _main "$line"
    done < /dev/stdin
    [[ {$line} ]] && _main "$line" # read the final line (if no trailing newline)
    # see: https://stackoverflow.com/a/42631838/382912
else
    _main "$1"
fi
