#!/usr/bin/env bash
remark \
    --use preset-lint-markdown-style-guide \
    --use remark-reference-links \
    --use remark-frontmatter \
    "$@"
