#!/usr/bin/env bash

grep -h -oE '\[[^]]+\]\((https?://[^)]+)\)|https?://[^[:space:]]+' *.md | \
sed -E 's#.*\\\[[^]]+\\\]\((https?://[^)]+)\\\\.#\\1#g; t; s#^(https?://[^[:space:]]+).*#\\1#g' | \
grep -v '^/data/data/' | \
sed 's/)$//' | \
sort -u