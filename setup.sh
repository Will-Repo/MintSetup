#!/bin/bash

default=$1
option=null

display_main_menu() {
    eval `resize`
    whiptail --title "Setup menu - configure what to install within each catagory." --ok-button "DO NOT PRESS" --cancel-button "Exit" --menu "Options are selected by default, enter false as the parameter of the setup script to have all options selected to false." $LINES $COLUMNS $(($LINES - 8)) \
    "Select All" "" \
    "Deselect All" "" \
    "Applications" "Standalone applications" \
    "Package Installs" "Command line tools and other software dependencies." \
    "Software Removal" "Removing unecessary packages and applications." \
    "Games" "" \
    "Configs" "" \
    "Miscellaneous" "" \
    "Setup/Install Selected" "" \
    "Exit" "" 
    # The option selected is printed to stderr. Which has been redirected to stdcout.
}

display_application_menu() {
    options=()
    for i in "${!appsName[@]}"; do
        description="$(jq -r --arg name "${appsName[i]}" '.[] | select(.name == $name) | .description' ./data/applications.json)"
        options+=( \
            "${appsName[i]}" \
            "$description" \
            "${appsSelected[i]}" \
        )
    done
    
    #echo ${options[@]}
    eval `resize`
    whiptail --title "Application install options" --checklist "Choose what applications to install" $LINES $COLUMNS $(($LINES - 8)) \
    "${options[@]}"
}

display_installs_menu() {
    options=()
    for i in "${!installsName[@]}"; do
        description="$(jq -r --arg name "${installsName[i]}" '.[] | select(.name == $name) | .description' ./data/package-installs.json)"
        options+=( \
            "${installsName[i]}" \
            "$description" \
            "${installsSelected[i]}" \
        )
    done
    
    #echo ${options[@]}
    eval `resize`
    whiptail --title "Package install options" --checklist "Choose what packages to install" $LINES $COLUMNS $(($LINES - 8)) \
    "${options[@]}"
}

display_removals_menu() {
    options=()
    for i in "${!removalsName[@]}"; do
        description="$(jq -r --arg name "${removalsName[i]}" '.[] | select(.name == $name) | .description' ./data/package-removals.json)"
        options+=( \
            "${removalsName[i]}" \
            "$description" \
            "${removalsSelected[i]}" \
        )
    done
    
    #echo ${options[@]}
    eval `resize`
    whiptail --title "Package removal options" --checklist "Choose what packages to uninstall" $LINES $COLUMNS $(($LINES - 8)) \
    "${options[@]}"
}

