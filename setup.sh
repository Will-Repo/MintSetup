#!/bin/bash

default=$1
option=null

display_main_menu () {
    eval `resize`
    whiptail --title "Setup menu - configure what to install within each catagory." --menu "Options are selected by default, enter false as the parameter of the setup script to have all options selected to false." $LINES $COLUMNS $(($LINES - 8)) \
    "asd" "" \
    "Applications" "" \
    "Games" "" \
    "Setup/install selected" "" \
    "Exit" "" 
    # The option selected is printed to stderr.
}

# Starting program.
while [ "$option" != "Exit" ] 
do
    option="$(display_main_menu 3>&1 1>&2 2>&3)"
    echo $option
done
