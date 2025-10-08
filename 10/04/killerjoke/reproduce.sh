#!/bin/bash

cd "$(dirname "$0")" || exit
nix build -vvvvvvvvvv --debug .