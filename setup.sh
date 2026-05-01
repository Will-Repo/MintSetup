#!/bin/bash

checkDependencies() {
    exit="false"

    if ! command -v fzf >/dev/null; then
        printf "%s\n" "fzf is not installed, see README for more info."
        exit="true"
    fi

    if ! command -v jq >/dev/null; then
        printf "%s\n" "jq is not installed, see README for more info."
        exit="true"
    fi

    if ! command -v tac >/dev/null; then
        printf "%s\n" "tac is not installed, see README for more info."
        exit="true"
    fi

    if [[ "$exit" == "true" ]]; then
        exit
    fi

    echo "All dependencies met"
}

showCategories() {
    dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
    mapfile -t categories < <(jq -r '.[].category' $dir/data/categories.json)

    #TODO: Use jq to get categories and description.
    while true; do
        # Show menu list of categories, and their contents and description in preview.
        choice=$(printf '%s\n' "${categories[@]}" | tac | fzf --preview "jq -r --arg category {} '.[] | select(.category == \$category) | .description' \"$dir/data/categories.json\"")

        case $choice in 
            "Install Selected")
                printf "Installing Selected"
                ;;
            "Exit")
                printf "Exiting"
                exit
                ;;
        esac
    done
}

#printf '%s\n' "${categories[@]}" | fzf --multi --bind 'tab:toggle' --preview 'echo {}'

# Start of function calls and program flow.
checkDependencies
showCategories
