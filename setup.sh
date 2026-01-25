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

executeSelected() {
    # Execute games commands.
    output=()
    echo "Starting to execute commands"
    for (( i=0; i<${#appsName[@]}; i++ )); do
        if [[ "${appsSelected[$i]}" == "ON" ]]; then
            # If string return string, if array join the array of strings.
            if [[ $(jq --arg name "${appsName[$i]}" -r '.[] | select(.name == $name) | .script | type' ./data/applications.json) == "array" ]]; then
                script="$(jq --arg name "${appsName[$i]}" -r '.[] | select(.name == $name) | .script | join("\n")' ./data/applications.json)"
            else
                script="$(jq --arg name "${appsName[$i]}" -r '.[] | select(.name == $name) | .script' ./data/applications.json)"
            fi
            #echo $script
            #whiptail --scrolltext --msgbox "$(bash -c "$script")" 30 60
            # To avoid one command returning enough lines to crash the terminal as one string, break each line into a seperate index.
            #mapfile -t output < <(bash -c "$script" 2>/dev/null) # Overwrites output array, not what i want.
            output+=("$script")
            mapfile -t tmp < <(bash -c "$script" 2>/dev/null)
            output+=("${tmp[@]}")
            #output+=("$(bash -c "$script" 2>/dev/null)")
            output+=("")
        fi
    done
    echo "Executed all selected application commands."

    for (( i=0; i<${#installsName[@]}; i++ )); do
        if [[ "${installsSelected[$i]}" == "ON" ]]; then
            # If string return string, if array join the array of strings.
            if [[ $(jq --arg name "${installsName[$i]}" -r '.[] | select(.name == $name) | .script | type' ./data/package-installs.json) == "array" ]]; then
                script="$(jq --arg name "${installsName[$i]}" -r '.[] | select(.name == $name) | .script | join("\n")' ./data/package-installs.json)"
            else
                script="$(jq --arg name "${installsName[$i]}" -r '.[] | select(.name == $name) | .script' ./data/package-installs.json)"
            fi
            #echo $script
            #whiptail --scrolltext --msgbox "$(bash -c "$script")" 30 60
            output+=("$script")
            mapfile -t tmp < <(bash -c "$script" 2>/dev/null) 
            output+=("${tmp[@]}")     
            output+=("")
        fi
    done
    echo "Executed all selected package install commands."

    for (( i=0; i<${#removalsName[@]}; i++ )); do
        if [[ "${removalsSelected[$i]}" == "ON" ]]; then
            # If string return string, if array join the array of strings.
            if [[ $(jq --arg name "${removalsName[$i]}" -r '.[] | select(.name == $name) | .script | type' ./data/package-removals.json) == "array" ]]; then
                script="$(jq --arg name "${removalsName[$i]}" -r '.[] | select(.name == $name) | .script | join("\n")' ./data/package-removals.json)"
            else
                script="$(jq --arg name "${removalsName[$i]}" -r '.[] | select(.name == $name) | .script' ./data/package-removals.json)"
            fi
            #echo $script
            #whiptail --scrolltext --msgbox "$(bash -c "$script")" 30 60
            output+=("$script")
            mapfile -t tmp < <(bash -c "$script" 2>/dev/null) 
            output+=("${tmp[@]}")     
            output+=("")
        fi
    done
    echo "Executed all selected package removal commands."

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
            output+=("$script")
            mapfile -t tmp < <(bash -c "$script" 2>/dev/null) 
            output+=("${tmp[@]}")     
            output+=("")
        fi
    done
    echo "Executed all selected game commands."

    for (( i=0; i<${#configsName[@]}; i++ )); do
        if [[ "${configsSelected[$i]}" == "ON" ]]; then
            # If string return string, if array join the array of strings.
            if [[ $(jq --arg name "${configsName[$i]}" -r '.[] | select(.name == $name) | .script | type' ./data/configs.json) == "array" ]]; then
                script="$(jq --arg name "${configsName[$i]}" -r '.[] | select(.name == $name) | .script | join("\n")' ./data/configs.json)"
            else
                script="$(jq --arg name "${configsName[$i]}" -r '.[] | select(.name == $name) | .script' ./data/configs.json)"
            fi
            #echo $script
            #whiptail --scrolltext --msgbox "$(bash -c "$script")" 30 60
            output+=("$script")
            mapfile -t tmp < <(bash -c "$script" 2>/dev/null) 
            output+=("${tmp[@]}")     
            output+=("")
        fi
    done
    echo "Executed all selected configuration commands."

    for (( i=0; i<${#miscName[@]}; i++ )); do
        if [[ "${miscSelected[$i]}" == "ON" ]]; then
            # If string return string, if array join the array of strings.
            if [[ $(jq --arg name "${miscName[$i]}" -r '.[] | select(.name == $name) | .script | type' ./data/miscellaneous.json) == "array" ]]; then
                script="$(jq --arg name "${miscName[$i]}" -r '.[] | select(.name == $name) | .script | join("\n")' ./data/miscellaneous.json)"
            else
                script="$(jq --arg name "${miscName[$i]}" -r '.[] | select(.name == $name) | .script' ./data/miscellaneous.json)"
            fi
            #echo $script
            #whiptail --scrolltext --msgbox "$(bash -c "$script")" 30 60
            output+=("$script")
            mapfile -t tmp < <(bash -c "$script" 2>/dev/null) 
            output+=("${tmp[@]}")     
            output+=("")
        fi
    done
    echo "Executed all selected miscellaneous commands."

    output+=("All commands executed.")

    eval `resize`
    outputSize=${#output[@]}
    i=0
    while [ $i -lt $outputSize ]; do        
        text=""
        for ((k=0; k<$LINES && i<$outputSize; k++)); do
            text+="${output[$i]}" 
            text+="\n"
            ((i++))
        done
        whiptail --scrolltext --msgbox "$text" $LINES $COLUMNS
    done 
}

# Starting program.
if ! dpkg -s jq &>/dev/null; then
    sudo apt install jq -y # For interpreting json files.
fi

# Read name data from json files, this will be used later to get specific data for each menu. Uses parallel arrays to store whether the corresponding option is enabled. 1st array names, 2nd array whether its enabled, 3rd array scripts, these can be changed when overwrite is enabled/disabled.
# Application data
mapfile -t appsName < <(jq -r '.[].name' ./data/applications.json)
appsSelected=()
for ((i=0; i<${#appsName[@]}; i++)); do
    appsSelected[i]="OFF"
done

# Package installs
mapfile -t installsName < <(jq -r '.[].name' ./data/package-installs.json)
installsSelected=()
for ((i=0; i<${#installsName[@]}; i++)); do
    installsSelected[i]="OFF"
done

# Removing unecessary packages
mapfile -t removalsName < <(jq -r '.[].name' ./data/package-removals.json)
removalsSelected=()
for ((i=0; i<${#removalsName[@]}; i++)); do
    removalsSelected[i]="OFF"
done

# Game data
mapfile -t gamesName < <(jq -r '.[].name' ./data/games.json)
gamesSelected=()
for ((i=0; i<${#gamesName[@]}; i++)); do
    gamesSelected[i]="OFF"
done

# Configs
mapfile -t configsName < <(jq -r '.[].name' ./data/configs.json)
configsSelected=()
for ((i=0; i<${#configsName[@]}; i++)); do
    configsSelected[i]="OFF"
done

# Miscellaneous - e.g. deleting unecessary folders.
mapfile -t miscName < <(jq -r '.[].name' ./data/miscellaneous.json)
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
            for ((i=0; i<${#appsName[@]}; i++)); do
                appsSelected[i]="OFF"
            done
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                string=$1
                index=-1
                for i in "${!appsName[@]}"; do
                    #echo "${gamesName[$i]}"
                    if [[ "${appsName[$i]}" == "$opt" ]]; then
                        index=$i
                        break
                    fi
                done
                if (( index != -1 )); then
                    appsSelected[$index]="ON"
                fi
            done
            ;;
        "Package Installs")
            option="$(display_installs_menu 3>&1 1>&2 2>&3)"
            # Split option into individual names.
            #IFS=' ' 
            #read -a options <<< "$option"
            eval "options=($option)"
            for ((i=0; i<${#installsName[@]}; i++)); do
                installsSelected[i]="OFF"
            done
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                string=$1
                index=-1
                for i in "${!installsName[@]}"; do
                    #echo "${gamesName[$i]}"
                    if [[ "${installsName[$i]}" == "$opt" ]]; then
                        index=$i
                        break
                    fi
                done
                if (( index != -1 )); then
                    installsSelected[$index]="ON"
                fi
            done
            ;;
        "Software Removal")
            option="$(display_removals_menu 3>&1 1>&2 2>&3)"
            # Split option into individual names.
            #IFS=' ' 
            #read -a options <<< "$option"
            eval "options=($option)"
            for ((i=0; i<${#removalsName[@]}; i++)); do
                removalsSelected[i]="OFF"
            done
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                string=$1
                index=-1
                for i in "${!removalsName[@]}"; do
                    #echo "${gamesName[$i]}"
                    if [[ "${removalsName[$i]}" == "$opt" ]]; then
                        index=$i
                        break
                    fi
                done
                if (( index != -1 )); then
                    removalsSelected[$index]="ON"
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
            # Options is a list of those that are enabled. Set all to disabled then iterate through setting new values.
            for ((i=0; i<${#gamesName[@]}; i++)); do
                gamesSelected[i]="OFF"
            done
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                string=$1
                index=-1
                for i in "${!gamesName[@]}"; do
                    #echo "${gamesName[$i]}"
                    if [[ "${gamesName[$i]}" == "$opt" ]]; then
                        index=$i
                        break
                    fi
                done
                if (( index != -1 )); then
                    gamesSelected[$index]="ON"
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
            for ((i=0; i<${#configsName[@]}; i++)); do
                configsSelected[i]="OFF"
            done
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                string=$1
                index=-1
                for i in "${!configsName[@]}"; do
                    #echo "${gamesName[$i]}"
                    if [[ "${configsName[$i]}" == "$opt" ]]; then
                        index=$i
                        break
                    fi
                done
                if (( index != -1 )); then
                    configsSelected[$index]="ON"
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
            for ((i=0; i<${#miscName[@]}; i++)); do
                miscSelected[i]="OFF"
            done
            for opt in "${options[@]}"; do
                #echo $opt
                opt=$(echo "$opt" | xargs)
                string=$1
                index=-1
                for i in "${!miscName[@]}"; do
                    #echo "${gamesName[$i]}"
                    if [[ "${miscName[$i]}" == "$opt" ]]; then
                        index=$i
                        break
                    fi
                done
                if (( index != -1 )); then
                    miscSelected[$index]="ON"
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
            echo "Invalid option selected"
            exit
            ;;        
    esac
done         
