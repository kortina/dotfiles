#!/usr/bin/env bash
# unslugify pasteboard to titlecase
pbpaste | ruby -e 'require "active_support/core_ext/string/inflections"; puts STDIN.read.gsub!(/-/, " ").titleize'
