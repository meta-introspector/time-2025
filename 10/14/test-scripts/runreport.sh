#!/usr/bin/env bash

sort log.txt | uniq -c | sort -n  > report1.txt
