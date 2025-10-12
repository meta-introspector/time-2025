#!/bin/env bash
find . -type f | grep -v '/.git/' > index/files.txt
