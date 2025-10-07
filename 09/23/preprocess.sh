#!/usr/bin/env bash

sed -E '
  s/"?: {/"?: {\n/g;  # Newline after opening brace for path or n-gram type
  s/([0-9]-gram): {/\1: {\n/g; # Newline after n-gram type opening brace
  s/}, "/},\n"/g;  # Newline after closing brace for a block, before next key
  s/},/},\n/g;    # Newline after closing brace for a block, before next comma
  s/}}}/}\n}/g;    # Newline between two closing braces
  s/, /,\n/g;         # Split n-gram lists by ", "
  /^\s*$/d;          # Remove empty lines
' "$1"