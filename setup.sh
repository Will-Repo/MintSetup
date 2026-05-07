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

detectPkgm() {
    pkgm=""
    if command -v apt >/dev/null; then
        pkgm="apt"
    elif command -v dnf /dev/null; then
        pkgm="dnf"
    elif command -v pacman /dev/null; then
        pkgm="pacman"
    else 
        pkgm="unknown"
    fi
}

detectInit() {
    init=""
    exe=$(cat /proc/1/comm 2>/dev/null)
    case "$exe" in
        *dinit*) init="dinit" ;;
        *systemd*) init="systemd" ;;
        *openrc*) init="openrc" ;;
        *epoch*) init="epoch" ;;
        *runit*) init="runit" ;;
        *s6*) init="s6" ;;
        *) init="unknown" ;;
    esac
}

detectDs() {
    ds=""
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
        ds="wayland"
    elif [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
        ds="x11"
    else
        ds="unknown"
    fi
}

getPkgm() {
    type="$1"
    if [[ $type == "unknown" ]]; then
        header="Could not determine system package manager, please select the correct option."
    else
        header="Please select the correct option."
    fi
    input=$(printf "%s\n" "Detect automatically" "apt" "dnf" "pacman" "other" | tac | fzf --header="$header")
    if [[ $input == "other" ]]; then 
        printf "%s\n" "Please enter your package manager command: "
        read pkgm 
    elif [[ $input == "Detect automatically" ]]; then
        detectPkgm
    else
        pkgm=$input
    fi
}

getInit() {
    type="$1"
    if [[ $type == "unknown" ]]; then
        header="Could not determine init system, please select the correct option."
    else
        header="Please select the correct option."
    fi
    input=$(printf "%s\n" "Detect automatically" "dinit" "systemd" "openrc" "epoch" "runit" "s6" "other" | tac | fzf --header="$header")
    if [[ $input == "other" ]]; then 
        printf "%s\n" "Please enter your init system: "
        read init 
    elif [[ $input == "Detect automatically" ]]; then
        detectInit
    else
        init=$input
    fi
}

getDs() {
    type="$1"
    if [[ $type == "unknown" ]]; then
        header="Could not determine system display server, please select the correct option."
    else
        header="Please select the correct option."
    fi
    input=$(printf "%s\n" "Detect automatically" "wayland" "x11" "other" | tac | fzf --header="$header")
    if [[ $input == "other" ]]; then 
        printf "%s\n" "Please enter your display server (in format required by your scripts): "
        read ds 
    elif [[ $input == "Detect automatically" ]]; then
        detectDs
    else
        ds=$input
    fi
}

determineSystem() {
    if ! grep -q "pkgm" "$dir/.temp/.config"; then
        # Get package manager
        detectPkgm

        # Get init system. #TODO: Permission errors?
        detectInit
        
        # Get display server
        detectDs
        
        #echo $pkgm $init $ds
        # If any are unknown, let user select, if they select other, let them input on terminal and use that instead (they need to ensure this is consistent with their script.
        if [[ $pkgm == "unknown" ]]; then 
            getPkgm "unknown"
        fi

        if [[ $init == "unknown" ]]; then 
            getInit "unknown"
        fi

        if [[ $ds == "unknown" ]]; then 
            getDs "unknown"
        fi
        echo "pkgm=$pkgm" >> "$dir/.temp/.config"
        echo "init=$init" >> "$dir/.temp/.config"
        echo "ds=$ds" >> "$dir/.temp/.config"
    fi
    source "$dir/.temp/.config"
}

createArrays() {
    # Get path from executable to the directory storing user config data (or example). If this file doesn't exist, create and populate it.
    if ! grep -q "dataDirectory" "$dir/.temp/.config"; then
        echo "dataDirectory=$dir/example/" >> "$dir/.temp/.config"
    fi
    source "$dir/.temp/.config"

    # Declare array of default categories.
    declare -g -a defaults
    # Fill array with all category names
    mapfile -t defaults < <(jq -r '.[].category' "$dir/.default.json")
    # Check for errors when reading categories.
    if [[ $? -ne 0 ]]; then
        echo "Error: jq failed to parse $dir/.default.json"
        exit
    fi

    # Declare array of category names.
    declare -g -a categories
    # Fill array with all category names
    mapfile -t categories < <(jq -r '.[].category' "$dataDirectory/categories.json")
    # Check for errors when reading categories.
    if [[ $? -ne 0 ]]; then
        echo "Error: jq failed to parse $dataDirectory/categories.json"
        exit
    fi

    # For each category, make temp file and add initial data.
    mkdir -p "$dir/.temp"
    rm -rf "$dir/.temp/*"
    # Declare arrays containing checkbox state and names for each element of each category.
    for i in "${!categories[@]}"; do
        # Replace all spaces in category names with underscores.
        category="${categories[$i]// /_}"
        category="${category//[^a-zA-Z0-9_]/_}"

        # Declare array with category name, for containing task names.
        declare -n names="names${category}"
        # Populate array
        mapfile -t names < <(jq -r '.[].name' "$dataDirectory"/categories/"${categories[$i]}".json)

        # Declare array with category state, for containing task names.
        declare -n state="state${category}"
        # Populate array - for each element in names, add a corresponding state entry - defaulting to false.
        for j in "${!names[@]}";do 
            state[j]=false
        done
        
        # Declare array of what is displayed to the user, populate it with checkbox from state and name from names.
        unset items
        declare -a items
        for j in "${!names[@]}"; do
            if [[ ${state[j]} == "false" ]]; then
                items[j]="[] ${names[j]}"
            else
                items[j]="[*] ${names[j]}"
            fi
        done
        printf "%s\n" "${items[@]}" > "$dir/.temp/${categories[$i]}"
    done

    # Declare submenu categories
    declare -g -a defaultsConfig
    # Fill array with all category names
    mapfile -t defaultsConfig < <(jq -r '.[].category' "$dir/.defaultConfigsMenu.json")
    # Check for errors when reading categories.
    if [[ $? -ne 0 ]]; then
        echo "Error: jq failed to parse $dir/.defaultConfigsMenu.json"
        exit
    fi
}

runScripts() {
    # Set mode to empty string if not passed in. 
    local mode="${1:-}"
    # If mode is "execute", run the scripts straight away. Otherwise, create file representation of all commands to execute in tmux.
    
    if [[ "$mode" != "execute" ]]; then
        > "$dir/.temp/.scripts"
    fi
    for i in "${!categories[@]}"; do
        option="${categories[$i]// /_}"
        option="${option//[^a-zA-Z0-9_]/_}"

        declare -n arr="names${option}"
        declare -n state="state${option}"

        for j in "${!arr[@]}"; do
            if [[ ${state[j]} == "true" ]]; then
                # If array, flatten it. If string, return.
                mapfile -t script < <(jq --arg name "${arr[$j]}" -r '.[] | select(.name == $name) | .script | if type == "array" then .[] else . end' "$dataDirectory/categories/${categories[i]}.json")
                stringScript=$(printf "%s\n" "${script[@]}")
                # Execute script, log all commands to file, and errors seperately.
                if [[ "$mode" == "execute" ]]; then
                    DIR="$dir" PKGM="$pkgm" INIT="$init" DS="$ds" bash -euo pipefail -x -c "$stringScript" > >(tee -a "$dir/.temp/all.log") 2> >(tee -a "$dir/.temp/errors.log" | tee -a "$dir/.temp/all.log")
                else
                    printf "NEW SCRIPT\n" >> "$dir/.temp/.scripts"
                    printf "%s\n" "${stringScript[@]}" >> "$dir/.temp/.scripts"    
                fi
            fi
        done
    done

    if [[ "$mode" == "execute" ]]; then
        printf 'All commands executed.\nPress Enter to return to menu.'
        read
    fi
}

runAllScripts() {
    # Declare string for current script block
    local block=""
    # Create array of all scripts
    mapfile -t lines < <(cat "$DIR/.temp/.scripts")
    #declare -p lines
    #printf "%b\n" "${lines[@]}"
    #echo "$PKGM"
    for line in "${lines[@]}"; do 
        if [[ "$line" == "NEW SCRIPT" ]]; then
            DIR="$DIR" PKGM="$PKGM" INIT="$INIT" DS="$DS" bash -euo pipefail -x -c "$block"  > >(tee -a "$DIR/.temp/all.log") 2> >(tee -a "$DIR/.temp/errors.log" >> "$DIR/.temp/all.log") || true # Catch errors, prevents tmux closing.
            block=""
        else 
            block+="$line"$'\n'
        fi
    done
    DIR="$DIR" PKGM="$PKGM" INIT="$INIT" DS="$DS" bash -euo pipefail -x -c "$block" > >(tee -a "$DIR/.temp/all.log") 2> >(tee -a "$DIR/.temp/errors.log" >> "$DIR/.temp/all.log") || true
}

installSelected() {
    # Clear and create files for storing log info - stdout (and stderr), and just stderr.
    > "$dir/.temp/all.log"
    > "$dir/.temp/errors.log"

    #TODO: Add progress bar to pane 1.

    if command -v tmux >/dev/null; then
        # Create tmux session, with one pane that runs scripts and outputs instructions, another pane showing just stderr, and one showing all that would be outputted to terminal. User can resize. Also allow non-tmux if not installed.
        # Generate file of scripts to execute.
        runScripts
        # Pass in function to execute each script to tmux, alongside a file representation of all scripts to execute.
        
        export -f runAllScripts
        # Display script data to user.
        tmux kill-session -t logs >/dev/null
        #Use bash per-command environment variable to pass in dir path into single quotes.
        DIR="$dir" PKGM="$pkgm" INIT="$init" DS="$ds" tmux new-session -d -x 200 -y 60 -s logs "tail -f \"\$DIR/.temp/errors.log\"" \; \
        set-option -g pane-border-status top \; \
        select-pane -T "Errors (xtrace + stderr):" \; \
        split-window -h -t 0 "tail -f \"\$DIR/.temp/all.log\"" \; \
        select-pane -T "All output (stdout + xtrace + stderr):" \; \
        select-layout even-horizontal \; \
        split-window -f -t 0 -l 6 "bash -c \"
            runAllScripts
            printf 'All commands executed.\nPress Enter to exit tmux.'
            read
            tmux kill-session -t logs
        \"" \; \
        select-pane -t 2 \; \
        select-pane -T "Interactive pane" \; \
        set-option -t logs mouse on \; \
        attach -t logs
    else
        # Run scripts in terminal, outputtng to stdout and stderr as normal.
        runScripts "execute"
    fi
        
    #TODO: Print number of errors (how many scripts failed), and ask if user wants to continue, saying more installs will overrite log, so look now, or log to timestamp.
}

toggle=1
toggleAll() {
    for i in "${!categories[@]}"; do
        # Replace all spaces in category names with underscores.
        category="${categories[$i]// /_}"
        category="${category//[^a-zA-Z0-9_]/_}"


        declare -n names="names${category}"
        # Populate array
        mapfile -t names < <(jq -r '.[].name' "$dataDirectory"/categories/"${categories[$i]}".json)

        # Declare array with category state, for containing task names.
        declare -n state="state${category}"
        # Populate array - for each element in names, add a corresponding state entry - defaulting to false.
        for j in "${!names[@]}";do 
            if [[ $toggle -eq 1 ]]; then
                state[j]=true
            else 
                state[j]=false
            fi
        done
    
        unset items
        declare -a items
        for j in "${!names[@]}"; do
            if [[ ${state[j]} == "false" ]]; then
                items[j]="[] ${names[j]}"
            else
                items[j]="[*] ${names[j]}"
            fi
        done
        printf "%s\n" "${items[@]}" > "$dir/.temp/${categories[$i]}"
    done
    
    ((toggle *= -1))
}

# TODO: Create interactive terminal in tmux. Write all commands to be executed to a file - seperated by script. Give tmux script that iterates through this file and runs it, writing to the relevent files.
showCategories() {
    while true; do
        # Show menu list of categories, and their contents (including currently checkboxed) and description in preview.
        choice=$(
            printf "%s\n" "${categories[@]}" "${defaults[@]}" \
            | tac \
            | fzf \
                --preview "jq -r --arg category {} '.[] | select(.category == \$category) | .description' \"$dataDirectory/categories.json\" \"$dir/.default.json\";
                          cat "$dir/.temp/{}" 2>/dev/null;
                          if [[ {} == \"Install Selected\" || {} == \"Toggle All\" ]]; then
                              printf \"\n%s\n\" \"Currently Selected:\"
                              cat "$dir/.temp/*" 2>/dev/null | grep '^\[\*\]' | sed 's/^\(\[\]\|\[\*\]\) //'
                          elif [[ {} == \"Change Configs\" ]]; then 
                              printf '\nCurrent data directory: %s\nPackage manager: %s\nInit system: %s\nDisplay service: %s\n' \"$dataDirectory\" \"$pkgm\" \"$init\" \"$ds\"
                          fi" \
        )
        case $choice in 
            "Toggle All")
                toggleAll
                ;;
            "Install Selected")
                printf "%s\n" "Installing Selected"
                installSelected
                ;;
            "Change Configs")
                while true; do
                    input=$(
                        printf "%s\n" "${defaultsConfig[@]}" \
                        | tac \
                        | fzf \
                            --preview "jq -r --arg category {} '.[] | select(.category == \$category) | .description' \"$dir/.defaultConfigsMenu.json\";
                                      printf '\nCurrent data directory: %s\nPackage manager: %s\nInit system: %s\nDisplay service: %s\n' \"$dataDirectory\" \"$pkgm\" \"$init\" \"$ds\""
                    )
                    case $input in
                        "Change Data Directory")
                            choice=$(find ~ -type d ! -path "$dir" | fzf)
                            # If chosen directory contains categories.json file, accept it.
                            if [[ -f "$choice/categories.json" ]]; then
                                # Substitute line with dataDirectory= at the start, with dataDirectory=new value.
                                sed -i "s|^dataDirectory=.*|dataDirectory=$choice|" "$dir/.temp/.config"
                                createArrays
                            else
                                printf "%s\n" "Invalid directory $choice - does not contain categories.json file. Press Enter to return to menu."
                                read
                            fi
                            ;;
                        "Change Package Manager")
                            getPkgm
                            sed -i "s|^pkgm=.*|pkgm=$pkgm|" "$dir/.temp/.config"
                            ;;
                        "Change Init System")
                            getInit
                            sed -i "s|^init=.*|init=$init|" "$dir/.temp/.config"
                            ;;
                        "Change Display Server")
                            getDs
                            sed -i "s|^ds=.*|ds=$ds|" "$dir/.temp/.config"
                            ;;   
                        "" | "Exit")
                            break
                            ;;
                    esac
                done
                ;;
            "" | "Exit")
                printf "%s\n" "Exiting"
                exit
                ;;
            *)
                while true; do
                    # Remove spaces from chosen category.
                    option="${choice// /_}"
                    option="${option//[^a-zA-Z0-9_]/_}"

                    # Get the namesCategory array that stores all names in a certain category.
                    declare -n names="names${option}"
                    # Get the current state of each name in the category selected.
                    declare -n state="state${option}"
                    # Declare array of what is displayed to the user, populate it with checkbox from state and name from names.
                    unset items
                    declare -a items
                    for i in "${!names[@]}"; do
                        if [[ ${state[i]} == "false" ]]; then
                            items[i]="[] ${names[i]}"
                        else
                            items[i]="[*] ${names[i]}"
                        fi
                    done
                    
                    # Display to user and get state back. 
                    json='.[] | select(.name == ($name | sub("^(\\[\\]|\\[\\*\\]) "; ""))) | "Description:\n\(.description)\n\nScript:\n\(.script | join("\n"))"'
                    selected=$(printf "%s\n" "${items[@]}" | tac | fzf --multi --bind 'tab:toggle,ctrl-a:toggle-all' --header="Press esc or ctrl-q to exit." --preview "jq -r --arg name {} '$json' \"$dataDirectory/categories/$choice.json\"")
                    if [[ $? -eq 130 ]]; then 
                        break
                    fi

                    # Split selected into items. TODO: Make this able to have spaces perhaps?
                    mapfile -t indices < <(printf "%s\n" "$selected" | sed 's/^\(\[\]\|\[\*\]\) //')
                    for item in "${indices[@]}"; do 
                        index=$(jq -r --arg name "$item" 'map(.name) | index($name)' "$dataDirectory/categories/$choice.json")
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
                    for i in "${!names[@]}"; do
                        if [[ ${state[i]} == "false" ]]; then
                            items[i]="[] ${names[i]}"
                        else
                            items[i]="[*] ${names[i]}"
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
mkdir -p "$dir/.temp"
touch "$dir/.temp/.config"
determineSystem
createArrays # Create arrays associated with each category, for storing current state of each checkbox. Also create temp files for each category.
showCategories # Display menu.
