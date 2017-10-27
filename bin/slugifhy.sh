#!/usr/bin/env bash
cat - | sed -e 's/[^[:alnum:]]/-/g' | tr -s '-' | tr A-Z a-z
