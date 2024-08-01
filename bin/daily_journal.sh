#!/usr/bin/env sh
default_month_day=`date +%m-%d`
month_day="${1:-$default_month_day}"

notes_path="$HOME/_notebook"
cd "$notes_path"

# search ONLY files named like this:
ls journal*.md \
| sort \
| xargs rg \
--no-line-number \
--multiline \
--pcre2 \
--heading \
"^# \d{4}-$month_day\n([\s\S]*?)(?=\n# |\Z)" \
| perl -pe 's/^(\S+)\.(\S+)$/###### $1.$2/g' \
| glow