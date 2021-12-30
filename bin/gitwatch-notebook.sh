#!/usr/bin/env bash
set -e

# config:
remote="origin" # NB: this should be "origin" not something like "git@github.com:kortina/_notebook.git"
branch="master"
path="$HOME/_notebook"
secs="300" # at most push to github every 5 minutes

function commit_changes {
    cd "$path"

    # extract highland files:
    ls -1 | grep "\.highland$" | xargs -I {} x_highland_2_fountain.py {}

    # return if no changes
    [ -z "$(git status --porcelain=v1 2>/dev/null)" ] && return

    # get status to print
    git status

    # add
    msg="autocommit `date '+%Y-%m-%d %H:%M:%S'` by gitwatch"
    git add --all .

    # don't abort on error
    set +e

    # commit
    git commit -m "$msg"

    # push
    git push "$remote" "$branch"

    # resume abort on error
    set -e

    echo "-------------------------------------------------------------------------------"
    
}

echo "-------------------------------------------------------------------------------"
echo "autocommit changes at:"
echo "  $path"
echo "to:"
echo "  $remote $branch"
echo "every:"
echo "  $secs secs"
echo "-------------------------------------------------------------------------------"
echo ""

while true; do
    commit_changes
    sleep "$secs"
done

# run:
# gitwatch -s "$secs" -r "$remote" "$path"