display_game_menu() {
    options=()
    for i in "${!gamesName[@]}"; do
        description="$(jq -r --arg name "${gamesName[i]}" '.[] | select(.name == $name) | .description' ./data/games.json)"
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

display_configs_menu() {
    options=()
    for i in "${!configsName[@]}"; do
        description="$(jq -r --arg name "${configsName[i]}" '.[] | select(.name == $name) | .description' ./data/configs.json)"
        options+=( \
            "${configsName[i]}" \
            "$description" \
            "${configsSelected[i]}" \
        )
    done
    
    #echo ${options[@]}
    eval `resize`
    whiptail --title "Configuration options" --checklist "Choose what configurations to set up" $LINES $COLUMNS $(($LINES - 8)) \
    "${options[@]}"
}

display_misc_menu() {
    options=()
    for i in "${!configsName[@]}"; do
        description="$(jq -r --arg name "${miscName[i]}" '.[] | select(.name == $name) | .description' ./data/miscellaneous.json)"
        options+=( \
            "${miscName[i]}" \
            "$description" \
            "${miscSelected[i]}" \
        )
    done
    
    #echo ${options[@]}
    eval `resize`
    whiptail --title "Miscellaneous options" --checklist "Choose what miscellanous options to set up" $LINES $COLUMNS $(($LINES - 8)) \
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
            #whiptail --scrolltext --msgbox "$(bash -c "$script")" 30 60
            output+=$(bash -c "$script" 2>/dev/null)
        fi
    done
    eval `resize`
    whiptail --scrolltext --msgbox "$output" $LINES $COLUMNS 
}

# Starting program.
if ! dpkg -s jq &>/dev/null; then
    sudo apt install jq -y # For interpreting json files.
fi

# Read name data from json files, this will be used later to get specific data for each menu. Uses parallel arrays to store whether the corresponding option is enabled. 1st array names, 2nd array whether its enabled, 3rd array scripts, these can be changed when overwrite is enabled/disabled.
# Application data
mapfile -t appsName < <(jq -r '.[].name' ./data/applications.json)
appScript=$(jq '.[].script' ./data/applications.json) # All entries must have a name and script, everything else is optional.
appsSelected=()
for ((i=0; i<${#appsName[@]}; i++)); do
    appsSelected[i]="OFF"
done

# Package installs
mapfile -t installsName < <(jq -r '.[].name' ./data/package-installs.json)
installsScript=$(jq '.[].script' ./data/package-installs.json) # All entries must have a name and script, everything else is optional.
installsSelected=()
for ((i=0; i<${#installsName[@]}; i++)); do
    installsSelected[i]="OFF"
done

# Removing unecessary packages
mapfile -t removalsName < <(jq -r '.[].name' ./data/package-removals.json)
removalsScript=$(jq '.[].script' ./data/package-removals.json) # All entries must have a name and script, everything else is optional.
removalsSelected=()
for ((i=0; i<${#removalsName[@]}; i++)); do
    removalsSelected[i]="OFF"
done

# Game data
mapfile -t gamesName < <(jq -r '.[].name' ./data/games.json)
gamesScript=$(jq '.[].script' ./data/games.json) # All entries must have a name and script, everything else is optional.
gamesSelected=()
for ((i=0; i<${#gamesName[@]}; i++)); do
    gamesSelected[i]="OFF"
done

# Configs
mapfile -t configsName < <(jq -r '.[].name' ./data/configs.json)
configsScript=$(jq '.[].script' ./data/configs.json) # All entries must have a name and script, everything else is optional.
configsSelected=()
for ((i=0; i<${#configsName[@]}; i++)); do
    configsSelected[i]="OFF"
done

# Miscellaneous - e.g. deleting unecessary folders.
mapfile -t miscName < <(jq -r '.[].name' ./data/miscellaneous.json)
miscScript=$(jq '.[].script' ./data/miscellaneous.json) # All entries must have a name and script, everything else is optional.
miscSelected=()
for ((i=0; i<${#miscName[@]}; i++)); do
    miscSelected[i]="OFF"
done

#echo ${gamesName[*]}

while [ "$option" != "Exit" ] 
do
    option="$(display_main_menu 3>&1 1>&2 2>&3)" # stderr is redirected to stdout before display_main_menu is called.
    #echo $option
    case $option in
        "Select All")
            for ((i=0; i<${#appsName[@]}; i++)); do
                appsSelected[i]="ON"
            done
            for ((i=0; i<${#installsName[@]}; i++)); do
                installsSelected[i]="ON"
            done
            for ((i=0; i<${#removalsName[@]}; i++)); do
                removalsSelected[i]="ON"
            done
            for ((i=0; i<${#gamesName[@]}; i++)); do
                gamesSelected[i]="ON"
            done
            for ((i=0; i<${#configsName[@]}; i++)); do
                configsSelected[i]="ON"
            done
            for ((i=0; i<${#miscName[@]}; i++)); do
                miscSelected[i]="ON"
            done
            ;;
        "Deselect All")
            for ((i=0; i<${#appsName[@]}; i++)); do
                appsSelected[i]="OFF"
            done
            for ((i=0; i<${#installsName[@]}; i++)); do
                installsSelected[i]="OFF"
            done
            for ((i=0; i<${#removalsName[@]}; i++)); do
                removalsSelected[i]="OFF"
            done
            for ((i=0; i<${#gamesName[@]}; i++)); do
                gamesSelected[i]="OFF"
            done
            for ((i=0; i<${#configsName[@]}; i++)); do
                configsSelected[i]="OFF"
            done
            for ((i=0; i<${#miscName[@]}; i++)); do
                miscSelected[i]="OFF"
            done
            ;;
        "Applications")
            option="$(display_application_menu 3>&1 1>&2 2>&3)"
            # Split option into individual names.
            #IFS=' ' 
            #read -a options <<< "$option"
            eval "options=($option)"
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                index=$(getIndex "$opt")
                if (( index != -1 )); then
                    if [[ "${appsSelected[$index]}" == "OFF" ]]; then
                        appsSelected[$index]="ON"
                    else 
                        appsSelected[$index]="OFF"
                    fi
                fi
            done
            ;;
        "Package Installs")
            option="$(display_installs_menu 3>&1 1>&2 2>&3)"
            # Split option into individual names.
            #IFS=' ' 
            #read -a options <<< "$option"
            eval "options=($option)"
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                index=$(getIndex "$opt")
                if (( index != -1 )); then
                    if [[ "${installsSelected[$index]}" == "OFF" ]]; then
                        installsSelected[$index]="ON"
                    else 
                        installsSelected[$index]="OFF"
                    fi
                fi
            done
            ;;
        "Software Removal")
            option="$(display_removals_menu 3>&1 1>&2 2>&3)"
            # Split option into individual names.
            #IFS=' ' 
            #read -a options <<< "$option"
            eval "options=($option)"
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                index=$(getIndex "$opt")
                if (( index != -1 )); then
                    if [[ "${removalsSelected[$index]}" == "OFF" ]]; then
                        removalsSelected[$index]="ON"
                    else 
                        removalsSelected[$index]="OFF"
                    fi
                fi
            done
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
        "Configs")
            # Enter the game menu. return the names of any options that change.
            option="$(display_configs_menu 3>&1 1>&2 2>&3)"
            # Split option into individual names.
            #IFS=' ' 
            #read -a options <<< "$option"
            eval "options=($option)"
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                index=$(getIndex "$opt")
                if (( index != -1 )); then
                    if [[ "${configsSelected[$index]}" == "OFF" ]]; then
                        configsSelected[$index]="ON"
                    else 
                        configsSelected[$index]="OFF"
                    fi
                fi
            done
            ;;
        "Miscellaneous")
            # Enter the game menu. return the names of any options that change.
            option="$(display_misc_menu 3>&1 1>&2 2>&3)"
            # Split option into individual names.
            #IFS=' ' 
            #read -a options <<< "$option"
            eval "options=($option)"
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                index=$(getIndex "$opt")
                if (( index != -1 )); then
                    if [[ "${miscSelected[$index]}" == "OFF" ]]; then
                        miscSelected[$index]="ON"
                    else 
                        miscSelected[$index]="OFF"
                    fi
                fi
            done
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
