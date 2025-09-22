#!/usr/bin/env bash

# This script manages the list of muses for task generation.

function list_muses() {
    echo "DigitalMycology"
    echo "Calliope"
    echo "Clio"
    echo "Erato"
    echo "Euterpe"
    echo "Melpomene"
    echo "Polyhymnia"
    echo "Terpsichore"
    echo "Thalia"
    echo "Urania"
}

case "$1" in
    --list)
        list_muses
        ;;
    *)
        echo "Usage: $0 [--list]"
        exit 1
        ;;
esac