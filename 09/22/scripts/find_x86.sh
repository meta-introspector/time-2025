#!/usr/bin/env bash

find . -name flake.nix -exec grep x86 {} \; -print 
