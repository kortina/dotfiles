#!/usr/bin/env bash

# Desired package_name
usage() {
  echo "Usage: $0 [package_name]"
  echo "Runs yarn why and removes a bunch of extra output."
}
package_name="$1"
if [ "$package_name" = "" ]
then
    usage; exit
fi

set -v # start printing commands run
yarn why --no-progress "$package_name" | grep -v "^\["  | grep -v "Disk size" | grep -v "Number of" | grep -v "Done in" | grep -v "yarn why v"
