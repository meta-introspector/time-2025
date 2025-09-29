#!/usr/bin/env bash

today() {
    NIX_HOME="/data/data/com.termux.nix/files/home/pick-up-nix2"
    NIX_DIR="$NIX_HOME/nix"
    CURRENT_YEAR_MONTH_DAY=$(date +'%Y/%m/%d')
    CURRENT_YEAR_MONTH=$(date +'%Y/%m')

    # Ensure the base nix directory exists
    mkdir -p "$NIX_DIR"

    # Define the full path to today's directory within the streamofrandom structure
    TODAY_FULL_PATH="$NIX_HOME/source/github/meta-introspector/streamofrandom/$CURRENT_YEAR_MONTH_DAY"
    CURRENT_MONTH_FULL_PATH="$NIX_HOME/source/github/meta-introspector/streamofrandom/$CURRENT_YEAR_MONTH"

    # Create today's directory if it doesn't exist
    mkdir -p "$TODAY_FULL_PATH"

    # Create/update symlink for current-month in ~/nix/
    ln -sf "$CURRENT_MONTH_FULL_PATH" "$NIX_DIR/current-month"

    # Create/update symlink for today in ~/nix/
    ln -sf "$TODAY_FULL_PATH" "$NIX_DIR/today"

    # Change to today's directory
    cd "$TODAY_FULL_PATH" || exit 1

    echo "$TODAY_FULL_PATH"
}

today
