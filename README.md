# Initial installation manager for my Linux Mint install.

## Overview
This is a command line interface that will install the defaults for my system, and other optional applications and systems. 
This uses fzf and the terminal to display the interface.
Installing something that is already on the system will result in the install not happening.

## Controls
### Selecting checkboxes
Selecting options using enter automatically updates the checkbox, but causes screen flicker (fzf must reload).
Selecting checkboxes using tab marks boxes as selected, but the checkboxes dont update until the next enter input.

## Dependencies
[fzf][https://github.com/junegunn/fzf] must be installed.
[jq][https://github.com/jqlang/jq] must be installed.
tac must be installed.
Bash shell program (version 4 or later) must be at /bin/bash - or modify first line of the script to point to your bash program.

## Recommended Install Locations
Install general applications to ~/.local/share/

## To-do
Finalise the menu formmat.
Display menu using fzf.
Add exit prompt that asks whether they want to install selected.
Decide whether to replace tac with array reversal.
