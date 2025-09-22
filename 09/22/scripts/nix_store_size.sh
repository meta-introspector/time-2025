#!/usr/bin/env bash

source env.sh

ls -laS /nix/store/ > ${PROJECT_ROOT}/index/sizes.txt
