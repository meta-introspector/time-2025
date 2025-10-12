#!/usr/bin/env bash
grep process log.txt  | cut "-d'" -f2 | sort | uniq -c | sort -n > attrcount.txt
