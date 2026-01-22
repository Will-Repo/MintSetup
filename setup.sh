#!/bin/bash

default=$1
option=null

display_main_menu() {
    eval `resize`
    whiptail --title "Setup menu - configure what to install within each catagory." --menu "Options are selected by default, enter false as the parameter of the setup script to have all options selected to false." $LINES $COLUMNS $(($LINES - 8)) \
    "asd" "" \
    "Applications" "" \
    "Games" "" \
    "Setup/install selected" "" \
    "Exit" "" 
    # The option selected is printed to stderr.
}

display_game_menu() {
whiptail --title "Check list example" --checklist \
    "Choose user's permissions" 20 78 4 \
    "NET_OUTBOUND" "Allow connections to other hosts" ON \
    "NET_INBOUND" "Allow connections from other hosts" OFF \
    "LOCAL_MOUNT" "Allow mounting of local devices" OFF \
    "REMOTE_MOUNT" "Allow mounting of remote devices" OFF
}

# Starting program.
while [ "$option" != "Exit" ] 
do
    option="$(display_main_menu 3>&1 1>&2 2>&3)"
    echo $option

    case $option in 
        "Applications")
            ;;
        "Games")
            display_game_menu
            ;;
        "Setup/install selected")
            ;;
        "Exit")
            exit
            ;;
        *)
            exit
            ;;
    esac
done
