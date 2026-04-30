# Initial installation manager for my Linux Mint install.

## Overview
This is a command line interface that will install the defaults for my system, and other optional applications and systems. 
This uses [gum][https://github.com/charmbracelet/gum] to display the interface.
Installing something that is already on the system will result in the install not happening.

## Dependencies
[gum][https://github.com/charmbracelet/gum] must be installed.
[jq][https://github.com/jqlang/jq] must be installed.
Bash shell program must be at /bin/bash - or modify first line of the script to point to your bash program.

## Recommended Install Locations
Install general applications to ~/.local/share/

## To-do
Make all apps open in a seperate window - particularly browser websites.
Add exit prompt that asks whether they want to install selected.
Hitting escape unselects every option - fix this unintended behavior.
Split into setup script, and additional downloads.
