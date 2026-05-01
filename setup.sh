#!/bin/bash

# Get path to bash script directory, to allow script to be run from anywhere.
dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

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

createArrays() {
    # Get path from executable to the directory storing user config data (or example). If this file doesn't exist, create and populate it.
    if [[ ! -e $dir/.config ]]; then
        touch $dir/.config
        echo "dataDirectory=$dir/example/" >> $dir/.config
        dataPath="$dir/example"
    else 
        source $dir/.config
        dataPath="$dataDirectory"
    fi

    # Declare array of default categories.
    declare -g -a defaults
    # Fill array with all category names
    mapfile -t defaults < <(jq -r '.[].category' $dir/.default.json)
    # Check for errors when reading categories.
    if [[ $? -ne 0 ]]; then
        echo "Error: jq failed to parse $dir/.default.json"
        exit
    fi

    # Declare array of category names.
    declare -g -a categories
    # Fill array with all category names
    mapfile -t categories < <(jq -r '.[].category' $dataPath/categories.json)
    # Check for errors when reading categories.
    if [[ $? -ne 0 ]]; then
        echo "Error: jq failed to parse $dataPath/categories.json"
        exit
    fi

    # Declare arrays containing checkbox state and names for each element of each category.
    for i in "${!categories[@]}"; do
        # Replace all spaces in category names with underscores.
        category="${categories[$i]// /_}"

        #TODO: FIX THIS RUNNING FOR NON-CHECKBOX ONES, like exit
        # Declare array with category name, for containing task names.
        declare -g -n var="names${category}"
        # Populate array
        mapfile -t var < <(jq -r '.[].name' $dataPath/categories/"${categories[$i]}".json)

        # Declare array with category state, for containing task names.
        declare -g -n var2="state${category}"
        # Populate array
        for ((i=0; i<"${#var[@]}"; ++i));do 
            var2[$i]=false
        done
    done
        
    # declare -p categories
    # declare -p namesGames
    # declare -p stateGames

    # echo "${categories[@]}"
}

showCategories() {
    #TODO: Use jq to get categories and description.
    while true; do
        # Show menu list of categories, and their contents (including currently checkboxed) and description in preview.
        choice=$(printf "%s\n" "${categories[@]}" "${defaults[@]}" | tac | fzf --preview "jq -r --arg category {} '.[] | select(.category == \$category) | .description' \"$dataPath/categories.json\" \"$dir/.default.json\"")
        #TODO: Add checkboxes selected and list of tasks to preview.
        case $choice in 
            "Install Selected")
                printf "%s\n" "Installing Selected"
                ;;
            "Change Data Directory")
                choice=$(find "$dir" -type d ! -path "$dir" | fzf)
                # TODO: Check if valid folder.
                # TODO: Output to terminal if not, wait for confirmation.
                sed -i "s|^dataDirectory=.*|dataDirectory=$choice|" $dir/.config
                createArrays
                ;;
            "" | "Exit")
                printf "%s\n" "Exiting"
                exit
                ;;
            *)
                option="${choice// /_}"
                declare -n arr="names${option}"
                $(printf "%s\n" "${arr[@]}" | tac | fzf --multi --preview "jq -r --arg name {} '.[] | select(.name == \$name) | \"\(.description):\n\(.script)\"' \"$dataPath/categories/$option.json\"")
                ;;
        esac
    done
}

#printf '%s\n' "${categories[@]}" | fzf --multi --bind 'tab:toggle' --preview 'echo {}'

# Start of function calls and program flow.
checkDependencies
createArrays # Create arrays associated with each category, for storing current state of each checkbox.
showCategories

# Pass 2 arrays to jq, one with stuff from categories.json, and one with stuff defined here, store these seperately.
