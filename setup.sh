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
        category="${category//-/_}"

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
        
    # For each category, make temp file and add initial data.
    mkdir -p .temp
    for i in "${!categories[@]}"; do
        option="${categories[$i]// /_}"
        option="${option//-/_}"
        # Get the namesCategory array that stores all names in a certain category.
        declare -n arr="names${option}"
        # Get the current state of each name in the category selected.
        declare -n state="state${option}"
        # Declare array of what is displayed to the user, populate it with checkbox from state and name from names.
        declare -a items
        for j in "${!arr[@]}"; do
            if [[ ${state[j]} == "false" ]]; then
                items[j]="[] ${arr[j]}"
            else
                items[j]="[*] ${arr[j]}"
            fi
        done
        printf "%s\n" "${items[@]}" > "$dir/.temp/${categories[i]}"
    done
}

installSelected() {
    :
}

showCategories() {
    #TODO: Use jq to get categories and description.
    while true; do
        # Show menu list of categories, and their contents (including currently checkboxed) and description in preview. TODO: Show full list of selected options under install selected - get rid of checkboxes, just names.
        choice=$(printf "%s\n" "${categories[@]}" "${defaults[@]}" | tac | fzf --header="Current data directory: $dataPath" --preview "jq -r --arg category {} '.[] | select(.category == \$category) | .description' \"$dataPath/categories.json\" \"$dir/.default.json\"; cat "$dir/.temp/{}" 2>/dev/null")
        #TODO: Add checkboxes selected and list of tasks to preview.
        case $choice in 
            "Install Selected")
                printf "%s\n" "Installing Selected"
                installSelected
                ;;
            "Change Data Directory")
                choice=$(find ~ -type d ! -path "$dir" | fzf)
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
                while true; do
                    # TODO: Make this loop until exit selected.
                    # Remove spaces from chosen category.
                    option="${choice// /_}"
                    option="${option//-/_}"
                    # Get the namesCategory array that stores all names in a certain category.
                    declare -n arr="names${option}"
                    # Get the current state of each name in the category selected.
                    declare -n state="state${option}"
                    # Declare array of what is displayed to the user, populate it with checkbox from state and name from names.
                    declare -a items
                    for i in "${!arr[@]}"; do
                        if [[ ${state[i]} == "false" ]]; then
                            items[i]="[] ${arr[i]}"
                        else
                            items[i]="[*] ${arr[i]}"
                        fi
                    done
                    
                    # Display to user and get state back. TODO: Check {q} is best practice. FIX THIS.
                    #json='.[] | {json: .name, input: ($name | sub("^(\\[\\]|\\[\\*\\]) "; "")), match: (.name == ($name | sub("^(\\[\\]|\\[\\*\\]) "; "")))}'
                    json='.[] | select(.name == ($name | sub("^(\\[\\]|\\[\\*\\]) "; ""))) | "Description:\n\(.description)\n\nScript:\n\(.script | join("\n"))"'
                    selected=$(printf "%s\n" "${items[@]}" | tac | fzf --multi --bind 'tab:toggle' --header="Press esc or ctrl-q to exit." --preview "jq -r --arg name {} '$json' \"$dataPath/categories/$choice.json\"")
                    if [[ $? -eq 130 ]]; then 
                        break
                    fi

                    # Split selected into items. TODO: Make this able to have spaces perhaps?
                    mapfile -t indices < <(printf "%s\n" "$selected" | sed 's/^\(\[\]\|\[\*\]\) //')
                    for item in "${indices[@]}"; do 
                        index=$(jq -r --arg name "$item" 'map(.name) | index($name)' "$dataPath/categories/$choice.json")
                        if [[ $index == "null" ]]; then
                            echo "Option returned has null index. $item"
                        elif [[ ${state[index]} == "false" ]]; then
                            state[index]=true
                        elif [[ ${state[index]} == "true" ]]; then
                            state[index]=false
                        else 
                            printf "%s\n" "Invalid option returned from item selection. $item"
                        fi
                    done

                    # Get updated selection, output to temp file to be previewed from main menu.
                    for i in "${!arr[@]}"; do
                        if [[ ${state[i]} == "false" ]]; then
                            items[i]="[] ${arr[i]}"
                        else
                            items[i]="[*] ${arr[i]}"
                        fi
                    done
                    printf "%s\n" "${items[@]}" > "$dir/.temp/$choice"
                done
                ;;
        esac
    done
}

# Start of function calls and program flow.
checkDependencies
createArrays # Create arrays associated with each category, for storing current state of each checkbox.
showCategories

# Pass 2 arrays to jq, one with stuff from categories.json, and one with stuff defined here, store these seperately.
