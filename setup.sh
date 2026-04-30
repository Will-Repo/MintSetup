#!/bin/sh

checkDependencies() {
    exit="false"

    if ! command -v gum >/dev/null; then
        printf "%s\n" "Gum is not installed, see README for more info."
        exit="true"
    fi

    if ! command -v jq >/dev/null; then
        printf "%s\n" "JQ is not installed, see README for more info."
        exit="true"
    fi

    if "$exit" = "true"; then
        exit
    fi
}


# Start of function calls and program flow.
checkDependencies
