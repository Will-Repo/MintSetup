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
    rm -rf $dir/.temp/*
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

runScripts() {
    # Set mode to empty string if not passed in. Function utilises "output", for when wanting terminal output.
    local mode="${1:-}"

    for i in "${!categories[@]}"; do
        option="${categories[$i]// /_}"
        option="${option//-/_}"
        declare -n arr="names${option}"
        declare -n state="state${option}"

        for j in "${!arr[@]}"; do
            if [[ ${state[j]} == "true" ]]; then
                # If array, flatten it. If string, return.
                mapfile -t script < <(jq --arg name "${arr[$j]}" -r '.[] | select(.name == $name) | .script | if type == "array" then .[] else . end' "$dataPath/categories/${categories[i]}.json")
                stringScript=$(printf "%s\n" "${script[@]}")
                # Execute script, log all commands to file, and errors seperately.
                if [[ "$mode" == "output" ]]; then
                    bash -euo pipefail -x -c "$stringScript"
                else
                    bash -euo pipefail -x -c "$stringScript" > >(tee -a "$dir/.temp/all.log" > /dev/null) 2> >(tee -a "$dir/.temp/errors.log" | tee -a "$dir/.temp/all.log" > /dev/null)
                fi
            fi
        done
    done
    set +x

    
    if [[ "$mode" == "output" ]]; then
        printf "%s\n" "[COMPLETE] All commands finished, press Enter to continue."
        read
    else
        touch "$dir/.temp/tmux-exit"
    fi
}

installSelected() {
    # Clear and create files for storing log info - stdout (and stderr), and just stderr.
    > "$dir/.temp/all.log"
    > "$dir/.temp/errors.log"

    #TODO: Add progress bar to pane 1.

    if command -v tmux >/dev/null; then
        # Create tmux session, with one pane that runs scripts and outputs instructions, another pane showing just stderr, and one showing all that would be outputted to terminal. User can resize. Also allow non-tmux if not installed.
        # Run scripts in background.
        runScripts &
        # Display script data to user.
        tmux kill-session -t logs >/dev/null
        #Use bash per-command environment variable to pass in dir path into single quotes.
        DIR="$dir" tmux new-session -d -x 200 -y 60 -s logs "tail -f \"\$DIR/.temp/errors.log\"" \; \
        split-window -h -t 0 "tail -f \"\$DIR/.temp/all.log\"" \; \
        select-layout even-horizontal \; \
        split-window -f -t 0 -l 6 "bash -c '
            while [ ! -f \"\$DIR/.temp/tmux-exit\" ]; do
                sleep 1
            done
            printf \"All commands executed.\nPress Enter to exit tmux.\"
            read
            tmux kill-session -t logs
        '" \; \
        select-pane -t 2 \; \
        set-option -t logs mouse on \; \
        attach -t logs
    else
        # Run scripts in terminal, outputtng to stdout and stderr as normal.
        runScripts "output"
    fi
    rm -f "$dir/.temp/tmux-exit"
        
    #TODO: Print number of errors (how many scripts failed), and ask if user wants to continue, saying more installs will overrite log, so look now, or log to timestamp.
}

showCategories() {
    while true; do
        # Show menu list of categories, and their contents (including currently checkboxed) and description in preview.
        choice=$(
            printf "%s\n" "${categories[@]}" "${defaults[@]}" \
            | tac \
            | fzf \
                --header="Current data directory: $dataPath" \
                --preview "jq -r --arg category {} '.[] | select(.category == \$category) | .description' \"$dataPath/categories.json\" \"$dir/.default.json\";
                          cat "$dir/.temp/{}" 2>/dev/null;
                          if [[ {} == \"Install Selected\" ]]; then
                              printf \"\n%s\n\" \"Currently Selected:\"
                              cat "$dir/.temp/*" 2>/dev/null | grep '^\[\*\]' | sed 's/^\(\[\]\|\[\*\]\) //'
                          fi" \
        )
        case $choice in 
            "Install Selected")
                printf "%s\n" "Installing Selected"
                installSelected
                ;;
            "Change Data Directory")
                choice=$(find ~ -type d ! -path "$dir" | fzf)
                # If chosen directory contains categories.json file, accept it.
                if [[ -f "$choice/categories.json" ]]; then
                    sed -i "s|^dataDirectory=.*|dataDirectory=$choice|" $dir/.config
                    createArrays
                else
                    printf "%s\n" "Invalid directory $choice - does not contain categories.json file."
                fi
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
                    
                    # Display to user and get state back. 
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
checkDependencies # Check required dependencies - optionals checked when they would be used.
createArrays # Create arrays associated with each category, for storing current state of each checkbox. Also create temp files for each category.
showCategories # Display menu.
