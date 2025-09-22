#!/usr/bin/env bash

grep -h -oE 'https://en.wikipedia.org/wiki/[^[:space:]]+' *_tiktok_tutorial.md | sort -u