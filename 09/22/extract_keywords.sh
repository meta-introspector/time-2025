#!/usr/bin/env bash

grep -h -o -E '\w+' *_tiktok_tutorial.md | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -nr