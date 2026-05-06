# Script Management Tool

## Overview
fzf based checkbox interface for selecting scripts to run on a system.\
Can be used for any scripts, but was originally intended for use as a clean OS install setup script.

## UI Controls
### Navigating the interface
Use arrow keys or basic vim bindings (requires holding Ctrl) to navigate the menu.\
Press Enter to select a menu choice.

### Selecting checkboxes
To select a single checkbox, press Enter whilst hovering it - note that this will reload fzf, returning the selection tool to its initial position.\
To select multiple checkboxes at once, press Tab whilst hovering each checkbox, then press Enter to apply changes.

## Scripts Information
Scripts have access to the PKGM, INIT and DS variables for the package manager, init system and display service.

## Scripts Output
Log files are stored to .temp - all.log and errors.log respectively.\
If tmux is installed, stderr of each script is outputted to one window, and combined stdout and stderr to another.\
If tmux is not installed, all script output is displayed on the terminal.

## Dependencies
[fzf][https://github.com/junegunn/fzf] must be installed.\
[jq][https://github.com/jqlang/jq] must be installed.\
tac must be installed.\
Bash shell program (version 4 or later) must be found at /bin/bash - or modify first line of the script to point to your bash program.\
[recommended] tmux

## To-do
Add exit prompt that asks whether they want to install selected.
Remove large files from being tracked - e.g. GHIDRA, oops lol.
Add titles to each tmux pane.
Add section on fzf keybinds - particularly select all + deselect all.
Add example scripts using config variables.
Only determine system if not stored in .config gile.
