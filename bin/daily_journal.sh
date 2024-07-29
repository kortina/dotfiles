#!/usr/bin/env sh
default_month_day=`date +%m-%d`
month_day="${1:-$default_month_day}"
# Search for journal entries dated with today's month and year:
cd ~/_notebook; 

ls journal*.md \
| sort \
| xargs rg \
--no-line-number \
--multiline \
--pcre2 \
--heading \
"^# \d{4}-$month_day\n([\s\S]*?)(?=\n# |\Z)" \
| glow