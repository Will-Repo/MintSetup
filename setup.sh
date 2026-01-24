#!/bin/bash

default=$1
option=null

display_main_menu() {
    eval `resize`
    whiptail --title "Setup menu - configure what to install within each catagory." --ok-button "DO NOT PRESS" --cancel-button "Exit" --menu "Options are selected by default, enter false as the parameter of the setup script to have all options selected to false." $LINES $COLUMNS $(($LINES - 8)) \
    "Select All" "" \
    "Deselect All" "" \
    "Applications" "" \
    "Package Removal" "Removing unecessary packages." \
    "Games" "" \
    "Remote Data" "" \
    "Configs" "" \
    "Miscellaneous" "" \
    "Setup/Install Selected" "" \
    "Exit" "" 
    # The option selected is printed to stderr. Which has been redirected to stdcout.
}

display_game_menu() {
    options=()
    for i in "${!gamesName[@]}"; do
        description="$(jq --arg name "${gamesName[i]}" '.[] | select(.name == $name) | .description' ./data/games.json)"
        options+=( \
            "${gamesName[i]}" \
            "$description" \
            "${gamesSelected[i]}" \
        )
    done
    
    #echo ${options[@]}
    eval `resize`
    whiptail --title "Games install options" --checklist "Choose what game software to install" $LINES $COLUMNS $(($LINES - 8)) \
    "${options[@]}"
}

getIndex() {
    string=$1
    index=-1
    for i in "${!gamesName[@]}"; do
        #echo "${gamesName[$i]}"
        if [[ "${gamesName[$i]}" == "$string" ]]; then
            index=$i
            break
        fi
    done
    echo $index
}

executeSelected() {
    # Execute games commands.
    for (( i=0; i<${#gamesName[@]}; i++ )); do
        if [[ "${gamesSelected[$i]}" == "ON" ]]; then
            # If string return string, if array join the array of strings.
            if [[ $(jq --arg name "${gamesName[$i]}" -r '.[] | select(.name == $name) | .script | type' ./data/games.json) == "array" ]]; then
                script="$(jq --arg name "${gamesName[$i]}" -r '.[] | select(.name == $name) | .script | join("\n")' ./data/games.json)"
            else
                script="$(jq --arg name "${gamesName[$i]}" -r '.[] | select(.name == $name) | .script' ./data/games.json)"
            fi
            #echo $script
            bash -c "$script"
        fi
    done
}

# Starting program.
if ! dpkg -s jq &>/dev/null; then
    sudo apt install jq -y # For interpreting json files.
fi

# Read name data from json files, this will be used later to get specific data for each menu. Uses parallel arrays to store whether the corresponding option is enabled. 1st array names, 2nd array whether its enabled, 3rd array scripts, these can be changed when overwrite is enabled/disabled.
# Application data
# Removing unecessary packages
# Game data
mapfile -t gamesName < <(jq -r '.[].name' ./data/games.json)
gamesScript=$(jq '.[].script' ./data/games.json) # All entries must have a name and script, everything else is optional.
gamesSelected=()
for ((i=0; i<${#gamesName[@]}; i++)); do
    gamesSelected[i]="OFF"
done
# Remote data
# Configs
# Miscellaneous - e.g. deleting unecessary folders.

#echo ${gamesName[*]}

while [ "$option" != "Exit" ] 
do
    option="$(display_main_menu 3>&1 1>&2 2>&3)" # stderr is redirected to stdout before display_main_menu is called.

    #echo $option
    case $option in
        "Select All")
            ;;
        "Deselect All")
            ;;
        "Applications")
            ;;
        "Package Removal")
            ;;
        "Games")
            # Enter the game menu. return the names of any options that change.
            option="$(display_game_menu 3>&1 1>&2 2>&3)"
            # Split option into individual names.
            #IFS=' ' 
            #read -a options <<< "$option"
            eval "options=($option)"
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                index=$(getIndex "$opt")
                if (( index != -1 )); then
                    if [[ "${gamesSelected[$index]}" == "OFF" ]]; then
                        gamesSelected[$index]="ON"
                    else 
                        gamesSelected[$index]="OFF"
                    fi
                fi
            done
            #echo "${gamesSelected[@]}"
            ;;
        "Remote Data")
            ;;
        "Configs")
            ;;
        "Miscellaneous")
            ;;
        "Setup/Install Selected")
            executeSelected
            ;;
        "Exit")                
            exit
            ;;
        *)
            echo "Invalid option or exit selected"
            exit
            ;;        
    esac
done
                
